classdef MassActionReaction < Reaction
    % MASSACTIONREACTION Mass Action (Reversible) reaction: A + B <=> C
    %
    % Implements reversible binding with optional activators and inhibitors
    %
    % Reaction form: A + B <=> C
    % Rate equation: vf = (ka*A*B*(1 + activator_terms)) / inhibitor_terms - kd*C
    %
    % Parameters:
    %   ka_A_B_C              - Forward rate constant
    %   ka_A_B_C_ACT          - Enhanced forward rate (for each activator)
    %   Ki_A_B_C_INH          - Inhibition constant (for each inhibitor)
    %   kd_C_A_B              - Reverse (dissociation) rate constant
    %
    % Example:
    %   dataArray = {'MA', 'A', 'B', 'C', '+ENZ', '-INH'};
    %   reaction = MassActionReaction('R1', dataArray);

    methods
        function obj = MassActionReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('MA', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['MA', 'substrate1', 'substrate2', 'product', '+activator', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements
            Reaction.validateMinimumElements(charData, 4, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, activators, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrates: A, B; product: C; modifier: not used)
            obj.setSpecies({species{2}, species{3}}, {species{4}}, {});

            % Set regulators
            obj.setRegulators(activators, inhibitors);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "A+B=>C:R1" (simplified, reversibility handled in rate equation)
            procStr = sprintf('%s+%s=>%s:%s', ...
                obj.substrates{1}, obj.substrates{2}, obj.products{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the mass action rate equation
            % Returns: Rate equation string

            A = obj.substrates{1};
            B = obj.substrates{2};
            C = obj.products{1};

            % Base forward reaction: ka_A_B_C * A * B
            baseParam = sprintf('ka_%s_%s_%s', A, B, C);
            forwardReaction = sprintf('%s*%s*%s', baseParam, A, B);

            % Build activator enhancement terms
            if ~isempty(obj.activators)
                activatorTerms = '';
                for i = 1:length(obj.activators)
                    act = obj.activators{i};
                    actParam = sprintf('ka_%s_%s_%s_%s', A, B, C, act);
                    activatorTerms = [activatorTerms, sprintf('%s*%s + ', actParam, act)];
                end
                % Remove trailing ' + '
                activatorTerms = activatorTerms(1:end-3);

                forwardPart = sprintf('vf = (%s*( 1 + %s))/(', forwardReaction, activatorTerms);
            else
                forwardPart = sprintf('vf = (%s)/(', forwardReaction);
            end

            % Build inhibitor terms
            if ~isempty(obj.inhibitors)
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    inhParam = sprintf('Ki_%s_%s_%s_%s', A, B, C, inh);
                    forwardPart = [forwardPart, sprintf('(1 + %s*%s)*', inhParam, inh)];
                end
                % Replace trailing '*' with ')'
                forwardPart(end) = ')';
            else
                % Remove trailing '/('
                forwardPart = forwardPart(1:end-2);
            end

            % Build reverse reaction: - kd_C_A_B * C
            reverseParam = sprintf('kd_%s_%s_%s', C, A, B);
            reversePart = sprintf(' - %s*%s', reverseParam, C);

            % Combine forward and reverse
            rateEq = [forwardPart, reversePart];
        end

        function params = getParameterNames(obj)
            % Get all parameter names for this reaction
            % Returns: Cell array of parameter names

            A = obj.substrates{1};
            B = obj.substrates{2};
            C = obj.products{1};

            % Base forward rate
            params = {sprintf('ka_%s_%s_%s', A, B, C)};

            % Activator enhancement rates
            for i = 1:length(obj.activators)
                act = obj.activators{i};
                params{end+1} = sprintf('ka_%s_%s_%s_%s', A, B, C, act);
            end

            % Inhibition constants
            for i = 1:length(obj.inhibitors)
                inh = obj.inhibitors{i};
                params{end+1} = sprintf('Ki_%s_%s_%s_%s', A, B, C, inh);
            end

            % Reverse rate
            params{end+1} = sprintf('kd_%s_%s_%s', C, A, B);
        end
    end
end
