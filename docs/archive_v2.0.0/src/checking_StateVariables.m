%% checking_StateVariable

% variables for IQM
if ~isempty(readout_variables)
    
    for ii = 1:length(readout_variables)
        array = readout_variables{ii};
        
        str_p1 = strcat(array{1},'=');
        for kk = 2:length(array)
            str_px = strcat(array{kk},'+');
            str_p1 = [str_p1 str_px];
        end
        
        str_p1(end)=[];
        iqm_variables{ii}=str_p1;
    end
    
else
    iqm_variables = {};
end

% State variables for IQM 
% Step 1: remove duplicated state variables
species_all = {};
for ii = 1:size(Reactions,1)
    for jj = 1:length(Process(ii).species)
        species_all = [species_all, Process(ii).species(jj)];
    end
end

% unique state variables
species_unique(:,1) = unique(species_all);



 
% Step 2: Remove systems inputs from the state variable list
input_names = {};
for ii = 1:length(input_cont)
    input_names{ii} = input_cont{ii}{1};
end


input_name_id = ismember(species_unique, input_names);
species_unique(input_name_id) = [];


%% Checking missing state variables

Process_cell = struct2cell(Process);
iqm_proc(:,1) = Process_cell(1,1,:);

delimiter = cell(size(iqm_proc));
delimiter(:) = {':'};
str_1 = cellfun(@strsplit,iqm_proc,delimiter,'UniformOutput',false);
str_2 = cellfun(@(x) x{1},str_1,'UniformOutput',false);

str_3 = [];
for ii = 1:length(str_2)
    str_3 = [str_3;split(str_2{ii},["+","=>",':'])];
end
str_4 = unique(str_3);
str_4(cellfun(@isempty,str_4))=[];


% find undefined state variable
unident_states = species_unique(~ismember(species_unique,str_4));
if ~isempty(unident_states)
    errormsg = strcat('State variabes not defined :',{' '},unident_states);
    disp(errormsg)
    error('Undefined state variable(s)')
end


%%

% Step 3: generate an state variables table 
state_x0 = zeros(size(species_unique));
state_tbl = table(species_unique, state_x0);

% if exist(strcat(model_dir,'\table_statevariable.xlsx'),'file')
%     disp(strcat('[',strcat(model_name,'\table_statevariable.xlsx]'),' already exist'))
% else
    writetable(state_tbl,strcat(model_dir,'\table_statevariable.xlsx'), 'WriteVariableNames', false)
% end

