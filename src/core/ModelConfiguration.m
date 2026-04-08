classdef ModelConfiguration < handle
    % MODELCONFIGURATION Manages configuration settings for the ODE Model Creator
    %
    % This class handles all configuration settings including:
    %   - File paths (input, output, default parameter file)
    %   - IQMtools installation path
    %   - Processing options
    %
    % Properties:
    %   paths            - Struct with all path configurations
    %   options          - Struct with processing options
    %   iqmToolsPath     - Path to IQMtools installation
    %   defaultParamFile - Path to default parameter values file
    %
    % Example:
    %   config = ModelConfiguration();
    %   config.setDefaultPaths();
    %   config.saveToFile('my_config.mat');
    %
    %   config2 = ModelConfiguration();
    %   config2.loadFromFile('my_config.mat');

    properties
        paths struct           % Path configurations
        options struct         % Processing options
        iqmToolsPath char = '' % Path to IQMtools
        defaultParamFile char = '' % Path to default parameter file
    end

    methods
        function obj = ModelConfiguration()
            % Constructor
            % Initializes with default empty configuration

            % Initialize paths structure
            obj.paths = struct();
            obj.paths.inputDir = '';
            obj.paths.outputDir = '';
            obj.paths.modelDir = '';
            obj.paths.sourceDir = '';
            obj.paths.userFilesDir = '';

            % Initialize options structure
            obj.options = struct();
            obj.options.overwriteExisting = true;
            obj.options.validateModel = true;
            obj.options.compileMEX = false;
            obj.options.verbose = true;
        end

        function setDefaultPaths(obj, rootDir)
            % Set default paths based on root directory
            % Input:
            %   rootDir - Root directory (optional, uses current dir if not provided)

            if nargin < 2
                rootDir = pwd;
            end

            % Set default paths
            obj.paths.inputDir = fullfile(rootDir, 'user files');
            obj.paths.outputDir = fullfile(rootDir, 'output');
            obj.paths.sourceDir = fullfile(rootDir, 'src');
            obj.paths.userFilesDir = fullfile(rootDir, 'user files');

            % Set default parameter file path
            % First check ODEModelCreator/config
            configParamFile = fullfile(rootDir, 'ODEModelCreator', 'config', 'default_parameter_values.xlsx');
            if exist(configParamFile, 'file')
                obj.defaultParamFile = configParamFile;
            else
                % Check for config folder in root (common in development)
                rootConfigParamFile = fullfile(rootDir, 'config', 'default_parameter_values.xlsx');
                if exist(rootConfigParamFile, 'file')
                    obj.defaultParamFile = rootConfigParamFile;
                else
                    % Fall back to src folder
                    srcParamFile = fullfile(rootDir, 'src', 'default_parameter_value.xlsx');
                    if exist(srcParamFile, 'file')
                        obj.defaultParamFile = srcParamFile;
                    else
                        % Try root directory
                        rootParamFile = fullfile(rootDir, 'default_parameter_value.xlsx');
                        if exist(rootParamFile, 'file')
                            obj.defaultParamFile = rootParamFile;
                        else
                            warning('ModelConfiguration:NoDefaultParams', ...
                                'Default parameter file not found. Please set manually.');
                        end
                    end
                end
            end

            % Try to find IQMtools
            obj.detectIQMtools(rootDir);
        end

        function detectIQMtools(obj, rootDir)
            % Attempt to automatically detect IQMtools installation
            % Input:
            %   rootDir - Root directory to search from

            if nargin < 2
                rootDir = pwd;
            end

            % Common IQMtools installation locations (Windows-specific paths first)
            possiblePaths = {
                fullfile(rootDir, 'IQMtools V1.2.2.2')
                fullfile(rootDir, 'IQMtools')
                fullfile(rootDir, '..', 'IQMtools')
                fullfile(rootDir, 'tools', 'IQMtools')
                fullfile(fileparts(rootDir), 'IQMtools')
                };

            % Check each possible path
            for i = 1:length(possiblePaths)
                if exist(possiblePaths{i}, 'dir')
                    % Check if it's actually IQMtools by looking for key files
                    if exist(fullfile(possiblePaths{i}, 'IQMlite'), 'dir') || ...
                            exist(fullfile(possiblePaths{i}, 'IQMpro'), 'dir') || ...
                            exist(fullfile(possiblePaths{i}, 'installIQMtools.m'), 'file')
                        obj.iqmToolsPath = possiblePaths{i};
                        return;
                    end
                end
            end

            % If not found, leave empty with a warning
            if isempty(obj.iqmToolsPath)
                warning('ModelConfiguration:NoIQMtools', ...
                    'IQMtools installation not found. Please set manually if needed.');
            end
        end

        function success = initializeIQMtools(obj, iqmToolsPath)
            % Initialize IQMtools by running installIQMtools.m
            % This adds all IQMtools functions to the MATLAB path
            % Input:
            %   iqmToolsPath - Path to IQMtools installation (optional)
            % Returns:
            %   success - true if initialization successful, false otherwise

            % Use provided path or stored path
            if nargin >= 2 && ~isempty(iqmToolsPath)
                iqmPath = iqmToolsPath;
            elseif ~isempty(obj.iqmToolsPath)
                iqmPath = obj.iqmToolsPath;
            else
                % Try to detect IQMtools first
                obj.detectIQMtools();
                iqmPath = obj.iqmToolsPath;
            end

            % Check if path is valid
            if isempty(iqmPath) || ~exist(iqmPath, 'dir')
                success = false;
                warning('ModelConfiguration:NoIQMtools', ...
                    'IQMtools path not found: %s', iqmPath);
                return;
            end

            % Look for installIQMtools.m
            installScript = fullfile(iqmPath, 'installIQMtools.m');
            if ~exist(installScript, 'file')
                success = false;
                warning('ModelConfiguration:NoInstallScript', ...
                    'installIQMtools.m not found in: %s', iqmPath);
                return;
            end

            % Run installIQMtools.m
            try
                currentDir = pwd;
                cd(iqmPath);
                run('installIQMtools.m');
                cd(currentDir);

                % Verify that IQMtools functions are now available
                if exist('IQMmodel', 'file') == 2
                    success = true;
                    if obj.options.verbose
                        fprintf('IQMtools initialized successfully from: %s\n', iqmPath);
                    end
                else
                    success = false;
                    cd(currentDir);
                    warning('ModelConfiguration:InitializationFailed', ...
                        'IQMtools initialization failed - IQMmodel function not found');
                end
            catch ME
                cd(currentDir);
                success = false;
                warning('ModelConfiguration:InitializationError', ...
                    'Error initializing IQMtools: %s', ME.message);
            end
        end

        function loadFromFile(obj, configFile)
            % Load configuration from file
            % Input:
            %   configFile - Path to configuration file (.mat or .m)

            if ~exist(configFile, 'file')
                error('ModelConfiguration:FileNotFound', ...
                    'Configuration file not found: %s', configFile);
            end

            [~, ~, ext] = fileparts(configFile);

            switch lower(ext)
                case '.mat'
                    % Load from MAT file
                    data = load(configFile);
                    if isfield(data, 'config')
                        % Restore properties
                        if isfield(data.config, 'paths')
                            obj.paths = data.config.paths;
                        end
                        if isfield(data.config, 'options')
                            obj.options = data.config.options;
                        end
                        if isfield(data.config, 'iqmToolsPath')
                            obj.iqmToolsPath = data.config.iqmToolsPath;
                        end
                        if isfield(data.config, 'defaultParamFile')
                            obj.defaultParamFile = data.config.defaultParamFile;
                        end
                    else
                        error('ModelConfiguration:InvalidFormat', ...
                            'Invalid configuration file format');
                    end

                case '.m'
                    % Execute script to set configuration
                    currentDir = pwd;
                    [configDir, configName, ~] = fileparts(configFile);
                    if ~isempty(configDir)
                        cd(configDir);
                    end
                    try
                        run(configName);
                        cd(currentDir);
                    catch ME
                        cd(currentDir);
                        rethrow(ME);
                    end

                otherwise
                    error('ModelConfiguration:UnsupportedFormat', ...
                        'Unsupported configuration file format: %s', ext);
            end

            % Validate after loading
            obj.validate();
        end

        function saveToFile(obj, configFile)
            % Save configuration to file
            % Input:
            %   configFile - Path to save configuration (.mat)

            % Create structure to save
            config = struct();
            config.paths = obj.paths;
            config.options = obj.options;
            config.iqmToolsPath = obj.iqmToolsPath;
            config.defaultParamFile = obj.defaultParamFile;

            % Save to file
            save(configFile, 'config');

            if obj.options.verbose
                fprintf('Configuration saved to: %s\n', configFile);
            end
        end

        function isValid = validate(obj)
            % Validate configuration settings
            % Returns: true if valid, false otherwise

            isValid = true;

            % Check if default parameter file exists
            if ~isempty(obj.defaultParamFile) && ~exist(obj.defaultParamFile, 'file')
                warning('ModelConfiguration:InvalidParamFile', ...
                    'Default parameter file does not exist: %s', obj.defaultParamFile);
                isValid = false;
            end

            % Check if IQMtools path exists
            if ~isempty(obj.iqmToolsPath) && ~exist(obj.iqmToolsPath, 'dir')
                warning('ModelConfiguration:InvalidIQMPath', ...
                    'IQMtools path does not exist: %s', obj.iqmToolsPath);
                isValid = false;
            end

            % Check if essential paths exist (create if needed)
            if isfield(obj.paths, 'outputDir') && ~isempty(obj.paths.outputDir)
                if ~exist(obj.paths.outputDir, 'dir')
                    if obj.options.verbose
                        fprintf('Creating output directory: %s\n', obj.paths.outputDir);
                    end
                    mkdir(obj.paths.outputDir);
                end
            end
        end

        function setPath(obj, pathName, pathValue)
            % Set a specific path
            % Inputs:
            %   pathName  - Name of the path (e.g., 'inputDir', 'outputDir')
            %   pathValue - Path value

            obj.paths.(pathName) = pathValue;
        end

        function setOption(obj, optionName, optionValue)
            % Set a specific option
            % Inputs:
            %   optionName  - Name of the option
            %   optionValue - Option value

            obj.options.(optionName) = optionValue;
        end

        function pathValue = getPath(obj, pathName)
            % Get a specific path
            % Input:
            %   pathName - Name of the path
            % Returns:
            %   pathValue - Path value

            if isfield(obj.paths, pathName)
                pathValue = obj.paths.(pathName);
            else
                pathValue = '';
                warning('ModelConfiguration:PathNotFound', ...
                    'Path not found: %s', pathName);
            end
        end

        function optionValue = getOption(obj, optionName)
            % Get a specific option
            % Input:
            %   optionName - Name of the option
            % Returns:
            %   optionValue - Option value

            if isfield(obj.options, optionName)
                optionValue = obj.options.(optionName);
            else
                optionValue = [];
                warning('ModelConfiguration:OptionNotFound', ...
                    'Option not found: %s', optionName);
            end
        end

        function printSummary(obj)
            % Print configuration summary to console

            fprintf('\n=== Model Configuration ===\n\n');

            fprintf('Paths:\n');
            pathFields = fieldnames(obj.paths);
            for i = 1:length(pathFields)
                fprintf('  %-15s: %s\n', pathFields{i}, obj.paths.(pathFields{i}));
            end

            fprintf('\nOptions:\n');
            optionFields = fieldnames(obj.options);
            for i = 1:length(optionFields)
                value = obj.options.(optionFields{i});
                if islogical(value)
                    valueStr = mat2str(value);
                elseif isnumeric(value)
                    valueStr = num2str(value);
                else
                    valueStr = char(value);
                end
                fprintf('  %-20s: %s\n', optionFields{i}, valueStr);
            end

            fprintf('\nIQMtools Path: %s\n', obj.iqmToolsPath);
            fprintf('Default Param File: %s\n', obj.defaultParamFile);
            fprintf('\n===========================\n\n');
        end

        function disp(obj)
            % Display method
            obj.printSummary();
        end
    end
end
