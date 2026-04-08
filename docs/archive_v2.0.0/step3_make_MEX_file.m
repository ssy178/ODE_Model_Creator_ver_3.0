%% This is a first cell that clears workspace and memory
% Press Ctrl+enter to evaluate it

% modify the directory that contain IQMtools
run('C:\IQMtools V1.2.2.2\installIQMtools.m')

% %%
% model_name = 'Src_Network_Model';
% %addpath(strcat(pwd,'\',model_name))
% addpath(genpath(strcat(pwd,'/network_model')));


%% Load the CellCycle.txt model
my_model = IQMmodel(strcat(model_dir,'\', model_name, '.txtbc'));
my_model=IQMeditBC(my_model)

%% Create a MATLAB ODE m-file from the IQMmodel
IQMcreateODEfile(my_model,strcat(model_dir, '\', model_name, '_ode'))


%% Create MEX simulation function
cd(model_dir)
IQMmakeMEXmodel(my_model, strcat(model_name,'_mex'))
cd(rootwd)


%% parameter tables

para_vals=eval(strcat(model_name, '_mex(''parametervalues'')'))
para_names=eval(strcat(model_name, '_mex(''parameters'')'))
tbl_param_vals = table(para_vals, 'RowNames', para_names)

% writetable(tbl_param_vals,strcat(model_name,'_param.xlsx'),'WriteRowNames',true)
% tbl_param_vals_new = readtable(strcat(model_name,'_param.xlsx'));

%% initial value/total amount

initial_vals=eval(strcat(model_name,'_mex()'));
state_names=eval(strcat(model_name,'_mex(''states'')'));
tbl_initials = table(initial_vals,'RowNames',state_names);

