%% Degradation (Active)- Full

% devide cell into chacter and numeric
dat_array = proc(cellfun(@ischar,proc));

% check elements of reaction
num_element   = 3;
len_elements    = length(dat_array);

if len_elements < num_element
    msg = strcat('reaction syntax error (reaction number): ',num2str(ii),'-',proc_type);
    error(msg);
end


% devide array to parts
species = erase(dat_array(1:num_element),{'+','-'});
activators = erase(dat_array(contains(dat_array,'+')),'+');
inhibitors = erase(dat_array(contains(dat_array,'-')),'-');

% iqm preces & species
Process(ii).proc = strcat(species{2},'=>',':','R',num2str(ii));
Process(ii).species = {species{2},species{3}};



% activators --
str_param = [];
str_react = [];
for kk = 1:length(activators)

    new_str1 = strcat('kdeg_',species{2},'_',activators{kk},'*',species{2},'*',activators{kk});
    str_react = strcat(str_react,new_str1,'+');

end
str_react(end) = [];

str_p1 = strcat('vf = (',str_react,')/(');





% inhibitors --
if ~isempty(inhibitors)

    for kk = 1:length(inhibitors)
        str_px = strcat('(','1 + Ki_deg_',species{2},'_',species{3},'_',inhibitors{kk},'*',inhibitors{kk},')*');
        str_p1 = [str_p1 str_px];
    end
    % note '*' -> ')'
    str_p1(end) = ')';

else
    str_p1(end-1:end) = [];
end


Process(ii).rate_eq = str_p1;

for kk = 1:length(activators)
    Process(ii).param{kk} = strcat('kdeg_',species{2},'_',activators{kk});
end
rr = length(Process(ii).param);


Process(ii).param{rr+1} = strcat('Km_',species{2},'_',species{3});

rr = length(Process(ii).param);
for  kk = 1:length(inhibitors)
    Process(ii).param{rr} = strcat('Ki_deg_',species{2},'_',species{3},'_',inhibitors{kk});
    rr = rr+1;
end


