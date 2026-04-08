classdef DissociationReaction < Reaction
    % DISSOCIATIONREACTION Dissociation (Irreversible) reaction: C => A + B
    %
    % Implements irreversible dissociation with optional inhibitors
    %
    % Reaction form: C => A + B
    % Rate equation: vf = (kd*C) / inhibitor_terms
    %
    % Parameters:
    %   kd_C_A_B              - Dissociation rate constant
    %   Ki_C_A_B_INH          - Inhibition constant (for each inhibitor)
    %
    % Example:
    %   dataArray = {'DISSO', 'C', 'A', 'B', '-INH'};
    %   reaction = DissociationReaction('R1', dataArray);

    methods
        function obj = DissociationReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('DISSO', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['DISSO', 'substrate', 'product1', 'product2', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements
            Reaction.validateMinimumElements(charData, 4, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, activators, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrate: C; products: A, B)
            obj.setSpecies({species{2}}, {species{3}, species{4}}, {});

            % Set regulators (no activators for dissociation)
            obj.setRegulators({}, inhibitors);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "C=>A+B:R1"
            procStr = sprintf('%s=>%s+%s:%s', ...
                obj.substrates{1}, obj.products{1}, obj.products{2}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the dissociation rate equation
            % Returns: Rate equation string

            C = obj.substrates{1};
            A = obj.products{1};
            B = obj.products{2};

            % Base reaction: kd_C_A_B * C
            baseParam = sprintf('kd_%s_%s_%s', C, A, B);
            baseReaction = sprintf('%s*%s', baseParam, C);

            % Build inhibitor terms
            if ~isempty(obj.inhibitors)
                ratePart = sprintf('vf = (%s)/(', baseReaction);
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    inhParam = sprintf('Ki_%s_%s_%s_%s', C, A, B, inh);
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

            C = obj.substrates{1};
            A = obj.products{1};
            B = obj.products{2};

            % Base dissociation rate
            params = {sprintf('kd_%s_%s_%s', C, A, B)};

            % Inhibition constants
            for i = 1:length(obj.inhibitors)
                inh = obj.inhibitors{i};
                params{end+1} = sprintf('Ki_%s_%s_%s_%s', C, A, B, inh);
            end
        end
    end
end
