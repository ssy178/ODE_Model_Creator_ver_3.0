classdef AssociationReaction < Reaction
    % ASSOCIATIONREACTION Association (Irreversible) reaction: A + B => C
    %
    % Implements irreversible binding with optional activators and inhibitors
    %
    % Reaction form: A + B => C
    % Rate equation: vf = (ka*A*B*(1 + activator_terms)) / inhibitor_terms
    %
    % Parameters:
    %   ka_A_B_C              - Association rate constant
    %   ka_A_B_C_ACT          - Enhanced association rate (for each activator)
    %   Ki_A_B_C_INH          - Inhibition constant (for each inhibitor)
    %
    % Example:
    %   dataArray = {'ASSO', 'A', 'B', 'C', '+ENZ'};
    %   reaction = AssociationReaction('R1', dataArray);

    methods
        function obj = AssociationReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('ASSO', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['ASSO', 'substrate1', 'substrate2', 'product', '+activator', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements
            Reaction.validateMinimumElements(charData, 4, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, activators, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrates: A, B; product: C)
            obj.setSpecies({species{2}, species{3}}, {species{4}}, {});

            % Set regulators
            obj.setRegulators(activators, inhibitors);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "A+B=>C:R1"
            procStr = sprintf('%s+%s=>%s:%s', ...
                obj.substrates{1}, obj.substrates{2}, obj.products{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the association rate equation
            % Returns: Rate equation string

            A = obj.substrates{1};
            B = obj.substrates{2};
            C = obj.products{1};

            % Base reaction: ka_A_B_C * A * B
            baseParam = sprintf('ka_%s_%s_%s', A, B, C);
            baseReaction = sprintf('%s*%s*%s', baseParam, A, B);

            % Build activator enhancement terms
            if ~isempty(obj.activators)
                activatorTerms = '';
                for i = 1:length(obj.activators)
                    act = obj.activators{i};
                    actParam = sprintf('ka_%s_%s_%s_%s', A, B, C, act);
                    activatorTerms = [activatorTerms, sprintf('%s*%s+', actParam, act)];
                end
                % Remove trailing '+'
                activatorTerms = activatorTerms(1:end-1);

                ratePart = sprintf('vf = (%s*( 1 + %s))/(', baseReaction, activatorTerms);
            else
                ratePart = sprintf('vf = (%s)/(', baseReaction);
            end

            % Build inhibitor terms
            if ~isempty(obj.inhibitors)
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    inhParam = sprintf('Ki_%s_%s_%s_%s', A, B, C, inh);
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
            B = obj.substrates{2};
            C = obj.products{1};

            % Base association rate
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
        end
    end
end
