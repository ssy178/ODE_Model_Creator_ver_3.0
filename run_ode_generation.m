% RUN_ODE_GENERATION
%
% This script allows the user to select an Excel model file from the 'userInputFile'
% directory and runs the ODE Model Creator pipeline.
% Results are saved to a subdirectory in 'output' with the same name as the input file.
%

%% Setup
clear; clc; close all;

% Get the root directory (where this script is located)
rootDir = fileparts(mfilename('fullpath'));

% Add ODE Model Creator source code to path
addpath(genpath(fullfile(rootDir, 'src')));

%% Input Selection

% Define input directory
inputBaseDir = fullfile(rootDir, 'userInputFile');

% Check if input directory exists
if ~exist(inputBaseDir, 'dir')
    warning('Input directory "userInputFile" not found. Creating it...');
    mkdir(inputBaseDir);
end

% Open file selection dialog starting in inputBaseDir
fprintf('Please select your Excelt network map file from the dialog...\n');
[fileName, pathName] = uigetfile({'*.xlsx;*.xls', 'Excel Files (*.xlsx, *.xls)'}, ...
    'Select Network Map File', ...
    inputBaseDir);

% Check if user cancelled
if isequal(fileName, 0)
    fprintf('Selection cancelled. Exiting.\n');
    return;
end

inputFilePath = fullfile(pathName, fileName);

%% Output Setup

% Get filename without extension for folder name
[~, name, ~] = fileparts(fileName);
outputSubDirName = name;

% Define output directory
outputDir = fullfile(rootDir, 'output', outputSubDirName);

fprintf('\n=== ODE Model Generation ===\n');
fprintf('Input File:  %s\n', inputFilePath);
fprintf('Output Dir:  %s\n', outputDir);

%% Run Pipeline

fprintf('\nInitializing ODE Model Builder...\n');

% Create builder
builder = ODEModelBuilder();

% Initialize options struct
options = struct();
options.validateModel = true;

% Ask user if they want to use a custom parameter file
choice = questdlg('Do you want to use a custom parameter value file?', ...
    'Parameter File Selection', ...
    'Yes', 'No', 'No');

if strcmp(choice, 'Yes')
    fprintf('Please select your parameter value file...\n');
    [paramFile, paramPath] = uigetfile({'*.xlsx;*.xls', 'Excel Files (*.xlsx, *.xls)'}, ...
        'Select Parameter Value File', ...
        rootDir);

    if ~isequal(paramFile, 0)
        options.parameterValueMode = 'file';
        options.parameterValueFile = fullfile(paramPath, paramFile);
        fprintf('Using custom parameter value file: %s\n', options.parameterValueFile);
    else
        fprintf('Parameter file selection cancelled. Using default values.\n');
        options.parameterValueMode = 'default';
    end
else
    fprintf('Using default parameter values.\n');
    options.parameterValueMode = 'default';
end

% Ask user if they have an initial value file
choice = questdlg('Do you have an initial value file for state variables?', ...
	'Initial Value Selection', ...
	'Yes', 'No', 'No');

if strcmp(choice, 'Yes')
    fprintf('Please select your initial value file...\n');
    [initFile, initPath] = uigetfile({'*.xlsx;*.xls', 'Excel Files (*.xlsx, *.xls)'}, ...
        'Select Initial Value File', ...
        rootDir);
    
    if ~isequal(initFile, 0)
        options.initialValueMode = 'file';
        options.initialValueFile = fullfile(initPath, initFile);
        fprintf('Using initial value file: %s\n', options.initialValueFile);
    else
        fprintf('Initial value file selection cancelled. Using random values (0-100).\n');
        options.initialValueMode = 'random';
        options.randomRange = [0 100];
    end
else
    fprintf('No initial value file provided. Using random values (0-100).\n');
    options.initialValueMode = 'random';
    options.randomRange = [0 100];
end

% Run complete pipeline
% This will:
%   - Load Excel file
%   - Generate rate equations
%   - Validate model
%   - Export parameter and state variable tables
%   - PAUSE for you to edit tables (if configured in builder, usually via input())
%   - Export to IQM txtbc
%   - Generate ODE file
try
    builder.runFullPipeline(inputFilePath, outputDir, options);

    fprintf('\n=== Generation Complete ===\n');
    fprintf('Results saved in: %s\n', outputDir);

catch ME
    fprintf('\n!!! Error during generation !!!\n');
    fprintf('%s\n', ME.message);
    rethrow(ME);
end
