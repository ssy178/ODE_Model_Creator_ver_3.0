classdef TranslocationReaction < Reaction
    % TRANSLOCATIONREACTION Translocation (Bidirectional) reaction: A <=> B
    %
    % Implements reversible translocation between compartments
    %
    % Reaction form: A <=> B
    % Rate equation: vf = (ktrn_A_B*A) / inhibitor_terms - ktrn_B_A*B
    %
    % Parameters:
    %   ktrn_A_B              - Forward translocation rate
    %   ktrn_B_A              - Reverse translocation rate
    %   Ki_trn_A_B_INH        - Inhibition constant (for each inhibitor)
    %
    % Example:
    %   dataArray = {'TRN', 'A', 'B', '-INH'};
    %   reaction = TranslocationReaction('R1', dataArray);

    methods
        function obj = TranslocationReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('TRN', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['TRN', 'substrate', 'product', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements
            Reaction.validateMinimumElements(charData, 3, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, ~, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrates: A; products: B)
            obj.setSpecies({species{2}}, {species{3}}, {});

            % Set regulators (no activators for TRN)
            obj.setRegulators({}, inhibitors);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "A=>B:R1"
            procStr = sprintf('%s=>%s:%s', obj.substrates{1}, obj.products{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the translocation rate equation
            % Returns: Rate equation string

            A = obj.substrates{1};
            B = obj.products{1};

            % Build forward reaction: ktrn_A_B * A
            forwardParam = sprintf('ktrn_%s_%s', A, B);
            forwardReaction = sprintf('%s*%s', forwardParam, A);

            % Build inhibitor terms
            if ~isempty(obj.inhibitors)
                forwardPart = sprintf('vf = (%s)/(', forwardReaction);
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    inhParam = sprintf('Ki_trn_%s_%s_%s', A, B, inh);
                    forwardPart = [forwardPart, sprintf('(1 + %s*%s)*', inhParam, inh)];
                end
                % Replace trailing '*' with ')'
                forwardPart(end) = ')';
            else
                forwardPart = sprintf('vf = %s', forwardReaction);
            end

            % Build reverse reaction: - ktrn_B_A * B
            reverseParam = sprintf('ktrn_%s_%s', B, A);
            reversePart = sprintf(' - %s*%s', reverseParam, B);

            % Combine forward and reverse
            rateEq = [forwardPart, reversePart];
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
