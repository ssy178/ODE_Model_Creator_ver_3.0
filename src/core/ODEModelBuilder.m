classdef ODEModelBuilder < handle
    % ODEMODELBUILDER Main facade class that orchestrates the entire ODE model creation workflow
    %
    % This class provides a high-level interface to:
    %   - Load Excel model files
    %   - Generate rate equations for all reactions
    %   - Validate the biological model
    %   - Export parameter and state variable tables
    %   - Export to IQM format
    %   - Generate ODE and MEX files
    %   - Run complete pipeline
    %
    % Properties:
    %   config        - ModelConfiguration object
    %   model         - BiologicalModel object
    %   reader        - ExcelModelReader object
    %   factory       - ReactionFactory object
    %   paramManager  - ParameterManager object
    %   stateManager  - StateVariableManager object
    %   exporter      - IQMExporter object
    %
    % Example:
    %   % Quick start - run full pipeline
    %   builder = ODEModelBuilder();
    %   builder.runFullPipeline('model.xlsx', 'output/model_name');
    %
    %   % Step-by-step control
    %   builder = ODEModelBuilder();
    %   builder.loadModel('model.xlsx');
    %   builder.generateRateEquations();
    %   builder.validateModel();
    %   builder.exportParameterTable('output/table_parameter.xlsx');
    %   builder.exportStateVariableTable('output/table_statevariable.xlsx');
    %   builder.exportToIQM('output/model.txtbc');

    properties
        config          % ModelConfiguration object
        model           % BiologicalModel object
        reader          % ExcelModelReader object
        factory         % ReactionFactory object
        paramManager    % ParameterManager object
        stateManager    % StateVariableManager object
        exporter        % IQMExporter object
    end

    methods
        function obj = ODEModelBuilder(config)
            % Constructor
            % Input:
            %   config - ModelConfiguration object or config file path (optional)

            % Initialize configuration
            if nargin == 0 || isempty(config)
                % Create default configuration
                obj.config = ModelConfiguration();
                obj.config.setDefaultPaths();
            elseif isa(config, 'ModelConfiguration')
                % Use provided configuration object
                obj.config = config;
            elseif ischar(config)
                % Load configuration from file
                obj.config = ModelConfiguration();
                obj.config.loadFromFile(config);
            else
                error('ODEModelBuilder:InvalidConfig', ...
                    'Config must be ModelConfiguration object or file path');
            end

            % Initialize components
            obj.factory = ReactionFactory();

            % Initialize managers (will be set up when model is loaded)
            obj.paramManager = [];
            obj.stateManager = [];
            obj.exporter = [];

            fprintf('ODE Model Builder initialized\n');
        end

        function loadModel(obj, excelFile, modelName)
            % Load model from Excel file
            % Inputs:
            %   excelFile - Path to Excel file
            %   modelName - Custom model name (optional, uses filename if not provided)

            fprintf('\n=== Loading Model from Excel ===\n\n');

            % Create reader
            obj.reader = ExcelModelReader(excelFile);

            % Read file and create model
            obj.reader.readFile();
            obj.model = obj.reader.createModel();

            % Override model name if provided
            if nargin >= 3 && ~isempty(modelName)
                obj.model.name = modelName;
            end

            fprintf('\n=== Model Loaded Successfully ===\n\n');
        end

        function generateRateEquations(obj)
            % Generate rate equations for all reactions
            % This is automatically done during model loading, but can be called again if needed

            if isempty(obj.model)
                error('ODEModelBuilder:NoModel', 'No model loaded. Call loadModel() first.');
            end

            fprintf('\n=== Generating Rate Equations ===\n\n');

            % Regenerate rate equations for all reactions
            for i = 1:length(obj.model.reactions)
                reaction = obj.model.reactions{i};
                reaction.build();
            end

            % Re-extract parameters and state variables
            obj.model.extractAllParameters();
            obj.model.extractAllStateVariables();

            fprintf('Rate equations generated for %d reactions\n', length(obj.model.reactions));
            fprintf('\n=== Rate Equations Complete ===\n\n');
        end

        function isValid = validateModel(obj)
            % Validate the biological model
            % Returns: true if valid, false otherwise

            if isempty(obj.model)
                error('ODEModelBuilder:NoModel', 'No model loaded. Call loadModel() first.');
            end

            fprintf('\n=== Validating Model ===\n\n');

            isValid = obj.model.validate();

            if isValid
                fprintf('Model validation: PASSED\n');
            else
                fprintf('Model validation: FAILED\n');
            end

            fprintf('\n=== Validation Complete ===\n\n');
        end

        function exportParameterTable(obj, outputFile, options)
            % Export parameter table to Excel
            % Input:
            %   outputFile - Path to output Excel file (optional)
            %   options    - Struct with parameter options (optional)
            %                .parameterValueMode ('default', 'file')
            %                .parameterValueFile (path to file)

            if isempty(obj.model)
                error('ODEModelBuilder:NoModel', 'No model loaded. Call loadModel() first.');
            end

            fprintf('\n=== Exporting Parameter Table ===\n\n');

            % Parse options
            if nargin < 3
                options = struct();
            end
            if ~isfield(options, 'parameterValueMode')
                options.parameterValueMode = 'default';
            end

            % Create parameter manager if not exists
            if isempty(obj.paramManager)
                obj.paramManager = ParameterManager(obj.config.defaultParamFile);
                obj.paramManager.loadDefaults();
            end

            % Extract parameters from model
            obj.paramManager.extractFromModel(obj.model);

            % Assign default values first
            obj.paramManager.assignDefaultValues();

            % Apply user parameter file if provided
            if strcmpi(options.parameterValueMode, 'file')
                if isfield(options, 'parameterValueFile') && ~isempty(options.parameterValueFile)
                    fprintf('Loading parameter values from: %s\n', options.parameterValueFile);
                    if exist(options.parameterValueFile, 'file')
                        obj.paramManager.updateFromExcel(options.parameterValueFile);
                    else
                        warning('ODEModelBuilder:ParamFileDiff', 'Parameter value file not found. Using defaults.');
                    end
                end
            end

            % Determine output file path
            if nargin < 2 || isempty(outputFile)
                % Use model directory
                modelDir = obj.getModelOutputDir();
                outputFile = fullfile(modelDir, 'table_parameter.xlsx');
            end

            % Export to Excel
            obj.paramManager.exportToExcel(outputFile);

            fprintf('\n=== Parameter Table Export Complete ===\n\n');
        end

        function exportStateVariableTable(obj, outputFile, options)
            % Export state variable table to Excel
            % Input:
            %   outputFile - Path to output Excel file (optional)
            %   options    - Struct with initialization options (optional)
            %                .initialValueMode ('default', 'file', 'random')
            %                .initialValueFile (path to file)
            %                .randomRange ([min max])

            if isempty(obj.model)
                error('ODEModelBuilder:NoModel', 'No model loaded. Call loadModel() first.');
            end

            fprintf('\n=== Exporting State Variable Table ===\n\n');

            % Parse options
            if nargin < 3
                options = struct();
            end
            if ~isfield(options, 'initialValueMode')
                options.initialValueMode = 'default';
            end

            % Create state variable manager if not exists
            if isempty(obj.stateManager)
                obj.stateManager = StateVariableManager();
            end

            % Extract state variables from model (resets everything to 0)
            obj.stateManager.extractFromModel(obj.model);

            % Validate against reactions
            obj.stateManager.validateAgainstReactions(obj.model.reactions);

            % Apply initialization logic based on options
            switch lower(options.initialValueMode)
                case 'file'
                    if isfield(options, 'initialValueFile') && ~isempty(options.initialValueFile)
                        fprintf('Loading initial values from: %s\n', options.initialValueFile);
                        if exist(options.initialValueFile, 'file')
                            obj.stateManager.updateFromExcel(options.initialValueFile);
                        else
                            warning('ODEModelBuilder:InitFileDiff', 'Initial value file not found. using defaults.');
                        end
                    end
                case 'random'
                    minVal = 0; maxVal = 100;
                    if isfield(options, 'randomRange') && length(options.randomRange) == 2
                        minVal = options.randomRange(1);
                        maxVal = options.randomRange(2);
                    end
                    obj.stateManager.randomizeInitialValues(minVal, maxVal);
                otherwise
                    % 'default' (0) - already set by extractFromModel
            end

            % Determine output file path
            if nargin < 2 || isempty(outputFile)
                % Use model directory
                modelDir = obj.getModelOutputDir();
                outputFile = fullfile(modelDir, 'table_statevariable.xlsx');
            end

            % Export to Excel
            obj.stateManager.exportToExcel(outputFile);

            fprintf('\n=== State Variable Table Export Complete ===\n\n');
        end

        function exportToIQM(obj, outputFile)
            % Export model to IQM txtbc format
            % Input:
            %   outputFile - Path to output txtbc file (optional)

            if isempty(obj.model)
                error('ODEModelBuilder:NoModel', 'No model loaded. Call loadModel() first.');
            end

            fprintf('\n=== Exporting to IQM Format ===\n\n');

            % Determine output directory and file
            if nargin < 2 || isempty(outputFile)
                modelDir = obj.getModelOutputDir();
                outputFile = fullfile(modelDir, sprintf('%s.txtbc', obj.model.name));
            end

            % Get output directory
            [outputDir, ~, ~] = fileparts(outputFile);

            % Create exporter if not exists
            if isempty(obj.exporter)
                obj.exporter = IQMExporter(obj.model, outputDir);
            else
                obj.exporter.model = obj.model;
                obj.exporter.outputDir = outputDir;
            end

            % Load parameter and state variable tables
            modelDir = obj.getModelOutputDir();
            paramFile = fullfile(modelDir, 'table_parameter.xlsx');
            stateFile = fullfile(modelDir, 'table_statevariable.xlsx');

            if exist(paramFile, 'file')
                obj.exporter.loadParameterTable(paramFile);
            else
                warning('ODEModelBuilder:NoParamTable', ...
                    'Parameter table not found: %s\nUsing default values.', paramFile);
                % Create default parameter table
                obj.exportParameterTable(paramFile);
                obj.exporter.loadParameterTable(paramFile);
            end

            if exist(stateFile, 'file')
                obj.exporter.loadStateVariableTable(stateFile);
            else
                warning('ODEModelBuilder:NoStateTable', ...
                    'State variable table not found: %s\nUsing default values.', stateFile);
                % Create default state variable table
                obj.exportStateVariableTable(stateFile);
                obj.exporter.loadStateVariableTable(stateFile);
            end

            % Export to txtbc
            obj.exporter.exportToTxtbc(outputFile);

            fprintf('\n=== IQM Export Complete ===\n\n');
        end

        function generateODEFile(obj, outputFile)
            % Generate ODE m-file from model
            % Input:
            %   outputFile - Path to output ODE file (without extension) (optional)

            if isempty(obj.exporter)
                error('ODEModelBuilder:NoExporter', ...
                    'Model not exported to IQM yet. Call exportToIQM() first.');
            end

            fprintf('\n=== Generating ODE File ===\n\n');

            % Determine output file
            if nargin < 2 || isempty(outputFile)
                modelDir = obj.getModelOutputDir();
                outputFile = fullfile(modelDir, sprintf('%s_ode', obj.model.name));
            end

            % Generate ODE file
            obj.exporter.generateODEFile(outputFile);

            fprintf('\n=== ODE File Generation Complete ===\n\n');
        end

        function compileMEX(obj, outputFile)
            % Compile MEX file from model
            % Input:
            %   outputFile - Path to output MEX file (without extension) (optional)

            if isempty(obj.exporter)
                error('ODEModelBuilder:NoExporter', ...
                    'Model not exported to IQM yet. Call exportToIQM() first.');
            end

            fprintf('\n=== Compiling MEX File ===\n\n');

            % Determine output file
            if nargin < 2 || isempty(outputFile)
                modelDir = obj.getModelOutputDir();
                outputFile = fullfile(modelDir, sprintf('%s_mex', obj.model.name));
            end

            % Compile MEX file
            obj.exporter.compileMEX(outputFile);

            fprintf('\n=== MEX Compilation Complete ===\n\n');
        end

        function generateStandardODEFile(obj, outputFile)
            % Generate MATLAB standard ODE solver compatible m-file
            % This file can be used directly with ode15s, ode45, ode23, etc.
            %
            % Input:
            %   outputFile - Path to output file (without extension) (optional)
            %
            % Example usage of generated file:
            %   p = model_ode_std('parameters');
            %   y0 = model_ode_std('initialvalues');
            %   [t, y] = ode15s(@(t,y) model_ode_std(t, y, p), [0 1000], y0);

            if isempty(obj.exporter)
                error('ODEModelBuilder:NoExporter', ...
                    'Model not exported to IQM yet. Call exportToIQM() first.');
            end

            fprintf('\n=== Generating Standard ODE File ===\n\n');

            % Determine output file
            if nargin < 2 || isempty(outputFile)
                modelDir = obj.getModelOutputDir();
                outputFile = fullfile(modelDir, sprintf('%s_ode_std', obj.model.name));
            end

            % Generate standard ODE file
            obj.exporter.generateStandardODEFile(outputFile);

            fprintf('\n=== Standard ODE File Generation Complete ===\n\n');;
        end

        function runFullPipeline(obj, excelFile, outputDir, options)
            % Run complete pipeline from Excel to IQM/ODE/MEX
            % Inputs:
            %   excelFile - Path to Excel input file
            %   outputDir - Output directory path (optional)
            %   options   - Struct with options (optional)
            %               .compileMEX (default: false)
            %               .validateModel (default: true)

            fprintf('\n');
            fprintf('================================================\n');
            fprintf('  ODE Model Creator - Full Pipeline\n');
            fprintf('================================================\n');
            fprintf('\n');

            % Parse options
            if nargin < 4
                options = struct();
            end
            if ~isfield(options, 'compileMEX')
                options.compileMEX = false;
            end
            if ~isfield(options, 'validateModel')
                options.validateModel = true;
            end

            % Set output directory if provided
            if nargin >= 3 && ~isempty(outputDir)
                obj.config.setPath('outputDir', outputDir);
            end

            % Step 1: Load model from Excel
            obj.loadModel(excelFile);

            % Step 2: Generate rate equations (already done in loadModel, but ensure it's done)
            obj.generateRateEquations();

            % Step 3: Validate model (optional)
            if options.validateModel
                isValid = obj.validateModel();
                if ~isValid && obj.config.getOption('verbose')
                    warning('ODEModelBuilder:ValidationFailed', ...
                        'Model validation failed but continuing...');
                end
            end

            % Step 4: Export parameter table
            obj.exportParameterTable([], options);

            % Step 5: Export state variable table
            obj.exportStateVariableTable([], options);

            % Display message for user to edit tables
            fprintf('\n');
            fprintf('================================================\n');
            fprintf('  IMPORTANT: Review and Edit Tables\n');
            fprintf('================================================\n');
            fprintf('\n');
            fprintf('The following tables have been generated:\n');
            modelDir = obj.getModelOutputDir();
            fprintf('  1. Parameter table: %s\n', fullfile(modelDir, 'table_parameter.xlsx'));
            fprintf('  2. State variable table: %s\n', fullfile(modelDir, 'table_statevariable.xlsx'));
            fprintf('\n');
            fprintf('Please review and edit these tables as needed.\n');
            fprintf('Then press any key to continue with IQM export...\n');
            fprintf('\n');

            % Wait for user confirmation
            pause;

            % Step 6: Export to IQM format
            obj.exportToIQM();

            % Step 7: Ask user if they want to generate ODE and MEX files
            fprintf('\n');
            fprintf('================================================\n');
            fprintf('  IQMtools Processing Options\n');
            fprintf('================================================\n');
            fprintf('\n');
            fprintf('The txtbc file has been successfully generated.\n');
            fprintf('Would you like to use IQMtools to generate:\n');
            fprintf('  1. ODE m-file (MATLAB function for simulation)\n');
            fprintf('  2. MEX file (compiled for faster simulation)\n');
            fprintf('\n');

            % Check if IQMtools is available
            iqmAvailable = exist('IQMmodel', 'file') == 2;

            % If not available, try to initialize it
            if ~iqmAvailable
                fprintf('IQMtools not currently on MATLAB path.\n');
                fprintf('Attempting to detect and initialize IQMtools...\n\n');

                % Try to initialize IQMtools automatically
                success = obj.config.initializeIQMtools();

                if success
                    fprintf('SUCCESS: IQMtools initialized successfully!\n');
                    iqmAvailable = true;
                else
                    % Auto-initialization failed, provide manual options
                    fprintf('\nWARNING: Could not automatically initialize IQMtools.\n');
                    fprintf('\nIf you have IQMtools installed, please choose an option:\n');
                    fprintf('  1. Manually specify IQMtools installation path\n');
                    fprintf('  2. Use default path: C:\\IQMtools V1.2.2.2\\installIQMtools.m\n');
                    fprintf('  3. Skip IQMtools initialization (txtbc file only)\n');
                    fprintf('\n');

                    % Get user choice
                    choice = input('Enter your choice (1/2/3): ', 's');

                    if strcmp(choice, '1')
                        % Option 1: Manual path entry
                        fprintf('\nPlease enter the full path to your IQMtools installation directory.\n');
                        fprintf('Example: C:\\IQMtools V1.2.2.2\n');
                        iqmPath = input('IQMtools path: ', 's');

                        if ~isempty(iqmPath) && exist(iqmPath, 'dir')
                            obj.config.iqmToolsPath = iqmPath;
                            success = obj.config.initializeIQMtools();
                            if success
                                fprintf('\nSUCCESS: IQMtools initialized from: %s\n', iqmPath);
                                iqmAvailable = true;
                            else
                                fprintf('\nERROR: Failed to initialize IQMtools from: %s\n', iqmPath);
                                fprintf('Please check that installIQMtools.m exists in this directory.\n');
                            end
                        else
                            fprintf('\nERROR: Invalid path: %s\n', iqmPath);
                        end

                    elseif strcmp(choice, '2')
                        % Option 2: Use default path
                        defaultPath = 'C:\IQMtools V1.2.2.2';
                        fprintf('\nAttempting to initialize IQMtools from: %s\n', defaultPath);

                        if exist(defaultPath, 'dir')
                            obj.config.iqmToolsPath = defaultPath;
                            success = obj.config.initializeIQMtools();
                            if success
                                fprintf('\nSUCCESS: IQMtools initialized from default path!\n');
                                iqmAvailable = true;
                            else
                                fprintf('\nERROR: Failed to initialize IQMtools from default path.\n');
                                fprintf('Please check that installIQMtools.m exists at:\n');
                                fprintf('  %s\\installIQMtools.m\n', defaultPath);
                            end
                        else
                            fprintf('\nERROR: Default path not found: %s\n', defaultPath);
                            fprintf('Please use option 1 to specify the correct path.\n');
                        end

                    elseif strcmp(choice, '3')
                        % Option 3: Skip
                        fprintf('\nSkipping IQMtools initialization.\n');
                        fprintf('Only txtbc file will be generated.\n');
                        fprintf('You can manually load it later:\n');
                        fprintf('  >> run(''C:\\IQMtools V1.2.2.2\\installIQMtools.m'');\n');
                        fprintf('  >> model = IQMmodel(''model.txtbc'');\n');
                    else
                        fprintf('\nInvalid choice. Skipping IQMtools initialization.\n');
                    end
                end
                fprintf('\n');
            end

            response = questdlg("Generate ODE and MEX files using IQMtools (y/n) ? ", 's');

            if strcmpi(response, 'y') || strcmpi(response, 'yes')
                fprintf('\n=== Starting IQMtools Processing ===\n\n');

                % Step 7a: Load model into IQMtools
                fprintf('Step 1/3: Loading model into IQMtools...\n');
                try
                    obj.exporter.loadIntoIQMtools(obj.config.iqmToolsPath);              

                catch ME
                    fprintf('\nERROR: Could not load model into IQMtools.\n');
                    fprintf('Error message: %s\n', ME.message);
                    fprintf('\nPlease check that:\n');
                    fprintf('  1. IQMtools is properly installed\n');
                    fprintf('  2. IQMtools is added to MATLAB path\n');
                    fprintf('  3. The txtbc file is valid\n');
                    fprintf('\nSkipping ODE and MEX generation.\n');
                    return;
                end

                % Step 7b: Generate ODE file (IQMtools format)
                fprintf('\nStep 2/4: Generating IQMtools ODE m-file...\n');
                try
                    obj.generateODEFile();
                    fprintf('SUCCESS: IQMtools ODE m-file generated.\n');
                catch ME
                    fprintf('WARNING: IQMtools ODE file generation failed: %s\n', ME.message);
                end

                % Step 7c: Generate Standard ODE file (MATLAB native format)
                fprintf('\nStep 3/4: Generating MATLAB Standard ODE m-file...\n');
                try
                    obj.generateStandardODEFile();
                    fprintf('SUCCESS: Standard ODE m-file generated (compatible with ode15s, ode45, etc.).\n');
                catch ME
                    fprintf('WARNING: Standard ODE file generation failed: %s\n', ME.message);
                end

                % Step 7d: Ask about MEX compilation
                fprintf('\nStep 4/4: MEX file compilation\n');
                fprintf('MEX compilation requires a C compiler to be configured.\n');
                fprintf('Run "mex -setup" if you haven''t configured a compiler yet.\n');
                fprintf('\n');
                mexResponse = questdlg('Compile MEX file for faster simulation (y/n) ? ', 's');

                if strcmpi(mexResponse, 'y') || strcmpi(mexResponse, 'yes')
                    fprintf('\nCompiling MEX file...\n');
                    fprintf('(This may take a minute...)\n');
                    try
                        % Save current directory
                        currentDir = pwd;

                        % Change to model output directory for MEX compilation
                        modelDir = obj.getModelOutputDir();
                        cd(modelDir);

                        % Compile MEX
                        obj.compileMEX();

                        % Return to original directory
                        cd(currentDir);

                        fprintf('SUCCESS: MEX file compiled successfully.\n');

                        % Generate simulation script
                        fprintf('\nGenerating simulation script...\n');
                        scriptPath = obj.exporter.generateSimulationScript();

                        % Ask user if they want to run it
                        simResponse = questdlg('Do you want to run the random parameter simulation now?', ...
                            'Run Simulation', ...
                            'Yes', 'No', 'No');

                        if strcmpi(simResponse, 'Yes')
                            fprintf('\nRunning simulation script...\n');
                            run(scriptPath);
                        else
                            fprintf('Simulation script saved to: %s\n', scriptPath);
                        end
                    catch ME
                        % Return to original directory even on error
                        cd(currentDir);

                        fprintf('WARNING: MEX compilation failed.\n');
                        fprintf('Error message: %s\n', ME.message);
                        fprintf('\nPossible solutions:\n');
                        fprintf('  1. Install a C compiler (e.g., MinGW for Windows)\n');
                        fprintf('  2. Run "mex -setup" to configure your compiler\n');
                        fprintf('  3. Use the ODE m-file instead (slower but doesn''t require compiler)\n');
                    end
                else
                    fprintf('Skipping MEX compilation.\n');
                    fprintf('You can compile later using step3_make_MEX_file.m or compileMEX() method.\n');
                end

                fprintf('\n=== IQMtools Processing Complete ===\n');
            else
                fprintf('\nSkipping IQMtools processing.\n');
                fprintf('The txtbc file can be loaded into IQMtools manually:\n');
                fprintf('  >> model = IQMmodel(''%s'');\n', obj.exporter.txtbcFile);
                fprintf('\nOr you can run step3 later to generate ODE and MEX files.\n');
            end

            % Final summary
            fprintf('\n');
            fprintf('================================================\n');
            fprintf('  Pipeline Complete!\n');
            fprintf('================================================\n');
            fprintf('\n');
            fprintf('Model: %s\n', obj.model.name);
            fprintf('Output Directory: %s\n', modelDir);
            fprintf('\n');
            fprintf('Generated Files:\n');
            fprintf('  - table_parameter.xlsx         (Edit parameter values here)\n');
            fprintf('  - table_statevariable.xlsx     (Edit initial conditions here)\n');
            fprintf('  - %s.txtbc                (IQM model format)\n', obj.model.name);

            % Check if ODE file was generated
            if ~isempty(obj.exporter) && ~isempty(obj.exporter.odeFile)
                odeFilePath = sprintf('%s.m', obj.exporter.odeFile);
                if exist(odeFilePath, 'file')
                    fprintf('  - %s_ode.m                 (MATLAB ODE function)\n', obj.model.name);
                end
            end

            % Check if standard ODE file was generated
            if ~isempty(obj.exporter) && ~isempty(obj.exporter.odeFile)
                stdOdeFilePath = sprintf('%s_std.m', obj.exporter.odeFile);
                if exist(stdOdeFilePath, 'file')
                    fprintf('  - %s_ode_std.m                 (MATLAB ODE function)\n', obj.model.name);
                end
            end

            % Check if MEX file was generated
            if ~isempty(obj.exporter) && ~isempty(obj.exporter.mexFile)
                % MEX files have platform-specific extensions (.mexw64, .mexa64, etc.)
                mexPattern = sprintf('%s.*', obj.exporter.mexFile);
                mexFiles = dir(mexPattern);
                if ~isempty(mexFiles)
                    fprintf('  - %s                    (Compiled MEX - fast simulation)\n', mexFiles(1).name);
                end
            end

            fprintf('\n');
            fprintf('================================================\n');
            fprintf('\n');
        end

        function runQuickPipeline(obj, excelFile, outputDir)
            % Run quick pipeline without user interaction
            % Inputs:
            %   excelFile - Path to Excel input file
            %   outputDir - Output directory path (optional)

            % Set up options for non-interactive mode
            options = struct();
            options.compileMEX = false;
            options.validateModel = true;

            fprintf('\n');
            fprintf('================================================\n');
            fprintf('  ODE Model Creator - Quick Pipeline\n');
            fprintf('  (Non-interactive mode)\n');
            fprintf('================================================\n');
            fprintf('\n');

            % Set output directory if provided
            if nargin >= 3 && ~isempty(outputDir)
                obj.config.setPath('outputDir', outputDir);
            end

            % Load and process model
            obj.loadModel(excelFile);
            obj.generateRateEquations();

            if options.validateModel
                obj.validateModel();
            end

            % Export tables
            obj.exportParameterTable();
            obj.exportStateVariableTable();

            % Export to IQM (no pause for user editing)
            obj.exportToIQM();

            % Try to generate ODE file
            try
                obj.generateODEFile();
            catch
                % Silently fail
            end

            fprintf('\n');
            fprintf('================================================\n');
            fprintf('  Quick Pipeline Complete!\n');
            fprintf('================================================\n');
            fprintf('\n');
        end

        function modelDir = getModelOutputDir(obj)
            % Get output directory for current model
            % Returns: Path to model output directory

            if isempty(obj.model)
                modelDir = obj.config.getPath('outputDir');
            else
                if isempty(obj.config.getPath('outputDir'))
                    % Use user files directory
                    baseDir = obj.config.getPath('userFilesDir');
                    if isempty(baseDir)
                        baseDir = fullfile(pwd, 'user files');
                    end
                    modelDir = fullfile(baseDir, obj.model.name);
                else
                    modelDir = obj.config.getPath('outputDir');
                end
            end

            % Create directory if it doesn't exist
            if ~exist(modelDir, 'dir')
                mkdir(modelDir);
            end
        end

        function printSummary(obj)
            % Print builder summary to console

            fprintf('\n=== ODE Model Builder Summary ===\n\n');

            % Configuration
            fprintf('Configuration:\n');
            if ~isempty(obj.config.defaultParamFile)
                fprintf('  Default Params: %s\n', obj.config.defaultParamFile);
            end
            if ~isempty(obj.config.iqmToolsPath)
                fprintf('  IQMtools Path: %s\n', obj.config.iqmToolsPath);
            end

            % Model
            if ~isempty(obj.model)
                fprintf('\nModel: %s\n', obj.model.name);
                summary = obj.model.getSummary();
                fprintf('  Reactions: %d\n', summary.numReactions);
                fprintf('  State Variables: %d\n', summary.numStateVariables);
                fprintf('  Parameters: %d\n', summary.numParameters);
                fprintf('  Inputs: %d\n', summary.numInputs);
                fprintf('  Inhibitors: %d\n', summary.numInhibitors);
                fprintf('  Readouts: %d\n', summary.numReadouts);
            else
                fprintf('\nModel: Not loaded\n');
            end

            % Managers
            if ~isempty(obj.paramManager)
                fprintf('\nParameter Manager: Active (%d parameters)\n', obj.paramManager.parameters.Count);
            end
            if ~isempty(obj.stateManager)
                fprintf('State Variable Manager: Active (%d state variables)\n', obj.stateManager.stateVariables.Count);
            end
            if ~isempty(obj.exporter)
                fprintf('IQM Exporter: Active\n');
            end

            fprintf('\n=================================\n\n');
        end

        function disp(obj)
            % Display method
            obj.printSummary();
        end
    end
end
