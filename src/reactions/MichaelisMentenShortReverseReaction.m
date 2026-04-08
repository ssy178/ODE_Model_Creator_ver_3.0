classdef MichaelisMentenShortReverseReaction < Reaction
    % MICHAELIEMMENTENSHORTREVERSEACTION Michaelis-Menten (Irreversible, Reverse/Short) reaction: A => B
    %
    % Implements irreversible substrate conversion in reverse direction
    % Uses simple enzyme kinetics without Michaelis constant
    %
    % Reaction form: A => B
    % Rate equation: vf = (Vm*A) / inhibitor_terms
    %
    % Parameters:
    %   Vm_A_B                - Maximum velocity
    %   Ki_A_B_INH            - Inhibition constant (for each inhibitor)
    %
    % Example:
    %   dataArray = {'MMSR', 'A', 'B', '-INH'};
    %   reaction = MichaelisMentenShortReverseReaction('R1', dataArray);

    methods
        function obj = MichaelisMentenShortReverseReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('MMSR', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['MMSR', 'substrate', 'product', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements (only 3 required: type, A, B)
            Reaction.validateMinimumElements(charData, 3, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, ~, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrates: A; products: B)
            obj.setSpecies({species{2}}, {species{3}}, {});

            % Set regulators (no activators for MMSR)
            obj.setRegulators({}, inhibitors);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "A=>B:R1"
            procStr = sprintf('%s=>%s:%s', obj.substrates{1}, obj.products{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the Michaelis-Menten short reverse rate equation
            % Returns: Rate equation string

            A = obj.substrates{1};
            B = obj.products{1};

            % Base reaction: Vm_A_B * A
            baseParam = sprintf('Vm_%s_%s', A, B);
            baseReaction = sprintf('%s*%s', baseParam, A);

            % Build inhibitor terms
            if ~isempty(obj.inhibitors)
                ratePart = sprintf('vf = (%s)/(', baseReaction);
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    inhParam = sprintf('Ki_%s_%s_%s', A, B, inh);
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

            A = obj.substrates{1};
            B = obj.products{1};

            % Base velocity parameter
            params = {sprintf('Vm_%s_%s', A, B)};

            % Inhibition constants
            for i = 1:length(obj.inhibitors)
                inh = obj.inhibitors{i};
                params{end+1} = sprintf('Ki_%s_%s_%s', A, B, inh);
            end
        end
    end
end
