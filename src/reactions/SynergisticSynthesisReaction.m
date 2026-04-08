classdef SynergisticSynthesisReaction < Reaction
    % SYNERGISTICSYNTHESISREACTION Synergistic Synthesis: => P
    %
    % Implements synthesis where a Template (S) and a Driver (T) work together,
    % facilitated by secondary modifiers (M).
    %
    % Reaction form: => P
    % Rate equation: vf = (ksyn * S * T * (1 + sum(kalpha * M))) / inhibitor_terms
    %
    % The "Substrate" (S) here is treated as a Template (not consumed),
    % typically representing mRNA or a precursor assumed constant/upstream.
    %
    % Interpretation of Activators:
    %   1. First Activator: Template (S)
    %   2. Second Activator: Driver (T)
    %   3. Rest: Facilitators (M)
    %
    % Parameters:
    %   ksyn_P_S_T          - Synthesis rate
    %   kalpha_P_S_T_M      - Synergistic constant for facilitator (M)
    %   Ki_syn_P_T_INH      - Inhibition constant (assuming T is the primary regulated target)
    %
    % Example:
    %   dataArray = {'SYNS_SYN', 'P', '+S', '+T', '+M1', '-INH'};
    %   reaction = SynergisticSynthesisReaction('R1', dataArray);

    methods
        function obj = SynergisticSynthesisReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data
            
            % Call superclass constructor
            obj@Reaction('SYN_SYNS', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['SYN_SYNS', 'product', '+Primary', '+Facilitator1', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements (Type, P, +Primary)
            Reaction.validateMinimumElements(charData, 3, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, activators, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrates: none; products: P; modifiers: none explicit)
            obj.setSpecies({}, {species{2}}, {});

            % Set regulators
            obj.setRegulators(activators, inhibitors);
            
            % Validation for Activators
            if isempty(obj.activators)
                error('SynergisticSynthesisReaction:InsufficientActivators', ...
                    'SYN_SYNS reaction requires at least one primary activator.');
            end
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "=>P:R1"
            procStr = sprintf('=>%s:%s', obj.products{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the Synergistic Synthesis rate equation
            % Returns: Rate equation string

            P = obj.products{1};
            
            % 1. Primary Activator (Driver)
            Primary = obj.activators{1};
            
            % Base term: ksyn * Primary
            ksynParam = sprintf('ksyn_%s_%s', P, Primary);
            rateExp = sprintf('%s*%s', ksynParam, Primary);

            % 2. Facilitators (Secondary Activators)
            % Logic: mulitply by (1 + kalpha * F) for each facilitator
            if length(obj.activators) > 1
                for i = 2:length(obj.activators)
                    Fac = obj.activators{i};
                    alphaParam = sprintf('kalpha_%s_%s_%s', P, Primary, Fac);
                    rateExp = [rateExp, sprintf('*(1 + %s*%s)', alphaParam, Fac)];
                end
            end

            % 3. Inhibitor terms
            forwardPart = sprintf('vf = (%s)', rateExp);
            
            if ~isempty(obj.inhibitors)
                forwardPart = [forwardPart, '/('];
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    inhParam = sprintf('Ki_syn_%s_%s_%s', P, Primary, inh);
                    forwardPart = [forwardPart, sprintf('(1 + %s*%s)*', inhParam, inh)];
                end
                % Replace trailing '*' with ')'
                forwardPart(end) = ')';
            end

            rateEq = forwardPart;
        end

        function params = getParameterNames(obj)
            % Get all parameter names for this reaction
            % Returns: Cell array of parameter names

            P = obj.products{1};
            
            if isempty(obj.activators)
                 params = {};
                 return;
            end

            Primary = obj.activators{1};
            
            params = {};

            % 1. Primary synthesis rate
            params{end+1} = sprintf('ksyn_%s_%s', P, Primary);

            % 2. Synergistic constants for facilitators
            if length(obj.activators) > 1
                 for i = 2:length(obj.activators)
                    Fac = obj.activators{i};
                    params{end+1} = sprintf('kalpha_%s_%s_%s', P, Primary, Fac);
                 end
            end

            % 3. Inhibition constants
            for i = 1:length(obj.inhibitors)
                inh = obj.inhibitors{i};
                params{end+1} = sprintf('Ki_syn_%s_%s_%s', P, Primary, inh);
            end
        end
    end
end
