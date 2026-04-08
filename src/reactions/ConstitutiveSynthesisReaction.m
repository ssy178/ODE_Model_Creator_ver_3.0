classdef ConstitutiveSynthesisReaction < Reaction
    % CONSTITUTIVESYNTHESISREACTION Constitutive Synthesis reaction: => A
    %
    % Implements constitutive (constant) protein synthesis
    % with optional inhibitors
    %
    % Reaction form: => A
    % Rate equation: vf = Vsyn_A / inhibitor_terms
    %
    % Parameters:
    %   Vsyn_A                - Synthesis rate constant
    %   Ki_syn_A_INH          - Inhibition constant (for each inhibitor)
    %
    % Example:
    %   dataArray = {'SYN0', 'A', '-INH'};
    %   reaction = ConstitutiveSynthesisReaction('R1', dataArray);

    methods
        function obj = ConstitutiveSynthesisReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('SYN0', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['SYN0', 'product', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements (only 2 required: type, product)
            Reaction.validateMinimumElements(charData, 2, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, ~, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrates: none; products: A)
            obj.setSpecies({}, {species{2}}, {});

            % Set regulators (no activators for SYN0)
            obj.setRegulators({}, inhibitors);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "=>A:R1"
            procStr = sprintf('=>%s:%s', obj.products{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the constitutive synthesis rate equation
            % Returns: Rate equation string

            A = obj.products{1};

            % Base reaction: Vsyn_A
            baseParam = sprintf('Vsyn_%s', A);
            baseReaction = baseParam;

            % Build inhibitor terms
            if ~isempty(obj.inhibitors)
                ratePart = sprintf('vf = %s/(', baseReaction);
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    inhParam = sprintf('Ki_syn_%s_%s', A, inh);
                    ratePart = [ratePart, sprintf('(1 + %s*%s)*', inhParam, inh)];
                end
                % Replace trailing '*' with ')'
                ratePart(end) = ')';
            else
                ratePart = sprintf('vf = %s', baseReaction);
            end

            rateEq = ratePart;
        end

        function params = getParameterNames(obj)
            % Get all parameter names for this reaction
            % Returns: Cell array of parameter names

            A = obj.products{1};

            % Synthesis rate parameter
            params = {sprintf('Vsyn_%s', A)};

            % Inhibition constants
            for i = 1:length(obj.inhibitors)
                inh = obj.inhibitors{i};
                params{end+1} = sprintf('Ki_syn_%s_%s', A, inh);
            end
        end
    end
end
