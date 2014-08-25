classdef Batcher < handle
    properties (SetObservable = true)
        ParameterRecord = true %Log parameter described in Params2Log
        RemoveFailed = true
        ClassName
        ParamName  
        Value
        Values
        Progress = [0,10]
        TotalInterations = 0;
        SuccessfullInterations = 0;
        FailedInterations = 0;
        Params2Log = {  'RedEnergy'; ...
                        'GreenEnergy'; ...
                        'BlueEnergy'};
        ObjHandle
        DATASET = dataset([])
    end
    properties (Hidden = true) 
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            WB_Sim = WB_Simulator;
            ObjectInspector(WB_Sim)
            Values = {  'C:\ISP\awb\024_imx105.raw'; ...
                        'C:\ISP\awb\025_imx105.raw'; ...
                        'C:\ISP\awb\030_imx105.raw'};
                    
            obj = Batcher(  'ObjHandle',     WB_Sim, ...
                            'ParamName',    'input_filename', ...
                            'Values',        Values)
            ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            x = max(size(obj.Values));
            y = max(size(obj.Params2Log));
            obj.TotalInterations = x;
            obj.SuccessfullInterations = 0;
            obj.FailedInterations = 0;
            obj.Progress = [0,x];
            Pass = true;
            for i = 1:x % x
                obj.Value = obj.Values{i};
                obj.ObjHandle.(obj.ParamName) = obj.Value;
                try
                    obj.ObjHandle.RUN;
                    obj.SuccessfullInterations = obj.SuccessfullInterations + 1;
                    Pass = true;
                catch
                    obj.FailedInterations = obj.FailedInterations + 1; 
                    Pass = false;
                end
                obj.Progress = [i,x];
                drawnow;
                
                % Log parameters
                for j = 1:y
                    if Pass == true
                        %%
                        if isnumeric(obj.ObjHandle.(obj.Params2Log{j}))
                            Values(j).values(i) = obj.ObjHandle.(obj.Params2Log{j});
                        else
                            Values(j).values{i} = obj.ObjHandle.(obj.Params2Log{j});
                        end
                        else
                        if isnumeric(obj.ObjHandle.(obj.Params2Log{j}))
                            Values(j).values(i)  = NaN;    
                        else
                            Values(j).values{i} = 'N/A';
                        end
                    end
                end
                if Pass == true
                    PASSED{i,1} = 'PASSED';
                else
                    PASSED{i,1} = 'FAILED';
                end
            end
            %%
            if obj.ParameterRecord == true
                %%
                [x,p] = size(obj.Values);
                if not(p == 1)
                Names = rot90(obj.Values);
                else
                Names = obj.Values;    
                end
                DATASET = dataset({Names,obj.ParamName});
                for j = 1:y
                    DATASET = [DATASET,dataset({Values(j).values(:) ,obj.Params2Log{j}})];
                end
                obj.DATASET = [DATASET,dataset({PASSED,'PASSED'})];
            end
            if obj.RemoveFailed == true
                %%
                n = find(strcmpi(obj.DATASET.PASSED,'PASSED'));
                obj.DATASET = obj.DATASET(n,:);
            end
        end
    end
    methods (Hidden = true)
        function obj = Batcher(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            %%
            obj.ClassName = class(obj.ObjHandle);
        end
    end
end