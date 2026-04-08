classdef ExcelModelReader < handle
    % EXCELMODELREADER Reads and parses Excel input files for ODE models
    %
    % This class reads Excel files containing model definitions and creates
    % BiologicalModel objects. The Excel file must contain the following sheets:
    %   - map       : Reaction definitions
    %   - Input     : Input signals (optional)
    %   - Inhibitor : Inhibitor/drug compounds (optional)
    %   - readout   : Readout variables (optional)
    %
    % Properties:
    %   filePath        - Path to Excel file
    %   rawData         - Struct with raw data from all sheets
    %   mapSheet        - Parsed reaction map data
    %   inputSheet      - Parsed input signals data
    %   inhibitorSheet  - Parsed inhibitors data
    %   readoutSheet    - Parsed readout variables data
    %   modelName       - Name of the model
    %
    % Example:
    %   reader = ExcelModelReader('model.xlsx');
    %   reader.readFile();
    %   model = reader.createModel();

    properties
        filePath char = ''
        rawData struct
        mapSheet cell = {}
        inputSheet cell = {}
        inhibitorSheet cell = {}
        readoutSheet cell = {}
        modelName char = ''
    end

    methods
        function obj = ExcelModelReader(filePath)
            % Constructor
            % Input:
            %   filePath - Path to Excel file (optional)

            if nargin >= 1
                obj.filePath = filePath;
            end

            % Initialize raw data structure
            obj.rawData = struct();
        end

        function readFile(obj, filePath)
            % Read Excel file and load all sheets
            % Input:
            %   filePath - Path to Excel file (optional, uses obj.filePath if not provided)

            if nargin >= 2
                obj.filePath = filePath;
            end

            if isempty(obj.filePath)
                error('ExcelModelReader:NoFile', 'No file path specified');
            end

            if ~exist(obj.filePath, 'file')
                error('ExcelModelReader:FileNotFound', ...
                    'Excel file not found: %s', obj.filePath);
            end

            % Extract model name from file name
            [~, obj.modelName, ~] = fileparts(obj.filePath);

            % Get all sheet names
            sheets = sheetnames(obj.filePath);

            % Check for required sheets
            requiredSheets = {'map'};
            optionalSheets = {'Input', 'Inhibitor', 'readout'};

            % Validate required sheets exist (case-insensitive)
            for i = 1:length(requiredSheets)
                if ~any(strcmpi(sheets, requiredSheets{i}))
                    error('ExcelModelReader:MissingSheet', ...
                        'Required sheet "%s" not found in Excel file', requiredSheets{i});
                end
            end

            % Read required sheets
            obj.mapSheet = readcell(obj.filePath, 'Sheet', 'map');
            obj.rawData.map = obj.mapSheet;

            % Read optional sheets (case-insensitive)
            if any(strcmpi(sheets, 'Input'))
                obj.inputSheet = readcell(obj.filePath, 'Sheet', 'Input');
                obj.rawData.input = obj.inputSheet;
            else
                obj.inputSheet = {};
                obj.rawData.input = {};
            end

            if any(strcmpi(sheets, 'Inhibitor'))
                obj.inhibitorSheet = readcell(obj.filePath, 'Sheet', 'Inhibitor');
                obj.rawData.inhibitor = obj.inhibitorSheet;
            else
                obj.inhibitorSheet = {};
                obj.rawData.inhibitor = {};
            end

            if any(strcmpi(sheets, 'readout'))
                obj.readoutSheet = readcell(obj.filePath, 'Sheet', 'readout');
                obj.rawData.readout = obj.readoutSheet;
            else
                obj.readoutSheet = {};
                obj.rawData.readout = {};
            end

            fprintf('Successfully read Excel file: %s\n', obj.filePath);
            fprintf('  Map sheet: %d reactions\n', size(obj.mapSheet, 1));
            fprintf('  Input sheet: %d inputs\n', size(obj.inputSheet, 1));
            fprintf('  Inhibitor sheet: %d inhibitors\n', size(obj.inhibitorSheet, 1));
            fprintf('  Readout sheet: %d readouts\n', size(obj.readoutSheet, 1));
        end

        function inputs = parseInputSheet(obj)
            % Parse input signals from Input sheet
            % Returns: Cell array of InputSignal objects

            inputs = {};

            if isempty(obj.inputSheet)
                return;
            end

            % Parse each row
            for i = 1:size(obj.inputSheet, 1)
                % Skip if row is empty or all NaN
                if all(cellfun(@(x) isempty(x) || (isnumeric(x) && isnan(x)), obj.inputSheet(i,:)))
                    continue;
                end

                % Extract data
                name = obj.inputSheet{i, 1};

                % Skip if name is empty or not a string
                if isempty(name) || ~ischar(name)
                    continue;
                end

                % Get initial value (default to 0)
                if size(obj.inputSheet, 2) >= 2
                    initialValue = obj.inputSheet{i, 2};
                    if isempty(initialValue) || (isnumeric(initialValue) && isnan(initialValue))
                        initialValue = 0;
                    end
                else
                    initialValue = 0;
                end

                % Get activation time (default to 0)
                if size(obj.inputSheet, 2) >= 3
                    activationTime = obj.inputSheet{i, 3};
                    if isempty(activationTime) || (isnumeric(activationTime) && isnan(activationTime))
                        activationTime = 0;
                    end
                else
                    activationTime = 0;
                end

                % Create InputSignal object
                inputs{end+1} = InputSignal(name, initialValue, activationTime);
            end
        end

        function inhibitors = parseInhibitorSheet(obj)
            % Parse inhibitors from Inhibitor sheet
            % Returns: Cell array of Inhibitor objects

            inhibitors = {};

            if isempty(obj.inhibitorSheet)
                return;
            end

            % Parse each row
            for i = 1:size(obj.inhibitorSheet, 1)
                % Skip if row is empty or all NaN
                if all(cellfun(@(x) isempty(x) || (isnumeric(x) && isnan(x)), obj.inhibitorSheet(i,:)))
                    continue;
                end

                % Extract data
                name = obj.inhibitorSheet{i, 1};

                % Skip if name is empty or not a string
                if isempty(name) || ~ischar(name)
                    continue;
                end

                % Get initial value (default to 0)
                if size(obj.inhibitorSheet, 2) >= 2
                    initialValue = obj.inhibitorSheet{i, 2};
                    if isempty(initialValue) || (isnumeric(initialValue) && isnan(initialValue))
                        initialValue = 0;
                    end
                else
                    initialValue = 0;
                end

                % Get activation time (default to 0)
                if size(obj.inhibitorSheet, 2) >= 3
                    activationTime = obj.inhibitorSheet{i, 3};
                    if isempty(activationTime) || (isnumeric(activationTime) && isnan(activationTime))
                        activationTime = 0;
                    end
                else
                    activationTime = 0;
                end

                % Create Inhibitor object
                inhibitors{end+1} = Inhibitor(name, initialValue, activationTime);
            end
        end

        function readouts = parseReadoutSheet(obj)
            % Parse readout variables from readout sheet
            % Returns: Cell array of ReadoutVariable objects

            readouts = {};

            if isempty(obj.readoutSheet)
                return;
            end

            % Parse each row
            for i = 1:size(obj.readoutSheet, 1)
                % Skip if row is empty or all NaN
                if all(cellfun(@(x) isempty(x) || (isnumeric(x) && isnan(x)), obj.readoutSheet(i,:)))
                    continue;
                end

                % First column is the readout variable name
                name = obj.readoutSheet{i, 1};

                % Skip if name is empty or not a string
                if isempty(name) || ~ischar(name)
                    continue;
                end

                % Remaining columns are component variables
                components = {};
                for j = 2:size(obj.readoutSheet, 2)
                    component = obj.readoutSheet{i, j};
                    % Add if it's a valid string
                    if ~isempty(component) && ischar(component)
                        components{end+1} = component;
                    end
                end

                % Create ReadoutVariable object if there are components
                if ~isempty(components)
                    readouts{end+1} = ReadoutVariable(name, components);
                end
            end
        end

        function reactions = parseMapSheet(obj)
            % Parse reactions from map sheet
            % Returns: Cell array of Reaction objects

            reactions = {};

            if isempty(obj.mapSheet)
                error('ExcelModelReader:NoMapData', 'No reaction map data available');
            end

            % Create reaction factory
            factory = ReactionFactory();

            % Find header row (row containing 'RateEq')
            headerRow = 0;
            rateEqCol = 0;
            noteCol = 0;

            for i = 1:size(obj.mapSheet, 1)
                rowRaw = obj.mapSheet(i, :);
                % Find 'RateEq' column
                idx = find(strcmpi(string(rowRaw), 'RateEq'), 1);
                if ~isempty(idx)
                    headerRow = i;
                    rateEqCol = idx;
                    % Find 'Note' column in the same row
                    noteIdx = find(strcmpi(string(rowRaw), 'Note'), 1);
                    if ~isempty(noteIdx)
                        noteCol = noteIdx;
                    else
                        % If 'Note' not found, assume end of row
                        noteCol = size(obj.mapSheet, 2) + 1;
                    end
                    break;
                end
            end

            if headerRow == 0
                error('ExcelModelReader:NoHeader', 'Could not find "RateEq" header row in map sheet');
            end
            
            fprintf('Found header at row %d. Columns: RateEq=%d, Note=%d\n', headerRow, rateEqCol, noteCol);

            % Parse each row starting after header
            for i = (headerRow + 1):size(obj.mapSheet, 1)
                % Skip if row is empty or all NaN at the RateEq column
                if i > size(obj.mapSheet, 1) || rateEqCol > size(obj.mapSheet, 2) || ...
                   isempty(obj.mapSheet{i, rateEqCol}) || (isnumeric(obj.mapSheet{i, rateEqCol}) && isnan(obj.mapSheet{i, rateEqCol}))
                    continue;
                end

                % Extract data range: RateEq to Note (exclusive)
                endCol = min(noteCol - 1, size(obj.mapSheet, 2));
                if endCol < rateEqCol
                     continue;
                end
                
                rowData = obj.mapSheet(i, rateEqCol:endCol);

                % Clean data:
                % 1. Filter out empty cells / NaNs
                % 2. Remove whitespace from strings
                cleanData = {};
                for j = 1:length(rowData)
                    cellVal = rowData{j};
                    if isempty(cellVal) || (isnumeric(cellVal) && isnan(cellVal))
                        continue;
                    end
                    
                    if ischar(cellVal) || isstring(cellVal)
                        % Remove all whitespace
                        strVal = char(cellVal);
                        strVal = regexprep(strVal, '\s+', '');
                        cleanData{end+1} = strVal;
                    elseif isnumeric(cellVal)
                        cleanData{end+1} = num2str(cellVal);
                    end
                end

                if isempty(cleanData)
                    continue;
                end

                % First element is reaction type
                reactionType = cleanData{1};
                
                % Generate reaction ID
                reactionID = sprintf('R%d', i - headerRow); % ID based on data row number

                try
                    % Create reaction using factory
                    % Pass the cleaned data array (RateEq token is included, logic expects it?)
                    % ReactionFactory passes dataArray to Reaction constructor.
                    % Reaction.parseReactionData expects ['TYPE', 'S1', ...]
                    % So cleanData matches this format.
                    
                    reaction = factory.create(reactionType, reactionID, cleanData);

                    % Build the reaction (generate rate equation and parameters)
                    reaction.build();

                    % Add to reactions list
                    reactions{end+1} = reaction;

                catch ME
                    warning('ExcelModelReader:ReactionError', ...
                        'Error creating reaction at row %d (type: %s): %s', ...
                        i, reactionType, ME.message);
                end
            end

            fprintf('Successfully parsed %d reactions\n', length(reactions));
        end

        function model = createModel(obj)
            % Create BiologicalModel from parsed data
            % Returns: BiologicalModel object

            % Read file if not already done
            if isempty(obj.mapSheet)
                obj.readFile();
            end

            % Create new model
            model = BiologicalModel(obj.modelName);

            % Parse and add reactions
            fprintf('\nParsing reactions...\n');
            reactions = obj.parseMapSheet();
            for i = 1:length(reactions)
                model.addReaction(reactions{i});
            end

            % Parse and add input signals
            fprintf('Parsing input signals...\n');
            inputs = obj.parseInputSheet();
            for i = 1:length(inputs)
                model.addInput(inputs{i});
            end

            % Parse and add inhibitors
            fprintf('Parsing inhibitors...\n');
            inhibitors = obj.parseInhibitorSheet();
            for i = 1:length(inhibitors)
                model.addInhibitor(inhibitors{i});
            end

            % Parse and add readout variables
            fprintf('Parsing readout variables...\n');
            readouts = obj.parseReadoutSheet();
            for i = 1:length(readouts)
                model.addReadout(readouts{i});
            end

            % Extract state variables and parameters
            fprintf('Extracting state variables...\n');
            model.extractAllStateVariables();

            fprintf('Extracting parameters...\n');
            model.extractAllParameters();

            % Print summary
            fprintf('\n');
            model.printSummary();

            fprintf('Model creation complete!\n');
        end

        function isValid = validate(obj)
            % Validate the parsed data
            % Returns: true if valid, false otherwise

            isValid = true;

            % Check file exists
            if ~exist(obj.filePath, 'file')
                warning('ExcelModelReader:NoFile', 'Excel file not found');
                isValid = false;
                return;
            end

            % Check map sheet is not empty
            if isempty(obj.mapSheet)
                warning('ExcelModelReader:NoMapData', 'Map sheet is empty');
                isValid = false;
            end

            % Validate map sheet has at least one valid reaction
            validReactions = 0;
            for i = 1:size(obj.mapSheet, 1)
                if ~all(cellfun(@(x) isempty(x) || (isnumeric(x) && isnan(x)), obj.mapSheet(i,:)))
                    validReactions = validReactions + 1;
                end
            end

            if validReactions == 0
                warning('ExcelModelReader:NoValidReactions', 'No valid reactions found in map sheet');
                isValid = false;
            end
        end

        function printSummary(obj)
            % Print reader summary to console

            fprintf('\n=== Excel Model Reader Summary ===\n');
            fprintf('File: %s\n', obj.filePath);
            fprintf('Model Name: %s\n', obj.modelName);
            fprintf('\nData Loaded:\n');
            fprintf('  Reactions: %d\n', size(obj.mapSheet, 1));
            fprintf('  Inputs: %d\n', size(obj.inputSheet, 1));
            fprintf('  Inhibitors: %d\n', size(obj.inhibitorSheet, 1));
            fprintf('  Readouts: %d\n', size(obj.readoutSheet, 1));
            fprintf('==================================\n\n');
        end

        function disp(obj)
            % Display method
            obj.printSummary();
        end
    end
end
