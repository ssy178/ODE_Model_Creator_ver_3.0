classdef SimpleDegradationReaction < Reaction
    % SIMPLEDEGRADATIONREACTION Simple Active Degradation (Short form) reaction: A =>
    %
    % Implements active protein degradation with activators (proteases)
    % Short form (Linear kinetics, no saturation)
    %
    % Reaction form: A =>
    % Rate equation: vf = sum(kdeg*A*activators) / inhibitor_terms
    %
    % Parameters:
    %   kdeg_A_ACT            - Degradation rate for each activator
    %   Ki_deg_A_Protease_INH - Inhibition constant (for each inhibitor)
    %
    % Example:
    %   dataArray = {'DEGS', 'A', 'PROTEASE', '+ENZ', '-INH'};
    %   reaction = SimpleDegradationReaction('R1', dataArray);

    methods
        function obj = SimpleDegradationReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('DEGS', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['DEGS', 'substrate', 'protease', '+activator', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements
            Reaction.validateMinimumElements(charData, 3, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, activators, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrates: A; products: none; modifiers: PROTEASE)
            obj.setSpecies({species{2}}, {}, {species{3}});

            % Set regulators
            obj.setRegulators(activators, inhibitors);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "A=>:R1"
            procStr = sprintf('%s=>:%s', obj.substrates{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the simple degradation full rate equation
            % Returns: Rate equation string

            A = obj.substrates{1};
            PROTEASE = obj.modifiers{1};

            % Build activator degradation terms: sum(kdeg*A*activators)
            if ~isempty(obj.activators)
                activatorTerms = '';
                for i = 1:length(obj.activators)
                    act = obj.activators{i};
                    actParam = sprintf('kdeg_%s_%s', A, act);
                    activatorTerms = [activatorTerms, sprintf('%s*%s*%s', actParam, A, act)];
                    if i < length(obj.activators)
                        activatorTerms = [activatorTerms, '+'];
                    end
                end
                ratePart = sprintf('vf = (%s)/(', activatorTerms);
            else
                error('SimpleDegradationReaction:NoActivators', ...
                    'DEGS reaction requires at least one activator');
            end

            % Build inhibitor terms
            if ~isempty(obj.inhibitors)
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    inhParam = sprintf('Ki_deg_%s_%s_%s', A, PROTEASE, inh);
                    ratePart = [ratePart, sprintf('(1 + %s*%s)*', inhParam, inh)];
                end
                % Replace trailing '*' with ')'
                ratePart(end) = ')';
            else
                % Remove trailing '/('
                ratePart = ratePart(1:end-2);
            end

            rateEq = ratePart;
        end

        function params = getParameterNames(obj)
            % Get all parameter names for this reaction
            % Returns: Cell array of parameter names

            A = obj.substrates{1};
            PROTEASE = obj.modifiers{1};

            % Activator degradation rates
            params = {};
            for i = 1:length(obj.activators)
                act = obj.activators{i};
                params{end+1} = sprintf('kdeg_%s_%s', A, act);
            end

            % Inhibition constants
            for i = 1:length(obj.inhibitors)
                inh = obj.inhibitors{i};
                params{end+1} = sprintf('Ki_deg_%s_%s_%s', A, PROTEASE, inh);
            end
        end
    end
end
