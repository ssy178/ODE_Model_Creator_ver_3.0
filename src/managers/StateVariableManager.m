classdef StateVariableManager < handle
    % STATEVARIABLEMANAGER Manages state variables and initial conditions
    %
    % This class handles:
    %   - Extracting state variables from BiologicalModel
    %   - Removing input signals from state variable list
    %   - Validating state variables against reactions
    %   - Exporting state variable tables to Excel
    %   - Managing initial conditions
    %
    % Properties:
    %   stateVariables  - Containers.Map of StateVariable objects
    %   inputs          - Cell array of input signal names
    %   inhibitors      - Cell array of inhibitor names
    %   outputPath      - Path for exported state variable table
    %
    % Example:
    %   manager = StateVariableManager();
    %   manager.extractFromModel(biologicalModel);
    %   manager.removeInputsFromStates();
    %   manager.validateAgainstReactions();
    %   manager.exportToExcel('output/table_statevariable.xlsx');

    properties
        stateVariables       % Containers.Map of StateVariable objects
        inputs cell = {}     % Input signal names to exclude
        inhibitors cell = {} % Inhibitor names to exclude
        outputPath char = ''
    end

    methods
        function obj = StateVariableManager()
            % Constructor
            % Initializes empty state variable manager

            % Initialize state variables map
            obj.stateVariables = containers.Map('KeyType', 'char', 'ValueType', 'any');
        end

        function extractFromModel(obj, biologicalModel)
            % Extract state variables from BiologicalModel
            % Input:
            %   biologicalModel - BiologicalModel object

            if ~isa(biologicalModel, 'BiologicalModel')
                error('StateVariableManager:InvalidInput', ...
                    'Input must be a BiologicalModel object');
            end

            % Clear existing state variables
            obj.stateVariables = containers.Map('KeyType', 'char', 'ValueType', 'any');

            % Collect all species from reactions
            allSpecies = {};
            for i = 1:length(biologicalModel.reactions)
                reaction = biologicalModel.reactions{i};
                species = reaction.getAllSpecies();
                allSpecies = [allSpecies, species];
            end

            % Get unique species
            uniqueSpecies = unique(allSpecies);

            % Store input and inhibitor names for later removal
            obj.inputs = cellfun(@(x) x.name, biologicalModel.inputs, 'UniformOutput', false);
            obj.inhibitors = cellfun(@(x) x.name, biologicalModel.inhibitors, 'UniformOutput', false);

            % Create StateVariable objects
            for i = 1:length(uniqueSpecies)
                speciesName = uniqueSpecies{i};

                % Skip empty species names
                if isempty(speciesName) || isempty(strtrim(speciesName))
                    continue;
                end

                % Create state variable with initial value of 0
                stateVar = StateVariable(speciesName, 0);

                % Store in map
                obj.stateVariables(speciesName) = stateVar;
            end

            fprintf('Extracted %d unique species from reactions\n', obj.stateVariables.Count);

            % Remove inputs and inhibitors from state variables
            obj.removeInputsFromStates();
        end

        function removeInputsFromStates(obj, inputs, inhibitors)
            % Remove input signals and inhibitors from state variable list
            % Inputs:
            %   inputs     - Cell array of input signal names (optional)
            %   inhibitors - Cell array of inhibitor names (optional)

            if nargin >= 2 && ~isempty(inputs)
                obj.inputs = inputs;
            end

            if nargin >= 3 && ~isempty(inhibitors)
                obj.inhibitors = inhibitors;
            end

            % Remove inputs from state variables
            numRemoved = 0;
            for i = 1:length(obj.inputs)
                inputName = obj.inputs{i};
                if obj.stateVariables.isKey(inputName)
                    obj.stateVariables.remove(inputName);
                    numRemoved = numRemoved + 1;
                end
            end

            % Remove inhibitors from state variables
            for i = 1:length(obj.inhibitors)
                inhibitorName = obj.inhibitors{i};
                if obj.stateVariables.isKey(inhibitorName)
                    obj.stateVariables.remove(inhibitorName);
                    numRemoved = numRemoved + 1;
                end
            end

            if numRemoved > 0
                fprintf('Removed %d inputs/inhibitors from state variables\n', numRemoved);
            end
        end

        function validateAgainstReactions(obj, reactions)
            % Validate state variables against reaction definitions
            % Check for undefined state variables
            % Input:
            %   reactions - Cell array of Reaction objects

            if nargin < 2 || isempty(reactions)
                warning('StateVariableManager:NoReactions', ...
                    'No reactions provided for validation');
                return;
            end

            % Collect all species that appear in reaction process strings
            processSpecies = {};

            for i = 1:length(reactions)
                reaction = reactions{i};

                try
                    % Get process string (e.g., "A+B=>C:R1")
                    procStr = reaction.getProcessString();

                    % Split by delimiters to extract species names
                    % Remove reaction ID (after ':')
                    parts = strsplit(procStr, ':');
                    reactionPart = parts{1};

                    % Split by '+', '=>', '<=>', etc.
                    species = strsplit(reactionPart, {'+', '=>', '<=>', '='});

                    % Clean up and add to list
                    for j = 1:length(species)
                        speciesName = strtrim(species{j});
                        if ~isempty(speciesName)
                            processSpecies{end+1} = speciesName;
                        end
                    end
                catch
                    % If getProcessString fails, try using substrates and products
                    processSpecies = [processSpecies, reaction.substrates, reaction.products];
                end
            end

            % Get unique species from reactions
            processSpecies = unique(processSpecies);

            % Find state variables that don't appear in any reaction
            stateVarNames = obj.stateVariables.keys();
            undefinedStates = {};

            for i = 1:length(stateVarNames)
                stateName = stateVarNames{i};
                if ~ismember(stateName, processSpecies)
                    undefinedStates{end+1} = stateName;
                end
            end

            % Report undefined state variables
            if ~isempty(undefinedStates)
                warning('StateVariableManager:UndefinedStates', ...
                    'Found %d state variables not defined in reactions', ...
                    length(undefinedStates));
                fprintf('Undefined state variables:\n');
                for i = 1:length(undefinedStates)
                    fprintf('  - %s\n', undefinedStates{i});
                end
            else
                fprintf('All state variables are properly defined in reactions\n');
            end
        end

        function exportToExcel(obj, outputFile)
            % Export state variables to Excel file
            % Input:
            %   outputFile - Path to output Excel file

            if nargin >= 2
                obj.outputPath = outputFile;
            end

            if isempty(obj.outputPath)
                error('StateVariableManager:NoOutputPath', ...
                    'No output file path specified');
            end

            % Create table for export
            stateTable = obj.getStateVariableTable();

            % Ensure output directory exists
            [outputDir, ~, ~] = fileparts(obj.outputPath);
            if ~isempty(outputDir) && ~exist(outputDir, 'dir')
                mkdir(outputDir);
            end

            % Write to Excel without variable names (header)
            writetable(stateTable, obj.outputPath, 'WriteVariableNames', false);

            fprintf('State variables exported to: %s\n', obj.outputPath);
        end

        function stateTable = getStateVariableTable(obj)
            % Get state variable table for export
            % Returns: Table with state variable names and initial values

            if obj.stateVariables.Count == 0
                stateTable = table();
                return;
            end

            % Get all state variable names
            stateNames = obj.stateVariables.keys();

            % Sort state variable names alphabetically
            stateNames = sort(stateNames);

            % Create arrays for table
            nameArray = cell(length(stateNames), 1);
            valueArray = zeros(length(stateNames), 1);

            for i = 1:length(stateNames)
                stateName = stateNames{i};
                stateVar = obj.stateVariables(stateName);

                nameArray{i} = stateName;
                valueArray(i) = stateVar.initialValue;
            end

            % Create table
            stateTable = table(nameArray, valueArray);
        end

        function setInitialValue(obj, stateName, value)
            % Set initial value for a state variable
            % Inputs:
            %   stateName - State variable name
            %   value     - Initial value

            if obj.stateVariables.isKey(stateName)
                stateVar = obj.stateVariables(stateName);
                stateVar.initialValue = value;
            else
                warning('StateVariableManager:StateNotFound', ...
                    'State variable not found: %s', stateName);
            end
        end

        function value = getInitialValue(obj, stateName)
            % Get initial value for a state variable
            % Input:
            %   stateName - State variable name
            % Returns:
            %   value - Initial value (or NaN if not found)

            if obj.stateVariables.isKey(stateName)
                stateVar = obj.stateVariables(stateName);
                value = stateVar.initialValue;
            else
                warning('StateVariableManager:StateNotFound', ...
                    'State variable not found: %s', stateName);
                value = NaN;
            end
        end

        function updateFromExcel(obj, excelFile)
            % Update state variable initial values from Excel file
            % Input:
            %   excelFile - Path to Excel file with state variable values

            if ~exist(excelFile, 'file')
                error('StateVariableManager:FileNotFound', ...
                    'Excel file not found: %s', excelFile);
            end

            try
                % Read table
                stateTable = readtable(excelFile, 'ReadVariableNames', false);

                % Track matched and unmatched entries
                numUpdated = 0;
                unmatchedNames = {};
                totalEntries = height(stateTable);

                for i = 1:totalEntries
                    stateName = stateTable{i, 1};
                    stateValue = stateTable{i, 2};

                    % Handle cell array case
                    if iscell(stateName)
                        stateName = stateName{1};
                    end

                    if ischar(stateName) && obj.stateVariables.isKey(stateName)
                        obj.setInitialValue(stateName, stateValue);
                        numUpdated = numUpdated + 1;
                    elseif ischar(stateName) && ~isempty(strtrim(stateName))
                        unmatchedNames{end+1} = stateName;
                    end
                end

                % Calculate matching rate
                if totalEntries > 0
                    matchRate = (numUpdated / totalEntries) * 100;
                else
                    matchRate = 0;
                end

                fprintf('Updated %d/%d state variables from Excel file (%.1f%% match rate)\n', ...
                    numUpdated, totalEntries, matchRate);

                % Display warning if match rate is below 80%
                if matchRate < 80
                    fprintf('\n');
                    fprintf('==========================================================\n');
                    fprintf('  ⚠️  WARNING: LOW MATCH RATE FOR STATE VARIABLE FILE  ⚠️\n');
                    fprintf('==========================================================\n');
                    fprintf('  Match Rate: %.1f%% (Threshold: 80%%)\n', matchRate);
                    fprintf('  Matched: %d, Unmatched: %d, Total in file: %d\n', ...
                        numUpdated, length(unmatchedNames), totalEntries);
                    fprintf('\n');
                    fprintf('  This may indicate you selected the WRONG FILE.\n');
                    fprintf('  Expected: State Variable table (e.g., AKT, NFkB, EGFR)\n');
                    fprintf('  Did you accidentally select a Parameter table instead?\n');
                    fprintf('\n');

                    if ~isempty(unmatchedNames)
                        fprintf('  Unmatched entries from file (first 10):\n');
                        numToShow = min(10, length(unmatchedNames));
                        for i = 1:numToShow
                            fprintf('    - %s\n', unmatchedNames{i});
                        end
                        if length(unmatchedNames) > 10
                            fprintf('    ... and %d more\n', length(unmatchedNames) - 10);
                        end
                    end
                    fprintf('==========================================================\n');
                    fprintf('\n');
                end

            catch ME
                error('StateVariableManager:UpdateError', ...
                    'Error updating from Excel: %s', ME.message);
            end
        end

        function randomizeInitialValues(obj, minVal, maxVal)
            % Randomize initial values for all state variables
            % Inputs:
            %   minVal - Minimum value (default: 0)
            %   maxVal - Maximum value (default: 100)

            if nargin < 2
                minVal = 0;
            end
            if nargin < 3
                maxVal = 100;
            end

            stateNames = obj.stateVariables.keys();
            for i = 1:length(stateNames)
                stateName = stateNames{i};
                randomValue = randi([minVal, maxVal]);
                obj.setInitialValue(stateName, randomValue);
            end

            fprintf('Randomized initial values for %d state variables (Range: %d-%d)\n', ...
                length(stateNames), minVal, maxVal);
        end

        function validateStateVariables(obj)
            % Validate all state variables
            % Checks for invalid names and negative initial values

            stateNames = obj.stateVariables.keys();
            invalidStates = {};

            for i = 1:length(stateNames)
                stateName = stateNames{i};
                stateVar = obj.stateVariables(stateName);

                if ~stateVar.validate()
                    invalidStates{end+1} = stateName;
                end
            end

            if ~isempty(invalidStates)
                warning('StateVariableManager:InvalidStates', ...
                    'Found %d invalid state variables', length(invalidStates));
                fprintf('Invalid state variables:\n');
                for i = 1:length(invalidStates)
                    fprintf('  - %s\n', invalidStates{i});
                end
            else
                fprintf('All state variables are valid\n');
            end
        end

        function printSummary(obj)
            % Print manager summary to console

            fprintf('\n=== State Variable Manager Summary ===\n');
            fprintf('Total State Variables: %d\n', obj.stateVariables.Count);
            fprintf('Excluded Inputs: %d\n', length(obj.inputs));
            fprintf('Excluded Inhibitors: %d\n', length(obj.inhibitors));
            fprintf('Output Path: %s\n', obj.outputPath);

            % Show some statistics
            if obj.stateVariables.Count > 0
                stateNames = obj.stateVariables.keys();
                values = zeros(1, length(stateNames));
                for i = 1:length(stateNames)
                    stateVar = obj.stateVariables(stateNames{i});
                    values(i) = stateVar.initialValue;
                end

                fprintf('\nInitial Value Statistics:\n');
                fprintf('  Num non-zero: %d\n', sum(values ~= 0));
                fprintf('  Min value: %g\n', min(values));
                fprintf('  Max value: %g\n', max(values));
                fprintf('  Mean value: %g\n', mean(values));
            end

            fprintf('======================================\n\n');
        end

        function disp(obj)
            % Display method
            obj.printSummary();
        end
    end
end
