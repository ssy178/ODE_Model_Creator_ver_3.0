classdef MichaelisMentenShortFeedbackReaction < Reaction
    % MICHAELISMENTENSSHORTFEEDBACKREACTION Michaelis-Menten Short with Feedback reaction
    %
    % Implements simple enzyme kinetics with feedback inhibition
    % Forward reaction only (irreversible)
    %
    % Reaction form: A => B
    % Rate equation: vf = (sum(kc*activators)*A) / inhibitor_terms
    %
    % Parameters:
    %   kc_A_B_ACT            - Catalytic rate for each activator
    %   Ki_A_B_EMZ_INH        - Inhibition constant (for each inhibitor)
    %
    % Example:
    %   dataArray = {'MMSF', 'A', 'B', 'EMZ', '+ENZ', '-INH'};
    %   reaction = MichaelisMentenShortFeedbackReaction('R1', dataArray);

    methods
        function obj = MichaelisMentenShortFeedbackReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('MMSF', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['MMSF', 'substrate', 'product', 'enzyme', '+activator', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements
            Reaction.validateMinimumElements(charData, 4, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, activators, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrates: A; products: B; modifiers: EMZ)
            obj.setSpecies({species{2}}, {species{3}}, {species{4}});

            % Set regulators
            obj.setRegulators(activators, inhibitors);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "A=>B:R1"
            procStr = sprintf('%s=>%s:%s', obj.substrates{1}, obj.products{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the Michaelis-Menten short feedback rate equation
            % Returns: Rate equation string

            A = obj.substrates{1};
            B = obj.products{1};
            EMZ = obj.modifiers{1};

            % Build activator reaction terms: sum(kc*activators)
            if ~isempty(obj.activators)
                activatorTerms = '';
                for i = 1:length(obj.activators)
                    act = obj.activators{i};
                    actParam = sprintf('kc_%s_%s_%s', A, B, act);
                    activatorTerms = [activatorTerms, sprintf('%s*%s', actParam, act)];
                    if i < length(obj.activators)
                        activatorTerms = [activatorTerms, '+'];
                    end
                end
                ratePart = sprintf('vf = (%s)*%s/(', activatorTerms, A);
            else
                error('MichaelisMentenShortFeedbackReaction:NoActivators', ...
                    'MMSF reaction requires at least one activator');
            end

            % Build inhibitor terms
            if ~isempty(obj.inhibitors)
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    inhParam = sprintf('Ki_%s_%s_%s_%s', A, B, EMZ, inh);
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
            B = obj.products{1};
            EMZ = obj.modifiers{1};

            % Activator catalytic rates
            params = {};
            for i = 1:length(obj.activators)
                act = obj.activators{i};
                params{end+1} = sprintf('kc_%s_%s_%s', A, B, act);
            end

            % Inhibition constants
            for i = 1:length(obj.inhibitors)
                inh = obj.inhibitors{i};
                params{end+1} = sprintf('Ki_%s_%s_%s_%s', A, B, EMZ, inh);
            end
        end
    end
end
