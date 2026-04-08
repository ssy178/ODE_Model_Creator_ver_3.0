function config = default_config()
% DEFAULT_CONFIG Returns default configuration for ODE Model Creator
%
% This function creates a ModelConfiguration object with default settings
% for the ODE Model Creator system.
%
% Returns:
%   config - ModelConfiguration object with default settings
%
% Usage:
%   config = default_config();
%   builder = ODEModelBuilder(config);

    % Create configuration object
    config = ModelConfiguration();

    % Set default paths (these will be auto-detected relative to this file)
    config.setDefaultPaths();

    % Set processing options
    config.setOption('verbose', true);           % Display detailed progress
    config.setOption('validateInput', true);     % Validate Excel input
    config.setOption('exportTables', true);      % Export parameter/state tables
    config.setOption('pauseForEditing', true);   % Pause to allow user table editing
    config.setOption('generateODE', true);       % Generate ODE m-file
    config.setOption('compileMEX', false);       % Compile MEX file (requires IQMtools)
    config.setOption('sortAlphabetically', true); % Sort parameters/states alphabetically

    % IQMtools settings (auto-detected if available)
    config.detectIQMtools();

    % Display configuration summary
    if config.getOption('verbose')
        config.printSummary();
    end
end
