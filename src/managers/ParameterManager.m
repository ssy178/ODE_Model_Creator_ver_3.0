classdef ParameterManager < handle
    % PARAMETERMANAGER Manages model parameters and default values
    %
    % This class handles:
    %   - Loading default parameter values from Excel file
    %   - Extracting parameters from BiologicalModel
    %   - Assigning default values to parameters
    %   - Exporting parameter tables to Excel
    %   - Validating parameter names and values
    %
    % Properties:
    %   parameters       - Containers.Map of Parameter objects
    %   defaultValues    - Table with default parameter values
    %   defaultFile      - Path to default parameter values file
    %   outputPath       - Path for exported parameter table
    %
    % Example:
    %   manager = ParameterManager('default_parameter_value.xlsx');
    %   manager.loadDefaults();
    %   manager.extractFromModel(biologicalModel);
    %   manager.assignDefaultValues();
    %   manager.exportToExcel('output/table_parameter.xlsx');

    properties
        parameters           % Containers.Map of Parameter objects
        defaultValues table  % Table with default values
        defaultFile char = ''
        outputPath char = ''
    end

    methods
        function obj = ParameterManager(defaultFile)
            % Constructor
            % Input:
            %   defaultFile - Path to default parameter values file (optional)

            % Initialize parameters map
            obj.parameters = containers.Map('KeyType', 'char', 'ValueType', 'any');

            if nargin >= 1
                obj.defaultFile = defaultFile;
            end
        end

        function loadDefaults(obj, defaultFile)
            % Load default parameter values from Excel file
            % Input:
            %   defaultFile - Path to default values file (optional)

            if nargin >= 2
                obj.defaultFile = defaultFile;
            end

            if isempty(obj.defaultFile)
                warning('ParameterManager:NoDefaultFile', ...
                    'No default parameter file specified');
                obj.defaultValues = table();
                return;
            end

            if ~exist(obj.defaultFile, 'file')
                warning('ParameterManager:FileNotFound', ...
                    'Default parameter file not found: %s', obj.defaultFile);
                obj.defaultValues = table();
                return;
            end

            try
                % Read default values from Excel
                rawData = readcell(obj.defaultFile);

                % Create table with parameter prefix and default value
                % Assuming format: [prefix, value]
                paramPrefix = {};
                paramValue = [];

                for i = 1:size(rawData, 1)
                    % Skip empty rows
                    if all(cellfun(@(x) isempty(x) || (isnumeric(x) && isnan(x)), rawData(i,:)))
                        continue;
                    end

                    % Get prefix (first column)
                    prefix = rawData{i, 1};
                    if isempty(prefix) || ~ischar(prefix)
                        continue;
                    end

                    % Get value (second column)
                    if size(rawData, 2) >= 2
                        value = rawData{i, 2};
                        if isempty(value) || (isnumeric(value) && isnan(value))
                            value = 1.0;
                        end
                    else
                        value = 1.0;
                    end

                    paramPrefix{end+1, 1} = prefix;
                    paramValue(end+1, 1) = value;
                end

                % Create table
                obj.defaultValues = table(paramPrefix, paramValue, ...
                    'VariableNames', {'Prefix', 'DefaultValue'});

                fprintf('Loaded %d default parameter values\n', height(obj.defaultValues));

            catch ME
                warning('ParameterManager:LoadError', ...
                    'Error loading default parameter file: %s', ME.message);
                obj.defaultValues = table();
            end
        end

        function extractFromModel(obj, biologicalModel)
            % Extract parameters from BiologicalModel
            % Input:
            %   biologicalModel - BiologicalModel object

            if ~isa(biologicalModel, 'BiologicalModel')
                error('ParameterManager:InvalidInput', ...
                    'Input must be a BiologicalModel object');
            end

            % Clear existing parameters
            obj.parameters = containers.Map('KeyType', 'char', 'ValueType', 'any');

            % Collect all parameters from reactions
            allParams = {};
            for i = 1:length(biologicalModel.reactions)
                reaction = biologicalModel.reactions{i};
                params = reaction.parameters;
                allParams = [allParams, params];
            end

            % Get unique parameters
            uniqueParams = unique(allParams);

            % Create Parameter objects
            for i = 1:length(uniqueParams)
                paramName = uniqueParams{i};

                % Skip empty parameters
                if isempty(paramName) || isempty(strtrim(paramName))
                    continue;
                end

                % Create parameter with default value of 1.0
                param = Parameter(paramName, 1.0);

                % Store in map
                obj.parameters(paramName) = param;
            end

            fprintf('Extracted %d unique parameters from model\n', obj.parameters.Count);
        end

        function assignDefaultValues(obj)
            % Assign default values to parameters based on prefix matching
            % Uses the loaded default values table to match parameter prefixes

            if isempty(obj.defaultValues) || height(obj.defaultValues) == 0
                warning('ParameterManager:NoDefaults', ...
                    'No default values loaded. All parameters will use default value of 1.0');
                return;
            end

            paramNames = obj.parameters.keys();
            numAssigned = 0;

            for i = 1:length(paramNames)
                paramName = paramNames{i};
                param = obj.parameters(paramName);

                % Check each default value prefix
                for j = 1:height(obj.defaultValues)
                    prefix = obj.defaultValues.Prefix{j};
                    defaultVal = obj.defaultValues.DefaultValue(j);

                    % Check if parameter name starts with this prefix
                    if startsWith(paramName, prefix)
                        param.setDefaultValue(defaultVal);
                        param.value = defaultVal;
                        numAssigned = numAssigned + 1;
                        break;
                    end
                end
            end

            fprintf('Assigned default values to %d/%d parameters\n', ...
                numAssigned, obj.parameters.Count);
        end

        function exportToExcel(obj, outputFile)
            % Export parameters to Excel file
            % Input:
            %   outputFile - Path to output Excel file

            if nargin >= 2
                obj.outputPath = outputFile;
            end

            if isempty(obj.outputPath)
                error('ParameterManager:NoOutputPath', ...
                    'No output file path specified');
            end

            % Create table for export
            paramTable = obj.getParameterTable();

            % Ensure output directory exists
            [outputDir, ~, ~] = fileparts(obj.outputPath);
            if ~isempty(outputDir) && ~exist(outputDir, 'dir')
                mkdir(outputDir);
            end

            % Write to Excel without variable names (header)
            writetable(paramTable, obj.outputPath, 'WriteVariableNames', false);

            fprintf('Parameters exported to: %s\n', obj.outputPath);
        end

        function paramTable = getParameterTable(obj)
            % Get parameter table for export
            % Returns: Table with parameter names and values

            if obj.parameters.Count == 0
                paramTable = table();
                return;
            end

            % Get all parameter names
            paramNames = obj.parameters.keys();

            % Sort parameter names alphabetically
            paramNames = sort(paramNames);

            % Create arrays for table
            nameArray = cell(length(paramNames), 1);
            valueArray = zeros(length(paramNames), 1);

            for i = 1:length(paramNames)
                paramName = paramNames{i};
                param = obj.parameters(paramName);

                nameArray{i} = paramName;
                valueArray(i) = param.value;
            end

            % Create table
            paramTable = table(nameArray, valueArray);
        end

        function validateParameterNames(obj)
            % Validate all parameter names
            % Checks for invalid characters and naming conventions

            paramNames = obj.parameters.keys();
            invalidNames = {};

            for i = 1:length(paramNames)
                paramName = paramNames{i};
                param = obj.parameters(paramName);

                if ~param.validate()
                    invalidNames{end+1} = paramName;
                end
            end

            if ~isempty(invalidNames)
                warning('ParameterManager:InvalidNames', ...
                    'Found %d invalid parameter names', length(invalidNames));
                fprintf('Invalid parameters:\n');
                for i = 1:length(invalidNames)
                    fprintf('  - %s\n', invalidNames{i});
                end
            else
                fprintf('All parameter names are valid\n');
            end
        end

        function setParameter(obj, paramName, value)
            % Set parameter value
            % Inputs:
            %   paramName - Parameter name
            %   value     - Parameter value

            if obj.parameters.isKey(paramName)
                param = obj.parameters(paramName);
                param.value = value;
            else
                warning('ParameterManager:ParamNotFound', ...
                    'Parameter not found: %s', paramName);
            end
        end

        function value = getParameter(obj, paramName)
            % Get parameter value
            % Input:
            %   paramName - Parameter name
            % Returns:
            %   value - Parameter value (or NaN if not found)

            if obj.parameters.isKey(paramName)
                param = obj.parameters(paramName);
                value = param.value;
            else
                warning('ParameterManager:ParamNotFound', ...
                    'Parameter not found: %s', paramName);
                value = NaN;
            end
        end

        function updateFromExcel(obj, excelFile)
            % Update parameter values from Excel file
            % Input:
            %   excelFile - Path to Excel file with parameter values

            if ~exist(excelFile, 'file')
                error('ParameterManager:FileNotFound', ...
                    'Excel file not found: %s', excelFile);
            end

            try
                % Read table
                paramTable = readtable(excelFile, 'ReadVariableNames', false);

                % Track matched and unmatched entries
                numUpdated = 0;
                unmatchedNames = {};
                totalEntries = height(paramTable);

                for i = 1:totalEntries
                    paramName = paramTable{i, 1};
                    paramValue = paramTable{i, 2};

                    % Handle cell array case
                    if iscell(paramName)
                        paramName = paramName{1};
                    end

                    if ischar(paramName) && obj.parameters.isKey(paramName)
                        obj.setParameter(paramName, paramValue);
                        numUpdated = numUpdated + 1;
                    elseif ischar(paramName) && ~isempty(strtrim(paramName))
                        unmatchedNames{end+1} = paramName;
                    end
                end

                % Calculate matching rate
                if totalEntries > 0
                    matchRate = (numUpdated / totalEntries) * 100;
                else
                    matchRate = 0;
                end

                fprintf('Updated %d/%d parameters from Excel file (%.1f%% match rate)\n', ...
                    numUpdated, totalEntries, matchRate);

                % Display warning if match rate is below 80%
                if matchRate < 80
                    fprintf('\n');
                    fprintf('==========================================================\n');
                    fprintf('  ⚠️  WARNING: LOW MATCH RATE FOR PARAMETER FILE  ⚠️\n');
                    fprintf('==========================================================\n');
                    fprintf('  Match Rate: %.1f%% (Threshold: 80%%)\n', matchRate);
                    fprintf('  Matched: %d, Unmatched: %d, Total in file: %d\n', ...
                        numUpdated, length(unmatchedNames), totalEntries);
                    fprintf('\n');
                    fprintf('  This may indicate you selected the WRONG FILE.\n');
                    fprintf('  Expected: Parameter table (e.g., kc_*, kdeg_*, Vm_*)\n');
                    fprintf('  Did you accidentally select a State Variable table instead?\n');
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
                error('ParameterManager:UpdateError', ...
                    'Error updating from Excel: %s', ME.message);
            end
        end

        function printSummary(obj)
            % Print manager summary to console

            fprintf('\n=== Parameter Manager Summary ===\n');
            fprintf('Total Parameters: %d\n', obj.parameters.Count);
            fprintf('Default Values File: %s\n', obj.defaultFile);
            fprintf('Output Path: %s\n', obj.outputPath);

            if ~isempty(obj.defaultValues) && height(obj.defaultValues) > 0
                fprintf('Default Value Rules: %d\n', height(obj.defaultValues));
            end

            % Show some statistics
            if obj.parameters.Count > 0
                paramNames = obj.parameters.keys();
                values = zeros(1, length(paramNames));
                for i = 1:length(paramNames)
                    param = obj.parameters(paramNames{i});
                    values(i) = param.value;
                end

                fprintf('\nParameter Statistics:\n');
                fprintf('  Min value: %g\n', min(values));
                fprintf('  Max value: %g\n', max(values));
                fprintf('  Mean value: %g\n', mean(values));
                fprintf('  Median value: %g\n', median(values));
            end

            fprintf('=================================\n\n');
        end

        function disp(obj)
            % Display method
            obj.printSummary();
        end
    end
end
