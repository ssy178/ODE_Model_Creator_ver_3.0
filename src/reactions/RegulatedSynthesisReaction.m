classdef RegulatedSynthesisReaction < Reaction
    % REGULATEDSYNTHESISREACTION Regulated Synthesis (Full form) reaction: => A
    %
    % Implements regulated protein synthesis with activator transcription factors
    % Full form with Michaelis constants for each activator
    %
    % Reaction form: => A
    % Rate equation: vf = sum(ksyn*act/(Km_act+act)) / inhibitor_terms
    %
    % Parameters:
    %   ksyn_A_ACT            - Synthesis rate for each activator
    %   Km_A_ACT              - Michaelis constant for each activator
    %   Ki_syn_A_INH          - Inhibition constant (for each inhibitor)
    %
    % Example:
    %   dataArray = {'SYNF', 'A', 'TF', '+ENZ', '-INH'};
    %   reaction = RegulatedSynthesisReaction('R1', dataArray);

    methods
        function obj = RegulatedSynthesisReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('SYNF', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['SYNF', 'product', 'TF', '+activator', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements
            Reaction.validateMinimumElements(charData, 3, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, activators, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrates: none; products: A; modifiers: TF)
            obj.setSpecies({}, {species{2}}, {species{3}});

            % Set regulators
            obj.setRegulators(activators, inhibitors);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "=>A:R1"
            procStr = sprintf('=>%s:%s', obj.products{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the regulated synthesis full rate equation
            % Returns: Rate equation string

            A = obj.products{1};

            % Build activator reaction terms: sum(ksyn*act/(Km+act))
            if ~isempty(obj.activators)
                activatorTerms = '';
                for i = 1:length(obj.activators)
                    act = obj.activators{i};
                    actParam = sprintf('ksyn_%s_%s', A, act);
                    kmParam = sprintf('Km_%s_%s', A, act);
                    activatorTerms = [activatorTerms, sprintf('%s*%s/(%s + %s)', ...
                        actParam, act, kmParam, act)];
                    if i < length(obj.activators)
                        activatorTerms = [activatorTerms, '+'];
                    end
                end
                ratePart = sprintf('vf = (%s)/(', activatorTerms);
            else
                error('RegulatedSynthesisReaction:NoActivators', ...
                    'SYNF reaction requires at least one activator');
            end

            % Build inhibitor terms
            if ~isempty(obj.inhibitors)
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    inhParam = sprintf('Ki_syn_%s_%s', A, inh);
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

            A = obj.products{1};

            params = {};

            % Activator synthesis rates
            for i = 1:length(obj.activators)
                act = obj.activators{i};
                params{end+1} = sprintf('ksyn_%s_%s', A, act);
            end

            % Michaelis constants for activators
            for i = 1:length(obj.activators)
                act = obj.activators{i};
                params{end+1} = sprintf('Km_%s_%s', A, act);
            end

            % Inhibition constants
            for i = 1:length(obj.inhibitors)
                inh = obj.inhibitors{i};
                params{end+1} = sprintf('Ki_syn_%s_%s', A, inh);
            end
        end
    end
end
