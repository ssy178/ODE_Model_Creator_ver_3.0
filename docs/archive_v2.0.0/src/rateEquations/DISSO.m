%% DISSOCIATION TYPE (C => A + B)


dat_array = proc(cellfun(@ischar,proc));

% check elements of reaction
num_element   = 4;
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
Process(ii).proc    = strcat(species{2},'=>',species{3},'+',species{4},':','R',num2str(ii));
Process(ii).species = {species{2},species{3},species{4}};


str_p1 = strcat('vf = ','kd_',species{2},'_',species{3},'_',species{4}, '* ',species{2},'/(');


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

Process(ii).rate_eq = str_p1;
Process(ii).param{1} = strcat('kd_',dat_array{2},'_',dat_array{3},'_',dat_array{4});

rr = length(Process(ii).param);
for kk =1:length(inhibitors)
    Process(ii).param{rr+1} = strcat('Ki_',species{2},'_',species{3},'_',species{4},'_',inhibitors{kk});
    rr = rr+1;
end


