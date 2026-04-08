classdef SynergisticMichaelisMentenShortReaction < Reaction
    % SYNERGISTICMICHAELISMENTENSHORTREACTION Synergistic MM (Short form): A => B
    %
    % Implements substrate conversion where a primary enzyme is facilitated
    % by secondary activators (synergy/cooperation) rather than additive action.
    %
    % Reaction form: A => B
    % Rate equation: vf = (kc*E*A*(1 + sum(kalpha*F))) / inhibitor_terms - Vm*B
    %
    % Parameters:
    %   kc_A_B_E            - Catalytic rate for primary enzyme (E)
    %   kalpha_A_B_E_F      - Synergistic constant for facilitator (F)
    %   Vm_B_A              - Maximum velocity for reverse reaction
    %   Ki_A_B_E_INH        - Inhibition constant (for each inhibitor)
    %
    % Example:
    %   dataArray = {'MMS_SYN', 'A', 'B', '+E', '+F1', '-INH'};
    %   reaction = SynergisticMichaelisMentenShortReaction('R1', dataArray);

    methods
        function obj = SynergisticMichaelisMentenShortReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data
            
            % Call superclass constructor
            obj@Reaction('SYN_MMS', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['SYN_MMS', 'substrate', 'product', '+enzyme', '+facilitator', '-inhibitor', ...]

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate minimum required elements (Type, S, P, +E)
            Reaction.validateMinimumElements(charData, 4, obj.type, str2double(obj.reactionID(2:end)));

            % Parse species, activators, and inhibitors
            [species, activators, inhibitors] = Reaction.parseReactionData(charData);

            % Set species (substrates: A; products: B; modifiers: E)
            % species{4} corresponds to the first modifier/enzyme
            obj.setSpecies({species{2}}, {species{3}}, {species{4}});

            % Set regulators
            obj.setRegulators(activators, inhibitors);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "A=>B:R1"
            procStr = sprintf('%s=>%s:%s', obj.substrates{1}, obj.products{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the Synergistic Michaelis-Menten rate equation
            % Returns: Rate equation string

            A = obj.substrates{1};
            B = obj.products{1};
            E = obj.modifiers{1}; % Primary enzyme (first modifier)

            if isempty(obj.activators)
                error('SynergisticMichaelisMentenShortReaction:NoActivators', ...
                    'MMS_SYN reaction requires at least one primary enzyme (activator)');
            end

            % Primary Enzyme is the first activator
            primaryEnzyme = obj.activators{1};
            
            % 1. Primary catalytic term: kc * E * A
            kcParam = sprintf('kc_%s_%s_%s', A, B, primaryEnzyme);
            baseTerm = sprintf('%s*%s*%s', kcParam, primaryEnzyme, A);

            % 2. Synergy term: prod(1 + kalpha * F)
            synergyFactor = '';
            if length(obj.activators) > 1
                for i = 2:length(obj.activators)
                    fac = obj.activators{i};
                    alphaParam = sprintf('kalpha_%s_%s_%s_%s', A, B, primaryEnzyme, fac);
                    synergyFactor = [synergyFactor, sprintf('*(1 + %s*%s)', alphaParam, fac)];
                end
            end

            % Start building forward part
            forwardPart = sprintf('vf = (%s%s)/(', baseTerm, synergyFactor);

            % 3. Inhibitor terms
            if ~isempty(obj.inhibitors)
                for i = 1:length(obj.inhibitors)
                    inh = obj.inhibitors{i};
                    % Note: naming uses 'E' (primary enzyme) consistent with modifier{1}
                    inhParam = sprintf('Ki_%s_%s_%s_%s', A, B, E, inh);
                    forwardPart = [forwardPart, sprintf('(1 + %s*%s)*', inhParam, inh)];
                end
                % Replace trailing '*' with ')'
                forwardPart(end) = ')';
            else
                % Remove trailing '/('
                forwardPart = forwardPart(1:end-2);
            end

            % 4. Reverse reaction: - Vm_B_A * B
            reverseParam = sprintf('Vm_%s_%s', B, A);
            reversePart = sprintf(' - %s*%s', reverseParam, B);

            % Combine
            rateEq = [forwardPart, reversePart];
        end

        function params = getParameterNames(obj)
            % Get all parameter names for this reaction
            % Returns: Cell array of parameter names

            A = obj.substrates{1};
            B = obj.products{1};
            E = obj.modifiers{1};

            if isempty(obj.activators)
                 params = {};
                 return;
            end

            primaryEnzyme = obj.activators{1};
            params = {};

            % 1. Primary catalytic rate
            params{end+1} = sprintf('kc_%s_%s_%s', A, B, primaryEnzyme);

            % 2. Synergistic constants for facilitators
            if length(obj.activators) > 1
                 for i = 2:length(obj.activators)
                    fac = obj.activators{i};
                    params{end+1} = sprintf('kalpha_%s_%s_%s_%s', A, B, primaryEnzyme, fac);
                 end
            end

            % 3. Reverse reaction velocity
            params{end+1} = sprintf('Vm_%s_%s', B, A);

            % 4. Inhibition constants
            for i = 1:length(obj.inhibitors)
                inh = obj.inhibitors{i};
                params{end+1} = sprintf('Ki_%s_%s_%s_%s', A, B, E, inh);
            end
        end
    end
end
