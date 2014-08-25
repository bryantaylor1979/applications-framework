%% 
function unix_wrapper(varargin)
%matlabpath(pathdef_bryan);
x = size(varargin,2);
for i = 1:x
    value = varargin{i};
    val = str2num(value);
    
    if isempty(val)
        str = ['''',value,''''];
    elseif or(strcmpi(value,'true'), strcmpi(value,'false'))
        str = value;
    else
        str = num2str(val);
    end
    if i == 1
        string = [str];
    else
        string = [string,', ',str];
    end
end
string = ['imx175n_DeltaC_Compare(',string,');'];
obj = eval(string);
%obj = imx175n_DeltaC_Compare(   'Root','/projects/IQ_tuning_data/bgentles/run/');
%obj.RUN();
end