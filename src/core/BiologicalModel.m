classdef BiologicalModel < handle
    % BIOLOGICALMODEL Represents a complete biological network model
    %
    % This class encapsulates all components of a biological model:
    %   - Reactions (enzymatic, binding, synthesis, degradation, etc.)
    %   - State variables (species concentrations)
    %   - Parameters (rate constants)
    %   - Input signals (external stimuli)
    %   - Inhibitors (drugs/compounds)
    %   - Readout variables (complex observables)
    %
    % Properties:
    %   name            - Model name
    %   description     - Model description
    %   reactions       - Cell array of Reaction objects
    %   stateVariables  - Containers.Map of StateVariable objects (key: name)
    %   parameters      - Containers.Map of Parameter objects (key: name)
    %   inputs          - Cell array of InputSignal objects
    %   inhibitors      - Cell array of Inhibitor objects
    %   readouts        - Cell array of ReadoutVariable objects
    %   metadata        - Struct with creation date, version, etc.
    %
    % Example:
    %   model = BiologicalModel('FGFR2_model');
    %   model.addReaction(reaction);
    %   model.addInput(InputSignal('FGF', 10, 5000));
    %   model.extractAllStateVariables();
    %   model.extractAllParameters();

    properties
        name char = ''
        description char = ''
        reactions cell = {}
        stateVariables
        parameters
        inputs cell = {}
        inhibitors cell = {}
        readouts cell = {}
        metadata struct
    end

    methods
        function obj = BiologicalModel(name, description)
            % Constructor
            % Inputs:
            %   name        - Model name (required)
            %   description - Model description (optional)

            if nargin >= 1
                obj.name = name;
            end

            if nargin >= 2
                obj.description = description;
            end

            % Initialize containers
            obj.stateVariables = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.parameters = containers.Map('KeyType', 'char', 'ValueType', 'any');

            % Initialize metadata
            obj.metadata = struct();
            obj.metadata.creationDate = datetime('now');
            obj.metadata.version = '3.0.0';
            obj.metadata.numReactions = 0;
        end

        function addReaction(obj, reaction)
            % Add a reaction to the model
            % Input: reaction - Reaction object

            if ~isa(reaction, 'Reaction')
                error('BiologicalModel:InvalidType', ...
                    'Input must be a Reaction object');
            end

            obj.reactions{end+1} = reaction;
            obj.metadata.numReactions = length(obj.reactions);
        end

        function addInput(obj, inputSignal)
            % Add an input signal to the model
            % Input: inputSignal - InputSignal object

            if ~isa(inputSignal, 'InputSignal')
                error('BiologicalModel:InvalidType', ...
                    'Input must be an InputSignal object');
            end

            obj.inputs{end+1} = inputSignal;
        end

        function addInhibitor(obj, inhibitor)
            % Add an inhibitor to the model
            % Input: inhibitor - Inhibitor object

            if ~isa(inhibitor, 'Inhibitor')
                error('BiologicalModel:InvalidType', ...
                    'Input must be an Inhibitor object');
            end

            obj.inhibitors{end+1} = inhibitor;
        end

        function addReadout(obj, readoutVariable)
            % Add a readout variable to the model
            % Input: readoutVariable - ReadoutVariable object

            if ~isa(readoutVariable, 'ReadoutVariable')
                error('BiologicalModel:InvalidType', ...
                    'Input must be a ReadoutVariable object');
            end

            obj.readouts{end+1} = readoutVariable;
        end

        function extractAllStateVariables(obj)
            % Extract all state variables from reactions
            % Automatically identifies unique species and creates StateVariable objects

            allSpecies = {};

            % Collect all species from reactions
            for i = 1:length(obj.reactions)
                species = obj.reactions{i}.getAllSpecies();
                allSpecies = [allSpecies, species];
            end

            % Get unique species
            uniqueSpecies = unique(allSpecies);

            % Remove input signals from state variables
            inputNames = cellfun(@(x) x.name, obj.inputs, 'UniformOutput', false);
            uniqueSpecies = setdiff(uniqueSpecies, inputNames);

            % Remove inhibitors from state variables
            inhibitorNames = cellfun(@(x) x.name, obj.inhibitors, 'UniformOutput', false);
            uniqueSpecies = setdiff(uniqueSpecies, inhibitorNames);

            % Create StateVariable objects
            obj.stateVariables = containers.Map('KeyType', 'char', 'ValueType', 'any');
            for i = 1:length(uniqueSpecies)
                speciesName = uniqueSpecies{i};
                if ~isempty(speciesName) && ~isempty(strtrim(speciesName))
                    obj.stateVariables(speciesName) = StateVariable(speciesName, 0);
                end
            end
        end

        function extractAllParameters(obj)
            % Extract all parameters from reactions
            % Automatically identifies unique parameters and creates Parameter objects

            allParams = {};

            % Collect all parameters from reactions
            for i = 1:length(obj.reactions)
                params = obj.reactions{i}.parameters;
                allParams = [allParams, params];
            end

            % Get unique parameters
            uniqueParams = unique(allParams);

            % Create Parameter objects
            obj.parameters = containers.Map('KeyType', 'char', 'ValueType', 'any');
            for i = 1:length(uniqueParams)
                paramName = uniqueParams{i};
                if ~isempty(paramName) && ~isempty(strtrim(paramName))
                    obj.parameters(paramName) = Parameter(paramName, 1.0);
                end
            end
        end

        function isValid = validate(obj)
            % Validate the biological model
            % Returns: true if valid, false otherwise

            isValid = true;

            % Model must have a name
            if isempty(obj.name)
                warning('BiologicalModel:NoName', 'Model has no name');
                isValid = false;
            end

            % Model must have at least one reaction
            if isempty(obj.reactions)
                warning('BiologicalModel:NoReactions', 'Model has no reactions');
                isValid = false;
            end

            % Validate all reactions
            for i = 1:length(obj.reactions)
                if ~obj.reactions{i}.validate()
                    warning('BiologicalModel:InvalidReaction', ...
                        'Reaction %d is invalid', i);
                    isValid = false;
                end
            end

            % Validate all inputs
            for i = 1:length(obj.inputs)
                if ~obj.inputs{i}.validate()
                    isValid = false;
                end
            end

            % Validate all inhibitors
            for i = 1:length(obj.inhibitors)
                if ~obj.inhibitors{i}.validate()
                    isValid = false;
                end
            end

            % Validate all readouts
            for i = 1:length(obj.readouts)
                if ~obj.readouts{i}.validate()
                    isValid = false;
                end
            end
        end

        function summary = getSummary(obj)
            % Get model summary
            % Returns: Struct with model statistics

            summary = struct();
            summary.name = obj.name;
            summary.description = obj.description;
            summary.numReactions = length(obj.reactions);
            summary.numStateVariables = obj.stateVariables.Count;
            summary.numParameters = obj.parameters.Count;
            summary.numInputs = length(obj.inputs);
            summary.numInhibitors = length(obj.inhibitors);
            summary.numReadouts = length(obj.readouts);
            summary.creationDate = obj.metadata.creationDate;
        end

        function printSummary(obj)
            % Print model summary to console
            fprintf('\n=== Biological Model Summary ===\n');
            fprintf('Name: %s\n', obj.name);
            if ~isempty(obj.description)
                fprintf('Description: %s\n', obj.description);
            end
            fprintf('Reactions: %d\n', length(obj.reactions));
            fprintf('State Variables: %d\n', obj.stateVariables.Count);
            fprintf('Parameters: %d\n', obj.parameters.Count);
            fprintf('Input Signals: %d\n', length(obj.inputs));
            fprintf('Inhibitors: %d\n', length(obj.inhibitors));
            fprintf('Readout Variables: %d\n', length(obj.readouts));
            fprintf('Created: %s\n', datestr(obj.metadata.creationDate));
            fprintf('================================\n\n');
        end

        function disp(obj)
            % Display method
            obj.printSummary();
        end
    end
end
