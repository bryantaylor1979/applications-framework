classdef ValueBox_PullDown < handle
    properties (SetObservable = true)
        LUT = { 'Example'; ...
                'Example2'};
        paramValue = 'Example';
    end
    properties (Hidden = true, SetObservable = true)
        Pos = [184 222 141 22];
        handles
    end
    methods
        function Example(obj)
           %% 
           close all
           clear classes
           
           %%
           hfig = figure;
           Pos = [184 222 141 22];
           obj = ValueBox_PullDown('Pos',Pos)    
           ObjectInspector(obj)
        end
        function RUN(obj)
            
        end
    end
    methods (Hidden = true)
        function obj = ValueBox_PullDown(varargin)
            %%
            x = size(varargin,2);
            for  i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.handles = obj.addValueBox(  obj.Pos, ...
                                            obj.LUT, ...
                                            obj.paramValue);
        end
        function h = addValueBox(	obj, Pos, LUT, paramValue)
            % create a edit box for you to type the desired value
            n = find(strcmpi(paramValue,LUT));
            h  = uicontrol( 'Style',                'popupmenu', ...
                            'Units',                'pixels', ...
                            'HorizontalAlignment',  'left', ...
                            'String',               '[Multi Text]', ...
                            'Position',             Pos, ...
                            'Value',                n);        
               set(h,       'String',    LUT, ...
                            'Callback', @obj.pulldownUpdate);      
        end   
        function pulldownUpdate(varargin)
            %%
            obj = varargin{1};
            LUT =   get(obj.handles,    'String');
            Value = get(obj.handles,    'Value');
            obj.paramValue = LUT{Value};
        end
    end
end