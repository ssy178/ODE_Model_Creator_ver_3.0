%% Michaelis-Menten - Short

% devide cell into chacter and numeric
dat_array = proc(cellfun(@ischar,proc));

num_element   = 4;
len_elements    = length(dat_array);

if length(dat_array) < num_element
    msg = strcat('reaction syntax error (reaction number): ',num2str(ii),'-',proc_type);
    error(msg);
end


% devide array to parts
species = erase(dat_array(1:4),{'+','-'});
activators = erase(dat_array(contains(dat_array,'+')),'+');
inhibitors = erase(dat_array(contains(dat_array,'-')),'-');

% iqm preces & species
Process(ii).proc = strcat(species{2},'=>',species{3},':','R',num2str(ii));
Process(ii).species = {species{2},species{3},species{4}};


% activators --
str_param = [];
str_react = [];
for kk = 1:length(activators)
    new_str1 = strcat('kc_',species{2},'_',species{3},'_',activators{kk},'*',activators{kk});
    str_react = strcat(str_react,new_str1,'+');
    
    
    new_str2 = strcat(activators{kk});
    str_param = strcat(str_param,new_str2,'_');
    
end
str_react(end) = ')';
str_param(end) = [];


str_p1 = strcat('vf = (',str_react,' * ',species{2},'/(');

% inhibitors --
if ~isempty(inhibitors)
    
    for kk = 1:length(inhibitors)
        str_px = strcat('(','1 + Ki_',species{2},'_',species{3},'_',species{4},'_',inhibitors{kk},'*',inhibitors{kk},')*');
        str_p1 = [str_p1 str_px];
    end
    % note '*' -> ')'
    str_p1(end) = ')';
    
else
    str_p1(end-1:end) = [];
    
end

str_p3 = strcat('-','Vm_',species{3},'_',species{2},' * ',species{3});

% parameter related to activators
Process(ii).rate_eq = [str_p1 str_p3];
for kk = 1:length(activators)
    Process(ii).param{kk} = strcat('kc_',species{2},'_',species{3},'_',activators{kk});
end
rr = length(Process(ii).param);

Process(ii).param{rr+1} = strcat('Vm_',species{3},'_',species{2});

rr = length(Process(ii).param);
for kk = 1:length(inhibitors)
    Process(ii).param{rr+1} = strcat('Ki_',species{2},'_',species{3},'_',species{4},'_',inhibitors{kk});
    rr = rr+1;
end