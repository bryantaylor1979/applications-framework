classdef ValueBox_MultiText < handle
    properties (SetObservable = true)
        SetButtonWidth = 22;
        LUT = { 'Example'; ...
                'Example2'};
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
           obj = ValueBox_MultiText('Pos',Pos)    
           ObjectInspector(obj)
        end
        function RUN(obj)
            
        end
    end
    methods (Hidden = true)
        function obj = ValueBox_MultiText(varargin)
            %%
            x = size(varargin,2);
            for  i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.handles = obj.addValueBox(  obj.Pos, ...
                                            obj.LUT);
        end
        function h = addValueBox(	obj, Pos, LUT)
            %% create a edit box for you to type the desired value
            h  = uicontrol( 'Style',                'edit', ...
                            'Units',                'pixels', ...
                            'HorizontalAlignment',  'left', ...
                            'String',               '[Multi Text]', ...
                            'Position',             Pos);     
            obj.addMultiTextButton(Pos)            
        end   
        function pulldownUpdate(varargin)
            %%
            obj = varargin{1};
            LUT =   get(obj.handles,    'String');
            Value = get(obj.handles,    'Value');
            obj.paramValue = LUT{Value};
        end
        function h = addMultiTextButton(    obj,Pos)
            filename = fullfile( matlabroot,'toolbox','matlab','icons','pageicon.gif');
            [X map] = imread(filename);
            icon = ind2rgb(X,map);
            
            Pos(1) = Pos(1) + Pos(3);
            Pos(3) = obj.SetButtonWidth;
            
            % create a pushbutton to confirm the assignment
            h  = uicontrol( 'Style',                'pushbutton', ...
                            'CDATA' ,               icon, ...
                            'Units',                'pixels', ...
                            'Callback',             @(x,y)obj.runMultiTextBox(obj.LUT), ...
                            'position',             Pos);
        end
        function runMultiTextBox(obj,LUT)
            %%
            uiMultiText('String',LUT);
        end
    end
end