classdef RegulatedTranslocationReaction < Reaction
    % REGULATEDTRANSLOCATIONREACTION Regulated Translocation reaction: A => B
    %
    % Implements regulated translocation between compartments
    % Includes inhibition control (forward reaction only in this implementation)
    %
    % Reaction form: A => B
    % Rate equation: vf = (ktrn_A_B*A) / inhibitor_terms
    %
    % Parameters:
    %   ktrn_A_B              - Forward translocation rate
    %   ktrn_B_A              - Reverse translocation rate
    %   Ki_trn_A_B_INH        - Inhibition constant (for each inhibitor)
    %
    % Example:
    %   dataArray = {'TRNF', 'A', 'B', '-INH'};
    %   reaction = RegulatedTranslocationReaction('R1', dataArray);

    methods
        function obj = RegulatedTranslocationReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('TRNF', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['TRNF', 'substrate', 'product', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements
            Reaction.validateMinimumElements(charData, 3, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, ~, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrates: A; products: B)
            obj.setSpecies({species{2}}, {species{3}}, {});

            % Set regulators (no activators for TRNF)
            obj.setRegulators({}, inhibitors);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "A=>B:R1"
            procStr = sprintf('%s=>%s:%s', obj.substrates{1}, obj.products{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the regulated translocation rate equation
            % Returns: Rate equation string

            A = obj.substrates{1};
            B = obj.products{1};

            % Build forward reaction: ktrn_A_B * A
            forwardParam = sprintf('ktrn_%s_%s', A, B);
            forwardReaction = sprintf('%s*%s', forwardParam, A);

            % Build inhibitor terms
            if ~isempty(obj.inhibitors)
                ratePart = sprintf('vf = (%s)/(', forwardReaction);
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    inhParam = sprintf('Ki_trn_%s_%s_%s', A, B, inh);
                    ratePart = [ratePart, sprintf('(1 + %s*%s)*', inhParam, inh)];
                end
                % Replace trailing '*' with ')'
                ratePart(end) = ')';
            else
                ratePart = sprintf('vf = %s', forwardReaction);
            end

            rateEq = ratePart;
        end

        function params = getParameterNames(obj)
            % Get all parameter names for this reaction
            % Returns: Cell array of parameter names

            A = obj.substrates{1};
            B = obj.products{1};

            % Forward and reverse translocation rates
            params = {sprintf('ktrn_%s_%s', A, B), sprintf('ktrn_%s_%s', B, A)};

            % Inhibition constants
            for i = 1:length(obj.inhibitors)
                inh = obj.inhibitors{i};
                params{end+1} = sprintf('Ki_trn_%s_%s_%s', A, B, inh);
            end
        end
    end
end
