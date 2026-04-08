
%% Model Creator master

clear;
clc;
close all;


% add source file folder
addpath(genpath('.\src'))
addpath(genpath('.\user files'))

rootwd = pwd;

%% loading a model file

% (**) Provide your input file
[file_name,path,indx] = uiputfile({'.\user files\*.xlsx'});


sheets = sheetnames(file_name);
map_dat = {'map','Input','Inhibitor','readout'};
missing_dat = map_dat(~ismember(lower(map_dat),lower(sheets)));
if ~isempty(missing_dat)
    msg = strcat(missing_dat,': missing');
    disp(msg)
    error('data missing')
end
inputs  = readcell(file_name,'Sheet','Input');
drugs   = readcell(file_name,'Sheet','Inhibitor');
readout = readcell(file_name,'Sheet','readout');
Reactions   = readcell(file_name,'Sheet','map');


% model input
if ~isempty(inputs)
    for ii = 1:size(inputs,1)
        str = inputs{ii,1};
        val = inputs{ii,2};
        tt = inputs{ii,3};
        input_cont{ii} = {str,strcat(str,'_0'),val,strcat(str,'_on'),tt};
    end
else
    input_cont = {};
end



% drug input
if isempty(drugs)
    % Model inhibitors (independant inputs)
    inhibitor.name = {};
    inhibitor.defaultvalue = {};
else
    % Model inhibitors (independant inputs)
    inhibitor.name = drugs(:,1);
    inhibitor.defaultvalue = drugs(:,2);
end

% drug input
if ~isempty(drugs)
    for ii = 1:size(drugs,1)
        str = drugs{ii,1};
        val = drugs{ii,2};
        tt = drugs{ii,3};
        drug_cont{ii} = {str,strcat(str,'_0'),val,strcat(str,'_on'),tt};
    end
else
    drug_cont = {};
end


% (TO-DO)readout (variables
% Model readout variables
% e.g) MET_tot = MET + pMET
%{{'Raf_total','aRaf','aRafuAKT','Raf'};
%{'Ras_total','aRas','Ras'}};
if ~isempty(readout)
    for ii = 1:size(readout,1)
        array = readout(ii,:);
        readout_variables{ii} = array(cellfun(@ischar,array));
    end
else
    readout_variables = {};
end

% model output fold
prompt = ['Change the Model Name (type a new name here)? ',newline,'==>  '];
str = input(prompt,'s');

if isempty(str)
    model_name_str  = strsplit(file_name,{'.', '\'});
    model_name      = model_name_str{1};
    model_dir       = strcat(rootwd,'\user files\', model_name);
    
else
    model_dir       = strcat(rootwd,'\user files\',str);
    model_name      = str;
end

mkdir(model_dir);
addpath(model_dir);


%%
generate_RateEquation_update

% generate a state table
checking_StateVariables

% generate a parameter table
checking_Parameters


disp({'Now parameter table and state-variable table were generated in your model directory.';'So, you can edit the values by hand.'});
%generate_IQM_txtbc
