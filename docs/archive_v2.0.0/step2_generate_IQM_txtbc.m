%% Caution
% You must keep the previous variables in the workspace to use in this part

%% load variable that is modified by hand
IQM_statevar = readtable(strcat(model_dir, '\table_statevariable.xlsx'));
IQM_statevar.Properties.VariableNames = {'Unique_Species', 'state_val'};

IQM_paramvar = readtable(strcat(model_dir,'\table_parameter.xlsx'), 'ReadVariableNames', false);
IQM_paramvar.Properties.VariableNames = {'Param_name', 'param_val'};

%% IQM TEXT Formatting

C = strsplit(model_name,'/');
f_name = C{end};
fileID = fopen(strcat(model_dir, '/', model_name, '.txtbc'),'w');


fprintf(fileID,'********** MODEL NAME');
fprintf(fileID,'\n\n');

% model name
fprintf(fileID,model_name);


fprintf(fileID,'\n\n');
fprintf(fileID,'********** MODEL NOTES');
fprintf(fileID,'\n\n');



fprintf(fileID,'\n\n');
fprintf(fileID,'********** MODEL STATE INFORMATION');
fprintf(fileID,'\n\n');


% initial values
for ii = 1:size(IQM_statevar,1)
    str_x0 = strcat(IQM_statevar.Unique_Species{ii},'(0) = ',{' '},num2str(IQM_statevar.state_val(ii)));
    fprintf(fileID,'%-20s\n',str_x0{1});
end



fprintf(fileID,'\n\n');
fprintf(fileID,'********** MODEL PARAMETERS');
fprintf(fileID,'\n\n');

    
% parameter values
for ii = 1:size(IQM_paramvar,1)
    str_par = strcat(IQM_paramvar.Param_name{ii},' = ',{' '},num2str(IQM_paramvar.param_val(ii)));
    fprintf(fileID,'%-20s\n',str_par{1});
end


fprintf(fileID,'\n\n');
fprintf(fileID,'%% input parameters \n');
fprintf(fileID,'\n\n');

for ii = 1:length(input_cont)
    str_input_1 = strcat(input_cont{ii}{2},' = ',{' '},num2str(input_cont{ii}{3}));
    fprintf(fileID,'%-20s\n',str_input_1{1});
    str_input_2 = strcat(input_cont{ii}{4},' = ',{' '},num2str(input_cont{ii}{5}));
    fprintf(fileID,'%-20s\n',str_input_2{1});
end

fprintf(fileID,'\n\n');
fprintf(fileID,'%% drug input parameters  \n');
fprintf(fileID,'\n\n');

for ii = 1:length(drug_cont)
    str_input_1 = strcat(drug_cont{ii}{2},' = ',{' '},num2str(drug_cont{ii}{3}));
    fprintf(fileID,'%-20s\n',str_input_1{1});
    str_input_2 = strcat(drug_cont{ii}{4},' = ',{' '},num2str(drug_cont{ii}{5}));
    fprintf(fileID,'%-20s\n',str_input_2{1});
end



fprintf(fileID,'\n\n');
fprintf(fileID,'********** MODEL VARIABLES');
fprintf(fileID,'\n\n');



% readout variables
if ~isempty(iqm_variables)
    for ii = 1:length(iqm_variables)
        str_modelvar = iqm_variables{ii};
        fprintf(fileID,strcat(str_modelvar,' ',' \n'));
    end    
    
    fprintf(fileID,' \n');
end

fprintf(fileID,'\n\n');
fprintf(fileID,'%% model input parameters  \n');
fprintf(fileID,'\n\n');

% the model inputs
for ii = 1:length(input_cont)
    model_in = input_cont{ii};
    str_modelinput = strcat(model_in{1},'= ',{' '},model_in{2},'*piecewiseIQM(1,ge(time,',model_in{4},'),0) \n');
    fprintf(fileID,str_modelinput{1});
end


fprintf(fileID,'\n\n');
fprintf(fileID,'%% drug input parameters  \n');
fprintf(fileID,'\n\n');


% the model inputs
for ii = 1:length(drug_cont)
    drug_in = drug_cont{ii};
    str_modelinput = strcat(drug_in{1},'= ',{' '},drug_in{2},'*piecewiseIQM(1,ge(time,',drug_in{4},'),0) \n');
    fprintf(fileID,str_modelinput{1});
end




fprintf(fileID,'\n\n');
fprintf(fileID,'********** MODEL REACTIONS');
fprintf(fileID,'\n\n');

for ii = 1:length(Process)
    
    fprintf(fileID,'%-20s\n',Process(ii).proc);
    fprintf(fileID,'%-20s\n',Process(ii).rate_eq);
    fprintf(fileID,'\n\n');
end



fprintf(fileID,'\n\n');
fprintf(fileID,'********** MODEL FUNCTIONS');
fprintf(fileID,'\n\n');


fprintf(fileID,'\n\n');
fprintf(fileID,'********** MODEL EVENTS');
fprintf(fileID,'\n\n');


fprintf(fileID,'\n\n');
fprintf(fileID,'********** MODEL MATLAB FUNCTIONS');
fprintf(fileID,'\n\n');


fclose(fileID);