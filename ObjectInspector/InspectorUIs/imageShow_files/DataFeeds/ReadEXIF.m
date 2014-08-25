classdef ReadEXIF < handle & ...
                    dynamicprops
    properties (SetObservable = true)
        filename = 'C:\WB_Workshop\Images\AwbTune\imx175_Macbeth_D50_4900K_v368934_181.jpg';
        %Image description expanded
        ev
        mlux
        exp
        ag
        dg
        focus
        gain_r
        gain_b
        ccm
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            %%
            obj = ReadEXIF
            ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            output = exifread(obj.filename);
            names = fieldnames(output)
            for i = 1:max(size(names))
                try
                H = addprop(obj,names{i});
                H.SetObservable = true;
                end
                obj.(names{i}) = output.(names{i})
            end
            output.ImageDescription 
            value = obj.SplitValuePairs(output)
            
            %%
            x = size(value,2)
            for i =1:x
            [param_name,param_value] = obj.ParamNameValue(value{i});
            obj.(param_name) = param_value;
            end
        end
    end
    methods (Hidden = true)
        function [param_name,param_value] = ParamNameValue(obj,value)
            n = findstr(value,'=');
            param_name = value(1:n-1);
            param_value = value(n+1:end);    
            temp = str2num(param_value)
            if not(isempty(temp))
              param_value = temp;  
            end
            param_name = strrep(param_name,' ','');
        end
        function obj = ReadEXIF()
            obj.RUN
        end
        function value = SplitValuePairs(obj, output)
            n = findstr(output.ImageDescription,' ');
            value{1} = output.ImageDescription(1:n(1)-1);
            for i = 1:max(size(n))-1
                value{i+1} = output.ImageDescription(n(i)+1:n(i+1)-1);
            end
            value{max(size(n))} = output.ImageDescription(n(max(size(n))):end);         
        end
    end
end

%%
