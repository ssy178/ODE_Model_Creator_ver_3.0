classdef RegulatedDegradationReaction < Reaction
    % REGULATEDDEGRADATIONREACTION Regulated Active Degradation (Full form) reaction: A =>
    %
    % Implements active protein degradation with activators (proteases)
    % Full form with Michaelis constant and divisor
    %
    % Reaction form: A =>
    % Rate equation: vf = sum(kdeg*A*activators) / (Km+A) / inhibitor_terms
    %
    % Parameters:
    %   kdeg_A_ACT            - Degradation rate for each activator
    %   Km_A_Protease         - Michaelis constant
    %   Ki_deg_A_Protease_INH - Inhibition constant (for each inhibitor)
    %
    % Example:
    %   dataArray = {'DEGF', 'A', 'PROTEASE', '+ENZ', '-INH'};
    %   reaction = RegulatedDegradationReaction('R1', dataArray);

    methods
        function obj = RegulatedDegradationReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('DEGF', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['DEGF', 'substrate', 'protease', '+activator', '-inhibitor', ...]

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
            % Generate the regulated degradation full rate equation
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

                % Add Michaelis constant term
                kmParam = sprintf('Km_%s_%s', A, PROTEASE);
                ratePart = sprintf('vf = (%s)/((%s + %s))/(', activatorTerms, kmParam, A);
            else
                error('RegulatedDegradationReaction:NoActivators', ...
                    'DEGF reaction requires at least one activator');
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

            % Michaelis constant
            params{end+1} = sprintf('Km_%s_%s', A, PROTEASE);

            % Inhibition constants
            for i = 1:length(obj.inhibitors)
                inh = obj.inhibitors{i};
                params{end+1} = sprintf('Ki_deg_%s_%s_%s', A, PROTEASE, inh);
            end
        end
    end
end
