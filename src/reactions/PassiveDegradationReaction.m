classdef PassiveDegradationReaction < Reaction
    % PASSIVEDEGRADATIONREACTION Passive Degradation (Constitutive) reaction: A =>
    %
    % Implements passive (constitutive) protein degradation
    % with optional inhibitors
    %
    % Reaction form: A =>
    % Rate equation: vf = (kdeg*A) / inhibitor_terms
    %
    % Parameters:
    %   kdeg_A                - Degradation rate constant
    %   Ki_deg_A_INH          - Inhibition constant (for each inhibitor)
    %
    % Example:
    %   dataArray = {'DEG0', 'A', '-INH'};
    %   reaction = PassiveDegradationReaction('R1', dataArray);

    methods
        function obj = PassiveDegradationReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('DEG0', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['DEG0', 'substrate', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements (only 2 required: type, substrate)
            Reaction.validateMinimumElements(charData, 2, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, ~, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrates: A; products: none)
            obj.setSpecies({species{2}}, {}, {});

            % Set regulators (no activators for DEG0)
            obj.setRegulators({}, inhibitors);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "A=>:R1"
            procStr = sprintf('%s=>:%s', obj.substrates{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the passive degradation rate equation
            % Returns: Rate equation string

            A = obj.substrates{1};

            % Base reaction: kdeg_A * A
            baseParam = sprintf('kdeg_%s', A);
            baseReaction = sprintf('%s*%s', baseParam, A);

            % Build inhibitor terms
            if ~isempty(obj.inhibitors)
                ratePart = sprintf('vf = (%s)/(', baseReaction);
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    inhParam = sprintf('Ki_deg_%s_%s', A, inh);
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

            % Degradation rate parameter
            params = {sprintf('kdeg_%s', A)};

            % Inhibition constants
            for i = 1:length(obj.inhibitors)
                inh = obj.inhibitors{i};
                params{end+1} = sprintf('Ki_deg_%s_%s', A, inh);
            end
        end
    end
end
