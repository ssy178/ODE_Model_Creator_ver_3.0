classdef IQMExporter < handle
    % IQMEXPORTER Exports biological model to IQM txtbc format and generates ODE/MEX files
    %
    % This class handles:
    %   - Exporting BiologicalModel to IQM txtbc format
    %   - Loading model into IQMtools
    %   - Generating ODE m-files
    %   - Compiling MEX files for faster simulation
    %
    % Properties:
    %   model        - BiologicalModel object
    %   outputDir    - Output directory path
    %   txtbcFile    - Generated txtbc file path
    %   odeFile      - Generated ODE m-file path
    %   mexFile      - Generated MEX file path
    %   iqmModel     - IQMtools model object
    %   paramTable   - Parameter table (name, value)
    %   stateTable   - State variable table (name, initial value)
    %
    % Example:
    %   exporter = IQMExporter(biologicalModel, 'output');
    %   exporter.loadParameterTable('table_parameter.xlsx');
    %   exporter.loadStateVariableTable('table_statevariable.xlsx');
    %   exporter.exportToTxtbc('model.txtbc');
    %   exporter.runFullExport();

    properties
        model              % BiologicalModel object
        outputDir char = ''
        txtbcFile char = ''
        odeFile char = ''
        mexFile char = ''
        iqmModel           % IQMtools model object
        paramTable table   % Parameter table
        stateTable table   % State variable table
    end

    methods
        function obj = IQMExporter(biologicalModel, outputDir)
            % Constructor
            % Inputs:
            %   biologicalModel - BiologicalModel object (optional)
            %   outputDir       - Output directory path (optional)

            if nargin >= 1
                obj.model = biologicalModel;
            end

            if nargin >= 2
                obj.outputDir = outputDir;
            end

            % Initialize empty tables
            obj.paramTable = table();
            obj.stateTable = table();
        end

        function loadParameterTable(obj, paramFile)
            % Load parameter table from Excel file
            % Input:
            %   paramFile - Path to parameter Excel file

            if ~exist(paramFile, 'file')
                error('IQMExporter:FileNotFound', ...
                    'Parameter file not found: %s', paramFile);
            end

            obj.paramTable = readtable(paramFile, 'ReadVariableNames', false);
            obj.paramTable.Properties.VariableNames = {'ParamName', 'ParamValue'};

            fprintf('Loaded %d parameters from: %s\n', height(obj.paramTable), paramFile);
        end

        function loadStateVariableTable(obj, stateFile)
            % Load state variable table from Excel file
            % Input:
            %   stateFile - Path to state variable Excel file

            if ~exist(stateFile, 'file')
                error('IQMExporter:FileNotFound', ...
                    'State variable file not found: %s', stateFile);
            end

            obj.stateTable = readtable(stateFile, 'ReadVariableNames', false);
            obj.stateTable.Properties.VariableNames = {'StateName', 'StateValue'};

            fprintf('Loaded %d state variables from: %s\n', height(obj.stateTable), stateFile);
        end

        function exportToTxtbc(obj, filename)
            % Export model to IQM txtbc format
            % Input:
            %   filename - Output filename (optional, uses model name if not provided)

            if isempty(obj.model)
                error('IQMExporter:NoModel', 'No biological model loaded');
            end

            % Determine output file path
            if nargin >= 2 && ~isempty(filename)
                % If filename is absolute path, use it directly
                if PathHelper.isAbsolutePath(filename)
                    obj.txtbcFile = filename;
                else
                    % Otherwise, use outputDir + filename
                    if isempty(obj.outputDir)
                        obj.txtbcFile = filename;
                    else
                        obj.txtbcFile = fullfile(obj.outputDir, filename);
                    end
                end
            else
                % Use model name
                if isempty(obj.outputDir)
                    obj.txtbcFile = sprintf('%s.txtbc', obj.model.name);
                else
                    obj.txtbcFile = fullfile(obj.outputDir, sprintf('%s.txtbc', obj.model.name));
                end
            end

            % Ensure output directory exists
            [outputPath, ~, ~] = fileparts(obj.txtbcFile);
            if ~isempty(outputPath) && ~exist(outputPath, 'dir')
                mkdir(outputPath);
            end

            % Open file for writing
            fid = fopen(obj.txtbcFile, 'w');
            if fid == -1
                error('IQMExporter:FileError', 'Cannot open file for writing: %s', obj.txtbcFile);
            end

            try
                % Write model sections
                obj.writeModelName(fid);
                obj.writeModelNotes(fid);
                obj.writeModelStateInformation(fid);
                obj.writeModelParameters(fid);
                obj.writeModelVariables(fid);
                obj.writeModelReactions(fid);
                obj.writeModelFunctions(fid);
                obj.writeModelEvents(fid);
                obj.writeModelMatlabFunctions(fid);

                fclose(fid);

                fprintf('Model exported to IQM txtbc format: %s\n', obj.txtbcFile);

            catch ME
                fclose(fid);
                rethrow(ME);
            end
        end

        function writeModelName(obj, fid)
            % Write MODEL NAME section
            fprintf(fid, '********** MODEL NAME\n\n');
            fprintf(fid, '%s\n', obj.model.name);
            fprintf(fid, '\n');
        end

        function writeModelNotes(obj, fid)
            % Write MODEL NOTES section
            fprintf(fid, '********** MODEL NOTES\n\n');
            if ~isempty(obj.model.description)
                fprintf(fid, '%s\n', obj.model.description);
            end
            fprintf(fid, '\n');
            fprintf(fid, '\n');
        end

        function writeModelStateInformation(obj, fid)
            % Write MODEL STATE INFORMATION section
            fprintf(fid, '********** MODEL STATE INFORMATION\n\n');

            % Write initial values for state variables
            if ~isempty(obj.stateTable) && height(obj.stateTable) > 0
                for i = 1:height(obj.stateTable)
                    stateName = obj.stateTable.StateName{i};
                    stateValue = obj.stateTable.StateValue(i);
                    fprintf(fid, '%-20s\n', sprintf('%s(0) = %g', stateName, stateValue));
                end
            end

            fprintf(fid, '\n');
        end

        function writeModelParameters(obj, fid)
            % Write MODEL PARAMETERS section
            fprintf(fid, '********** MODEL PARAMETERS\n\n');

            % Write parameter values
            if ~isempty(obj.paramTable) && height(obj.paramTable) > 0
                for i = 1:height(obj.paramTable)
                    paramName = obj.paramTable.ParamName{i};
                    paramValue = obj.paramTable.ParamValue(i);
                    fprintf(fid, '%-20s\n', sprintf('%s = %g', paramName, paramValue));
                end
            end

            fprintf(fid, '\n');

            % Write input signal parameters
            fprintf(fid, '%% input parameters\n\n');
            for i = 1:length(obj.model.inputs)
                input = obj.model.inputs{i};
                paramVals = input.getParameterValues();
                paramNames = fieldnames(paramVals);
                for j = 1:length(paramNames)
                    paramName = paramNames{j};
                    paramValue = paramVals.(paramName);
                    fprintf(fid, '%-20s\n', sprintf('%s = %g', paramName, paramValue));
                end
            end

            fprintf(fid, '\n');

            % Write inhibitor parameters
            fprintf(fid, '%% drug input parameters\n\n');
            for i = 1:length(obj.model.inhibitors)
                inhibitor = obj.model.inhibitors{i};
                paramVals = inhibitor.getParameterValues();
                paramNames = fieldnames(paramVals);
                for j = 1:length(paramNames)
                    paramName = paramNames{j};
                    paramValue = paramVals.(paramName);
                    fprintf(fid, '%-20s\n', sprintf('%s = %g', paramName, paramValue));
                end
            end

            fprintf(fid, '\n');
        end

        function writeModelVariables(obj, fid)
            % Write MODEL VARIABLES section
            fprintf(fid, '********** MODEL VARIABLES\n\n');

            % Write readout variables
            for i = 1:length(obj.model.readouts)
                readout = obj.model.readouts{i};
                eqStr = readout.getIQMEquation();
                fprintf(fid, '%s\n', eqStr);
            end

            if ~isempty(obj.model.readouts)
                fprintf(fid, '\n');
            end

            % Write input signal equations
            fprintf(fid, '%% model input parameters\n\n');
            for i = 1:length(obj.model.inputs)
                input = obj.model.inputs{i};
                eqStr = input.getIQMEquation();
                fprintf(fid, '%s\n', eqStr);
            end

            fprintf(fid, '\n');

            % Write inhibitor equations
            fprintf(fid, '%% drug input parameters\n\n');
            for i = 1:length(obj.model.inhibitors)
                inhibitor = obj.model.inhibitors{i};
                eqStr = inhibitor.getIQMEquation();
                fprintf(fid, '%s\n', eqStr);
            end

            fprintf(fid, '\n');
        end

        function writeModelReactions(obj, fid)
            % Write MODEL REACTIONS section
            fprintf(fid, '********** MODEL REACTIONS\n\n');

            % Write each reaction
            for i = 1:length(obj.model.reactions)
                reaction = obj.model.reactions{i};

                % Write process string
                procStr = reaction.getProcessString();
                fprintf(fid, '%-20s\n', procStr);

                % Write rate equation
                fprintf(fid, '%-20s\n', reaction.rateEquation);
                fprintf(fid, '\n');
            end

            fprintf(fid, '\n');
        end

        function writeModelFunctions(~, fid)
            % Write MODEL FUNCTIONS section
            fprintf(fid, '********** MODEL FUNCTIONS\n\n');
            fprintf(fid, '\n');
        end

        function writeModelEvents(~, fid)
            % Write MODEL EVENTS section
            fprintf(fid, '********** MODEL EVENTS\n\n');
            fprintf(fid, '\n');
        end

        function writeModelMatlabFunctions(~, fid)
            % Write MODEL MATLAB FUNCTIONS section
            fprintf(fid, '********** MODEL MATLAB FUNCTIONS\n\n');
            fprintf(fid, '\n');
        end

        function loadIntoIQMtools(obj, iqmToolsPath)
            % Load model into IQMtools
            % Input:
            %   iqmToolsPath - Path to IQMtools installation (optional)

            if isempty(obj.txtbcFile) || ~exist(obj.txtbcFile, 'file')
                error('IQMExporter:NoTxtbcFile', ...
                    'txtbc file not found. Run exportToTxtbc() first.');
            end

            % Add IQMtools to path if provided
            if nargin >= 2 && ~isempty(iqmToolsPath)
                addpath(genpath(iqmToolsPath));
            end

            % Check if IQMtools is available
            if ~exist('IQMmodel', 'file')
                warning('IQMExporter:NoIQMtools', ...
                    'IQMtools not found on path. Cannot load model into IQMtools.');
                return;
            end

            try
                % Load model using IQMtools
                obj.iqmModel = IQMmodel(obj.txtbcFile);
                fprintf('Model loaded into IQMtools successfully\n');

            catch ME
                error('IQMExporter:LoadError', ...
                    'Error loading model into IQMtools: %s', ME.message);
            end
        end

        function generateODEFile(obj, filename)
            % Generate ODE m-file from IQM model
            % Input:
            %   filename - Output filename (without extension)

            if isempty(obj.iqmModel)
                warning('IQMExporter:NoIQMModel', ...
                    'IQM model not loaded. Attempting to load...');
                obj.loadIntoIQMtools();
            end

            if isempty(obj.iqmModel)
                error('IQMExporter:NoIQMModel', ...
                    'Cannot generate ODE file without IQM model');
            end

            % Determine output file path
            if nargin >= 2 && ~isempty(filename)
                if PathHelper.isAbsolutePath(filename)
                    obj.odeFile = filename;
                else
                    if isempty(obj.outputDir)
                        obj.odeFile = filename;
                    else
                        obj.odeFile = fullfile(obj.outputDir, filename);
                    end
                end
            else
                % Use model name
                if isempty(obj.outputDir)
                    obj.odeFile = sprintf('%s_ode', obj.model.name);
                else
                    obj.odeFile = fullfile(obj.outputDir, sprintf('%s_ode', obj.model.name));
                end
            end

            % Ensure output directory exists
            [outputPath, ~, ~] = fileparts(obj.odeFile);
            if ~isempty(outputPath) && ~exist(outputPath, 'dir')
                mkdir(outputPath);
            end

            try
                % Generate ODE file using IQMtools
                IQMcreateODEfile(obj.iqmModel, obj.odeFile);
                fprintf('ODE m-file generated: %s.m\n', obj.odeFile);

            catch ME
                error('IQMExporter:ODEGenerationError', ...
                    'Error generating ODE file: %s', ME.message);
            end
        end

        function compileMEX(obj, filename)
            % Compile MEX file from ODE m-file
            % Input:
            %   filename - Output filename (without extension)

            if isempty(obj.odeFile) || ~exist(sprintf('%s.m', obj.odeFile), 'file')
                warning('IQMExporter:NoODEFile', ...
                    'ODE file not found. Generating ODE file first...');
                obj.generateODEFile();
            end

            % Determine MEX file path
            if nargin >= 2 && ~isempty(filename)
                if PathHelper.isAbsolutePath(filename)
                    obj.mexFile = filename;
                else
                    if isempty(obj.outputDir)
                        obj.mexFile = filename;
                    else
                        obj.mexFile = fullfile(obj.outputDir, filename);
                    end
                end
            else
                % Use model name
                if isempty(obj.outputDir)
                    obj.mexFile = sprintf('%s_mex', obj.model.name);
                else
                    obj.mexFile = fullfile(obj.outputDir, sprintf('%s_mex', obj.model.name));
                end
            end

            try
                % Compile MEX file using IQMtools
                IQMmakeMEXmodel(obj.iqmModel, obj.mexFile);
                fprintf('MEX file compiled: %s\n', obj.mexFile);

            catch ME
                warning('IQMExporter:MEXCompilationError', ...
                    'Error compiling MEX file: %s', ME.message);
            end
        end

        function stdOdeFile = generateStandardODEFile(obj, filename)
            % Generate MATLAB standard ODE solver compatible m-file
            % This file can be used directly with ode15s, ode45, etc.
            %
            % Input:
            %   filename - Output filename (without extension)
            %
            % Usage of generated file:
            %   [t, y] = ode15s(@model_ode_std, tspan, y0, [], p);
            %   where p is the parameter vector

            if isempty(obj.model)
                error('IQMExporter:NoModel', 'No biological model loaded');
            end

            % Determine output file path
            if nargin >= 2 && ~isempty(filename)
                if PathHelper.isAbsolutePath(filename)
                    stdOdeFile = filename;
                else
                    if isempty(obj.outputDir)
                        stdOdeFile = filename;
                    else
                        stdOdeFile = fullfile(obj.outputDir, filename);
                    end
                end
            else
                % Use model name with _ode_std suffix
                if isempty(obj.outputDir)
                    stdOdeFile = sprintf('%s_ode_std', obj.model.name);
                else
                    stdOdeFile = fullfile(obj.outputDir, sprintf('%s_ode_std', obj.model.name));
                end
            end

            % Open file for writing
            fid = fopen([stdOdeFile '.m'], 'w');
            if fid == -1
                error('IQMExporter:FileError', 'Cannot open file for writing: %s.m', stdOdeFile);
            end

            try
                modelName = obj.model.name;
                [~, funcName, ~] = fileparts(stdOdeFile);

                % Collect all parameters
                allParamNames = {};
                allParamVals = [];
                if ~isempty(obj.paramTable)
                    allParamNames = obj.paramTable.ParamName;
                    allParamVals = obj.paramTable.ParamValue;
                end
                % Add input parameters
                for i = 1:length(obj.model.inputs)
                    input = obj.model.inputs{i};
                    pVals = input.getParameterValues();
                    pFields = fieldnames(pVals);
                    for j = 1:length(pFields)
                        allParamNames{end+1, 1} = pFields{j};
                        allParamVals(end+1, 1) = pVals.(pFields{j});
                    end
                end
                % Add inhibitor parameters
                for i = 1:length(obj.model.inhibitors)
                    inhibitor = obj.model.inhibitors{i};
                    pVals = inhibitor.getParameterValues();
                    pFields = fieldnames(pVals);
                    for j = 1:length(pFields)
                        allParamNames{end+1, 1} = pFields{j};
                        allParamVals(end+1, 1) = pVals.(pFields{j});
                    end
                end

                % Get state variable names
                if ~isempty(obj.stateTable)
                    stateNames = obj.stateTable.StateName;
                else
                    stateNames = {};
                end

                % Write file header
                fprintf(fid, 'function dydt = %s(t, y, p)\n', funcName);
                fprintf(fid, '%%%% %s - MATLAB Standard ODE Solver Compatible ODE Function\n', funcName);
                fprintf(fid, '%%\n');
                fprintf(fid, '%% Generated by ODE Model Creator\n');
                fprintf(fid, '%% Model: %s\n', modelName);
                fprintf(fid, '%% Date: %s\n', datestr(now));
                fprintf(fid, '%%\n');
                fprintf(fid, '%% Usage:\n');
                fprintf(fid, '%%   p = %s(''parameters'');  %% Get default parameters\n', funcName);
                fprintf(fid, '%%   y0 = %s(''initialvalues'');  %% Get default initial values\n', funcName);
                fprintf(fid, '%%   [t, y] = ode15s(@(t,y) %s(t, y, p), [0 1000], y0);\n', funcName);
                fprintf(fid, '%%\n');
                fprintf(fid, '%% State Variables (%d):\n', length(stateNames));
                for i = 1:length(stateNames)
                    fprintf(fid, '%%   y(%d) = %s\n', i, stateNames{i});
                end
                fprintf(fid, '%%\n\n');

                % Handle special calls for metadata
                fprintf(fid, '%% Handle metadata requests\n');
                fprintf(fid, 'if nargin == 1 && ischar(t)\n');
                fprintf(fid, '    switch lower(t)\n');
                fprintf(fid, '        case ''parameters''\n');
                fprintf(fid, '            dydt = [%s]'';\n', num2str(allParamVals', '%g '));
                fprintf(fid, '            return;\n');
                fprintf(fid, '        case ''parameternames''\n');
                fprintf(fid, '            dydt = {''%s''}'';\n', strjoin(allParamNames, '''; '''));
                fprintf(fid, '            return;\n');
                fprintf(fid, '        case ''initialvalues''\n');
                if ~isempty(obj.stateTable)
                    fprintf(fid, '            dydt = [%s]'';\n', num2str(obj.stateTable.StateValue', '%g '));
                else
                    fprintf(fid, '            dydt = zeros(%d, 1);\n', length(stateNames));
                end
                fprintf(fid, '            return;\n');
                fprintf(fid, '        case ''statenames''\n');
                fprintf(fid, '            dydt = {''%s''}'';\n', strjoin(stateNames, '''; '''));
                fprintf(fid, '            return;\n');
                fprintf(fid, '        otherwise\n');
                fprintf(fid, '            error(''Unknown request: %%s'', t);\n');
                fprintf(fid, '    end\n');
                fprintf(fid, 'end\n\n');

                % Use default parameters if not provided
                fprintf(fid, '%% Use default parameters if not provided\n');
                fprintf(fid, 'if nargin < 3 || isempty(p)\n');
                fprintf(fid, '    p = [%s]'';\n', num2str(allParamVals', '%g '));
                fprintf(fid, 'end\n\n');

                % Extract state variables
                fprintf(fid, '%% ==========================================\n');
                fprintf(fid, '%% STATE VARIABLES\n');
                fprintf(fid, '%% ==========================================\n');
                for i = 1:length(stateNames)
                    fprintf(fid, '%s = y(%d);\n', stateNames{i}, i);
                end
                fprintf(fid, '\n');

                % Extract parameters
                fprintf(fid, '%% ==========================================\n');
                fprintf(fid, '%% PARAMETERS\n');
                fprintf(fid, '%% ==========================================\n');
                for i = 1:length(allParamNames)
                    fprintf(fid, '%s = p(%d);\n', allParamNames{i}, i);
                end
                fprintf(fid, '\n');

                % Write input/inhibitor variable calculations
                fprintf(fid, '%% ==========================================\n');
                fprintf(fid, '%% INPUT SIGNALS AND INHIBITORS\n');
                fprintf(fid, '%% ==========================================\n');
                for i = 1:length(obj.model.inputs)
                    input = obj.model.inputs{i};
                    % Substitute piecewiseIQM with MATLAB-compatible version
                    eqStr = input.getIQMEquation();
                    eqStr = strrep(eqStr, 'piecewiseIQM', 'piecewise_std');
                    eqStr = strrep(eqStr, 'time', 't');  % Replace 'time' with 't'
                    fprintf(fid, '%s;\n', eqStr);  % Add semicolon
                end
                for i = 1:length(obj.model.inhibitors)
                    inhibitor = obj.model.inhibitors{i};
                    eqStr = inhibitor.getIQMEquation();
                    eqStr = strrep(eqStr, 'piecewiseIQM', 'piecewise_std');
                    eqStr = strrep(eqStr, 'time', 't');  % Replace 'time' with 't'
                    fprintf(fid, '%s;\n', eqStr);  % Add semicolon
                end
                fprintf(fid, '\n');

                % Write reaction rate equations
                fprintf(fid, '%% ==========================================\n');
                fprintf(fid, '%% REACTION RATES\n');
                fprintf(fid, '%% ==========================================\n');
                for i = 1:length(obj.model.reactions)
                    reaction = obj.model.reactions{i};
                    rateEq = reaction.rateEquation;
                    
                    % Remove 'vf = ' or 'vr = ' prefix if present
                    rateEq = regexprep(rateEq, '^\s*v[fr]\s*=\s*', '');
                    
                    % Substitute piecewiseIQM
                    rateEq = strrep(rateEq, 'piecewiseIQM', 'piecewise_std');
                    rateEq = strrep(rateEq, 'time', 't');  % Replace 'time' with 't'
                    
                    fprintf(fid, 'R%d = %s;\n', i, rateEq);
                end
                fprintf(fid, '\n');

                % Write ODEs
                fprintf(fid, '%% ==========================================\n');
                fprintf(fid, '%% DIFFERENTIAL EQUATIONS\n');
                fprintf(fid, '%% ==========================================\n');
                fprintf(fid, 'dydt = zeros(%d, 1);\n', length(stateNames));

                % Build ODE for each state variable based on reaction stoichiometry
                for i = 1:length(stateNames)
                    stateName = stateNames{i};
                    odeTerms = {};

                    for j = 1:length(obj.model.reactions)
                        reaction = obj.model.reactions{j};
                        
                        % Check if this state is a substrate (consumed)
                        isSubstrate = any(strcmp(reaction.substrates, stateName));
                        % Check if this state is a product (produced)
                        isProduct = any(strcmp(reaction.products, stateName));

                        if isSubstrate && ~isProduct
                            odeTerms{end+1} = sprintf('-R%d', j);
                        elseif isProduct && ~isSubstrate
                            odeTerms{end+1} = sprintf('+R%d', j);
                        elseif isSubstrate && isProduct
                            % Both substrate and product (e.g., catalytic)
                            % Net effect is zero, skip
                        end
                    end

                    if isempty(odeTerms)
                        fprintf(fid, 'dydt(%d) = 0;  %% %s\n', i, stateName);
                    else
                        odeStr = strjoin(odeTerms, ' ');
                        if startsWith(odeStr, '+')
                            odeStr = odeStr(2:end);  % Remove leading +
                        end
                        fprintf(fid, 'dydt(%d) = %s;  %% %s\n', i, odeStr, stateName);
                    end
                end
                fprintf(fid, '\n');

                % Add helper function for piecewise
                fprintf(fid, 'end\n\n');
                fprintf(fid, '%% ==========================================\n');
                fprintf(fid, '%% HELPER FUNCTION: piecewise_std\n');
                fprintf(fid, '%% ==========================================\n');
                fprintf(fid, 'function result = piecewise_std(val_if_true, condition, val_if_false)\n');
                fprintf(fid, '    if condition\n');
                fprintf(fid, '        result = val_if_true;\n');
                fprintf(fid, '    else\n');
                fprintf(fid, '        result = val_if_false;\n');
                fprintf(fid, '    end\n');
                fprintf(fid, 'end\n');

                fclose(fid);
                fprintf('Standard ODE file generated: %s.m\n', stdOdeFile);

            catch ME
                if fid ~= -1
                    fclose(fid);
                end
                rethrow(ME);
            end
        end


function scriptFile = generateSimulationScript(obj, filename)
    % generateSimulationScript: MEX와 Standard ODE를 비교하는 시뮬레이션 스크립트 생성
    
    if isempty(obj.model)
        error('IQMExporter:NoModel', 'No biologically loaded model.');
    end

    % 출력 경로 결정 (모델명 기준)
    if nargin < 2 || isempty(filename)
        scriptFile = fullfile(obj.outputDir, sprintf('run_simulation_%s.m', obj.model.name));
    end

    fid = fopen(scriptFile, 'w');
    if fid == -1
        error('IQMExporter:FileError', 'Cannot open file for writing: %s', scriptFile);
    end

    try
        modelName = obj.model.name;
        mexName = sprintf('%s_mex', modelName);
        stdOdeName = sprintf('%s_ode_std', modelName);

        % 1. 헤더 및 경로 설정
        fprintf(fid, '%%%% Simulation Script for %s\n', modelName);
        fprintf(fid, '%% Generated by ODE Model Creator\n');
        fprintf(fid, '%% Compares MEX simulation vs MATLAB Standard ODE solver\n\n');
        
        fprintf(fid, '%% 경로 설정 (MEX 및 모델 파일 위치 자동 감지)\n');
        fprintf(fid, 'scriptDir = fileparts(mfilename(''fullpath''));\n');
        fprintf(fid, 'addpath(scriptDir); cd(scriptDir);\n\n');

        % 2. 데이터 임베딩
        fprintf(fid, '%%%% 1. Model Data\n');
        fprintf(fid, 'modelName = ''%s'';\n', modelName);
        fprintf(fid, 'mexFile = ''%s'';\n', mexName);
        fprintf(fid, 'stdOdeFile = ''%s'';\n\n', stdOdeName);

        % --- 모든 파라미터 수집 ---
        allNames = {};
        allVals = [];

        if ~isempty(obj.paramTable)
            allNames = obj.paramTable.ParamName;
            allVals = obj.paramTable.ParamValue;
        end

        for i = 1:length(obj.model.inputs)
            input = obj.model.inputs{i};
            pValsStruct = input.getParameterValues();
            pFields = fieldnames(pValsStruct);
            for j = 1:length(pFields)
                allNames{end+1, 1} = pFields{j};
                allVals(end+1, 1) = pValsStruct.(pFields{j});
            end
        end

        for i = 1:length(obj.model.inhibitors)
            inhibitor = obj.model.inhibitors{i};
            pValsStruct = inhibitor.getParameterValues();
            pFields = fieldnames(pValsStruct);
            for j = 1:length(pFields)
                allNames{end+1, 1} = pFields{j};
                allVals(end+1, 1) = pValsStruct.(pFields{j});
            end
        end

        fprintf(fid, 'paramNames = {''%s''};\n', strjoin(allNames, '''; '''));
        fprintf(fid, 'paramValues = [%s];\n\n', num2str(allVals', '%g '));

        if ~isempty(obj.stateTable)
            sNames = obj.stateTable.StateName;
            sVals = obj.stateTable.StateValue;
            fprintf(fid, 'stateNames = {''%s''};\n', strjoin(sNames, '''; '''));
            fprintf(fid, 'stateValues = [%s];\n\n', num2str(sVals', '%g '));
        end

        % 3. 시뮬레이션 설정
        fprintf(fid, '%%%% 2. Simulation Settings\n');
        fprintf(fid, 'fprintf(''\\n=== Comparison Simulation: MEX vs Standard ODE ===\\n'');\n');
        fprintf(fid, 'fprintf(''Model: %%s\\n\\n'', modelName);\n\n');
        fprintf(fid, 'tspan = linspace(0, 5000, 500);\n');
        fprintf(fid, 'X0 = stateValues(:)'';\n\n');

        fprintf(fid, '%% +/- 20%% 파라미터 변동 (동일한 random seed 사용)\n');
        fprintf(fid, 'rng(42);  %% 재현성을 위한 고정 시드\n');
        fprintf(fid, 'perturb_range = 0.2;\n');
        fprintf(fid, 'sim_params = paramValues(:)'' .* (1 + (rand(size(paramValues(:)''))-0.5)*2*perturb_range);\n\n');

        % 4. MEX 시뮬레이션
        fprintf(fid, '%%%% 3. MEX Simulation\n');
        fprintf(fid, 'fprintf(''Running MEX simulation...\\n'');\n');
        fprintf(fid, 'mex_success = false;\n');
        fprintf(fid, 'try\n');
        fprintf(fid, '    tic;\n');
        fprintf(fid, '    mex_output = feval(mexFile, tspan, X0, sim_params, []);\n');
        fprintf(fid, '    mex_time = toc;\n');
        fprintf(fid, '    t_mex = mex_output.time;\n');
        fprintf(fid, '    y_mex = mex_output.statevalues;\n');
        fprintf(fid, '    mex_success = true;\n');
        fprintf(fid, '    fprintf(''  MEX completed in %%.3f seconds\\n'', mex_time);\n');
        fprintf(fid, 'catch ME\n');
        fprintf(fid, '    fprintf(''  MEX simulation failed: %%s\\n'', ME.message);\n');
        fprintf(fid, '    t_mex = []; y_mex = [];\n');
        fprintf(fid, 'end\n\n');

        % 5. Standard ODE 시뮬레이션
        fprintf(fid, '%%%% 4. Standard ODE Simulation (ode15s)\n');
        fprintf(fid, 'fprintf(''Running Standard ODE simulation (ode15s)...\\n'');\n');
        fprintf(fid, 'std_success = false;\n');
        fprintf(fid, 'try\n');
        fprintf(fid, '    ode_opts = odeset(''RelTol'', 1e-6, ''AbsTol'', 1e-8);\n');
        fprintf(fid, '    tic;\n');
        fprintf(fid, '    [t_std, y_std] = ode15s(@(t,y) %s(t, y, sim_params(:)), tspan, X0(:), ode_opts);\n', stdOdeName);
        fprintf(fid, '    std_time = toc;\n');
        fprintf(fid, '    std_success = true;\n');
        fprintf(fid, '    fprintf(''  Standard ODE completed in %%.3f seconds\\n'', std_time);\n');
        fprintf(fid, 'catch ME\n');
        fprintf(fid, '    fprintf(''  Standard ODE simulation failed: %%s\\n'', ME.message);\n');
        fprintf(fid, '    t_std = []; y_std = [];\n');
        fprintf(fid, 'end\n\n');

        % 6. 결과 비교 시각화
        fprintf(fid, '%%%% 5. Comparison Visualization\n');
        fprintf(fid, 'if mex_success || std_success\n');
        fprintf(fid, '    figure(''Name'', [''Comparison: '' modelName], ''Position'', [100 100 1400 600]);\n\n');
        
        fprintf(fid, '    %% Subplot 1: MEX Results\n');
        fprintf(fid, '    subplot(1,3,1);\n');
        fprintf(fid, '    if mex_success\n');
        fprintf(fid, '        plot(t_mex, y_mex, ''LineWidth'', 1.2);\n');
        fprintf(fid, '        title(sprintf(''MEX Simulation (%%0.3fs)'', mex_time));\n');
        fprintf(fid, '    else\n');
        fprintf(fid, '        text(0.5, 0.5, ''MEX Failed'', ''HorizontalAlignment'', ''center'');\n');
        fprintf(fid, '        title(''MEX Simulation (Failed)'');\n');
        fprintf(fid, '    end\n');
        fprintf(fid, '    xlabel(''Time''); ylabel(''Concentration'');\n');
        fprintf(fid, '    grid on;\n\n');

        fprintf(fid, '    %% Subplot 2: Standard ODE Results\n');
        fprintf(fid, '    subplot(1,3,2);\n');
        fprintf(fid, '    if std_success\n');
        fprintf(fid, '        plot(t_std, y_std, ''LineWidth'', 1.2);\n');
        fprintf(fid, '        title(sprintf(''Standard ODE (%%0.3fs)'', std_time));\n');
        fprintf(fid, '    else\n');
        fprintf(fid, '        text(0.5, 0.5, ''ODE Failed'', ''HorizontalAlignment'', ''center'');\n');
        fprintf(fid, '        title(''Standard ODE (Failed)'');\n');
        fprintf(fid, '    end\n');
        fprintf(fid, '    xlabel(''Time''); ylabel(''Concentration'');\n');
        fprintf(fid, '    grid on;\n\n');

        fprintf(fid, '    %% Subplot 3: Error Comparison (if both succeeded)\n');
        fprintf(fid, '    subplot(1,3,3);\n');
        fprintf(fid, '    if mex_success && std_success\n');
        fprintf(fid, '        %% Interpolate to common time points for comparison\n');
        fprintf(fid, '        y_mex_interp = interp1(t_mex, y_mex, t_std);\n');
        fprintf(fid, '        rel_error = abs(y_mex_interp - y_std) ./ (abs(y_std) + 1e-10) * 100;\n');
        fprintf(fid, '        semilogy(t_std, mean(rel_error, 2), ''LineWidth'', 1.5);\n');
        fprintf(fid, '        title(''Mean Relative Error (%%)'');\n');
        fprintf(fid, '        xlabel(''Time''); ylabel(''Error (%%)'');\n');
        fprintf(fid, '        grid on;\n');
        fprintf(fid, '        fprintf(''\\nMax relative error: %%.2e%%%%\\n'', max(mean(rel_error, 2)));\n');
        fprintf(fid, '    else\n');
        fprintf(fid, '        text(0.5, 0.5, ''Cannot Compare'', ''HorizontalAlignment'', ''center'');\n');
        fprintf(fid, '        title(''Error Comparison (N/A)'');\n');
        fprintf(fid, '    end\n\n');

        fprintf(fid, '    sgtitle([''Random Parameter Simulation Comparison: '' modelName], ''FontSize'', 14);\n');
        fprintf(fid, 'end\n\n');

        % 7. 성능 요약
        fprintf(fid, '%%%% 6. Performance Summary\n');
        fprintf(fid, 'fprintf(''\\n=== Performance Summary ===\\n'');\n');
        fprintf(fid, 'if mex_success && std_success\n');
        fprintf(fid, '    fprintf(''  MEX Time:          %%.3f seconds\\n'', mex_time);\n');
        fprintf(fid, '    fprintf(''  Standard ODE Time: %%.3f seconds\\n'', std_time);\n');
        fprintf(fid, '    fprintf(''  Speed Ratio:       %%.1fx (MEX is faster)\\n'', std_time/mex_time);\n');
        fprintf(fid, 'end\n');
        fprintf(fid, 'fprintf(''==============================\\n'');\n');

        fclose(fid);
    catch ME
        if fid ~= -1, fclose(fid); end
        rethrow(ME);
    end
end        

        function runFullExport(obj)
            % Run complete export workflow
            % Exports to txtbc, loads into IQMtools, generates ODE and MEX files

            fprintf('\n=== Running Full Export Workflow ===\n\n');

            % Step 1: Export to txtbc
            fprintf('Step 1: Exporting to txtbc format...\n');
            obj.exportToTxtbc();

            % Step 2: Load into IQMtools
            fprintf('\nStep 2: Loading into IQMtools...\n');
            try
                obj.loadIntoIQMtools();
            catch ME
                warning('IQMExporter:IQMtoolsError', ...
                    'Could not load into IQMtools: %s\nSkipping ODE and MEX generation.', ME.message);
                fprintf('\n=== Export Complete (txtbc only) ===\n\n');
                return;
            end

            % Step 3: Generate ODE file
            fprintf('\nStep 3: Generating ODE m-file...\n');
            try
                obj.generateODEFile();
            catch ME
                warning('IQMExporter:ODEError', ...
                    'Could not generate ODE file: %s', ME.message);
            end

            % Step 4: Compile MEX file
            fprintf('\nStep 4: Compiling MEX file...\n');
            try
                obj.compileMEX();
            catch ME
                warning('IQMExporter:MEXError', ...
                    'Could not compile MEX file: %s', ME.message);
            end

            fprintf('\n=== Export Complete ===\n\n');
        end

        function printSummary(obj)
            % Print exporter summary to console

            fprintf('\n=== IQM Exporter Summary ===\n');
            if ~isempty(obj.model)
                fprintf('Model: %s\n', obj.model.name);
            end
            fprintf('Output Directory: %s\n', obj.outputDir);
            fprintf('\nGenerated Files:\n');
            fprintf('  txtbc file: %s\n', obj.txtbcFile);
            fprintf('  ODE file:   %s\n', obj.odeFile);
            fprintf('  MEX file:   %s\n', obj.mexFile);
            fprintf('\nLoaded Tables:\n');
            fprintf('  Parameters: %d\n', height(obj.paramTable));
            fprintf('  State Variables: %d\n', height(obj.stateTable));
            fprintf('============================\n\n');
        end

        function disp(obj)
            % Display method
            obj.printSummary();
        end
    end

    methods (Static, Access = private)
        function result = isAbsolutePath(path)
            % Check if path is absolute
            % Returns: true if absolute, false otherwise

            if ispc
                % Windows: Check for drive letter (C:\) or UNC path (\\server\)
                result = ~isempty(regexp(path, '^[a-zA-Z]:\\', 'once')) || ...
                         startsWith(path, '\\');
            else
                % Unix/Mac: Check for leading /
                result = startsWith(path, '/');
            end
        end
    end
end
