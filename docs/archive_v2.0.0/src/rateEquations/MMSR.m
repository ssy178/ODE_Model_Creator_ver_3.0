%% Michaelis-Menten - Short (Reverse/Backward)

% devide cell into chacter and numeric
dat_array = proc(cellfun(@ischar,proc));


% check elements of reaction
num_element   = 3;
len_elements    = length(dat_array);

if length(dat_array) < num_element
    msg = strcat('reaction syntax error (reaction number): ',num2str(ii),'-',proc_type);
    error(msg);
end

% devide array to parts
species = erase(dat_array(1:3),{'+','-'});
activators = erase(dat_array(contains(dat_array,'+')),'+');
inhibitors = erase(dat_array(contains(dat_array,'-')),'-');


Process(ii).proc = strcat(species{2},'=>',species{3},':','R',num2str(ii));
Process(ii).species = {species{2},species{3}};

str_p1 = strcat('vf = ','Vm_',species{2},'_',species{3},' * ',species{2},'/(');

% inhibitors --
if ~isempty(inhibitors)

    for kk = 1:length(inhibitors)
        str_px = strcat('(','1 + Ki_',species{2},'_',species{3},'_',inhibitors{kk},'*',inhibitors{kk},')*');
        str_p1 = [str_p1 str_px];
    end
    % note '*' -> ')'
    str_p1(end) = ')';

else
    str_p1(end-1:end) = [];

end

Process(ii).rate_eq = str_p1;
Process(ii).param{1} = strcat('Vm_',species{2},'_',species{3});

rr = length(Process(ii).param);
for kk = 1:length(inhibitors)
    Process(ii).param{rr+1} = strcat('Ki_',species{2},'_',species{3},'_',inhibitors{kk});
    rr = rr+1;
end

