classdef ReactionFactory
    % REACTIONFACTORY Factory class for creating Reaction objects
    %
    % This class creates appropriate Reaction subclass instances based on
    % the reaction type code. It provides a centralized way to instantiate
    % reactions and supports all 18 reaction types.
    %
    % Supported reaction types:
    %   MA    - Mass Action (reversible)
    %   ASSO  - Association (irreversible)
    %   DISSO - Dissociation
    %   MMS   - Michaelis-Menten Short
    %   MMF   - Michaelis-Menten Full
    %   MMSF  - Michaelis-Menten Short with Feedback
    %   MMFF  - Michaelis-Menten Full Feedback
    %   MMSR  - Michaelis-Menten Short Reverse
    %   MMFR  - Michaelis-Menten Full Reverse
    %   SYN0  - Constitutive Synthesis
    %   SYNS  - Simple Synthesis
    %   SYNF  - Regulated Synthesis
    %   DEG0  - Passive Degradation
    %   DEGS  - Simple Degradation
    %   DEGF  - Regulated Degradation
    %   TRN   - Translocation
    %   TRNF  - Regulated Translocation
    %   CAT   - Catalytic
    %
    % Example:
    %   factory = ReactionFactory();
    %   reaction = factory.create('MA', reactionID, dataArray);
    %   types = ReactionFactory.getSupportedTypes();

    methods (Static)
        function reaction = create(reactionType, reactionID, dataArray)
            % Create a Reaction object based on type
            % Inputs:
            %   reactionType - Type code (e.g., 'MA', 'ASSO', 'MMS')
            %   reactionID   - Reaction identifier (e.g., 'R1')
            %   dataArray    - Cell array with reaction data
            % Returns:
            %   reaction - Concrete Reaction subclass instance

            % Get the class name for this reaction type
            className = ReactionFactory.getReactionClassName(reactionType);

            if isempty(className)
                error('ReactionFactory:UnknownType', ...
                    'Unknown reaction type: %s', reactionType);
            end

            % Create instance of the appropriate class
            reaction = feval(className, reactionID, dataArray);
        end

        function className = getReactionClassName(reactionType)
            % Map reaction type code to class name
            % Input: Reaction type code
            % Returns: Class name string

            typeMap = containers.Map(...
                {'MA', 'ASSO', 'DISSO', 'MMS', 'SYN_MMS', 'MMF', 'MMSF', 'MMFF', ...
                 'MMSR', 'MMFR', 'SYN0', 'SYNS', 'SYN_SYNS', 'SYNF', 'SYS0', 'DEG0', 'DEGS', ...
                 'DEGF', 'TRN', 'TRNF', 'CAT'}, ...
                {'MassActionReaction', 'AssociationReaction', 'DissociationReaction', ...
                 'MichaelisMentenShortReaction', 'SynergisticMichaelisMentenShortReaction', 'MichaelisMentenFullReaction', ...
                 'MichaelisMentenShortFeedbackReaction', 'MichaelisMentenFullFeedbackReaction', ...
                 'MichaelisMentenShortReverseReaction', 'MichaelisMentenFullReverseReaction', ...
                 'ConstitutiveSynthesisReaction', 'SimpleSynthesisReaction', 'SynergisticSynthesisReaction', ...
                 'RegulatedSynthesisReaction', 'ConstitutiveSynthesisReaction', 'PassiveDegradationReaction', ...
                 'SimpleDegradationReaction', 'RegulatedDegradationReaction', ...
                 'TranslocationReaction', 'RegulatedTranslocationReaction', ...
                 'CatalyticReaction'});

            if typeMap.isKey(reactionType)
                className = typeMap(reactionType);
            else
                className = '';
            end
        end

        function types = getSupportedTypes()
            % Get list of all supported reaction types
            % Returns: Cell array of reaction type codes

            types = {'MA', 'ASSO', 'DISSO', 'MMS', 'SYN_MMS', 'MMF', 'MMSF', 'MMFF', ...
                     'MMSR', 'MMFR', 'SYN0', 'SYNS', 'SYN_SYNS', 'SYNF', 'SYS0', 'DEG0', 'DEGS', ...
                     'DEGF', 'TRN', 'TRNF', 'CAT'};
        end

        function desc = getTypeDescription(reactionType)
            % Get human-readable description of reaction type
            % Input: Reaction type code
            % Returns: Description string

            descMap = containers.Map(...
                {'MA', 'ASSO', 'DISSO', 'MMS', 'SYN_MMS', 'MMF', 'MMSF', 'MMFF', ...
                 'MMSR', 'MMFR', 'SYN0', 'SYNS', 'SYN_SYNS', 'SYNF', 'SYS0', 'DEG0', 'DEGS', ...
                 'DEGF', 'TRN', 'TRNF', 'CAT'}, ...
                {'Mass Action (Reversible): A + B <=> C', ...
                 'Association (Irreversible): A + B => C', ...
                 'Dissociation: C => A + B', ...
                 'Michaelis-Menten Short (enzyme-activated)', ...
                 'Michaelis-Menten Short Synergistic (Facilitated)', ...
                 'Michaelis-Menten Full (reversible, enzyme-activated)', ...
                 'Michaelis-Menten Short with Feedback', ...
                 'Michaelis-Menten Full Feedback', ...
                 'Michaelis-Menten Short Reverse', ...
                 'Michaelis-Menten Full Reverse', ...
                 'Constitutive Synthesis: => X', ...
                 'Simple Synthesis', ...
                 'Synergistic Synthesis (Template + Driver + Facilitators)', ...
                 'Regulated Synthesis (with activators)', ...
                 'Constitutive Synthesis (SYS0 Alias)', ...
                 'Passive Degradation: X =>', ...
                 'Simple Degradation', ...
                 'Regulated Degradation (with inhibitors)', ...
                 'Translocation: X => X_loc', ...
                 'Regulated Translocation', ...
                 'Catalytic / Gene Expression'});

            if descMap.isKey(reactionType)
                desc = descMap(reactionType);
            else
                desc = 'Unknown reaction type';
            end
        end

        function printSupportedTypes()
            % Print all supported reaction types with descriptions
            types = ReactionFactory.getSupportedTypes();
            fprintf('\nSupported Reaction Types:\n');
            fprintf('========================\n\n');
            for i = 1:length(types)
                desc = ReactionFactory.getTypeDescription(types{i});
                fprintf('  %-6s - %s\n', types{i}, desc);
            end
            fprintf('\n');
        end
    end
end
