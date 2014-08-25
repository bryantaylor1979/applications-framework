classdef ValueBox_Edit < handle
    properties (SetObservable = true)
        SetButtonWidth = 22;
        Value = '[Multi Text]';
        ObjectHandle
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
           obj = ValueBox_Edit( 'Pos',      Pos, ...
                                'Value',    'Hello');     
           ObjectInspector(obj)
        end
        function RUN(obj)
            
        end
    end
    methods (Hidden = true)
        function obj = ValueBox_Edit(varargin)
            %%
            x = size(varargin,2);
            for  i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.addValueBox(    obj.Pos, ...
                                obj.Value);
        end
        function addValueBox(           obj,Pos,Value)
            %% create a edit box for you to type the desired value
            obj.handles.edit  = uicontrol( 'Style',                'edit', ...
                            'Units',                'pixels', ...
                            'HorizontalAlignment',  'left', ...
                            'String',               Value, ...
                            'Position',             Pos);  
                        
            Pos(1) = Pos(1) + Pos(3);
            Pos(3) = obj.SetButtonWidth;
            obj.addMultiTextButton(Pos)        
        end   
        function h = addMultiTextButton(    obj,Pos)
            %%
            filename = fullfile( matlabroot,'toolbox','matlab','icons','pageicon.gif');
            [X map] = imread(filename);
            icon = ind2rgb(X,map);
            

            % create a pushbutton to confirm the assignment
            h3 = uicontrol( 'Style',                'pushbutton', ...
                            'String' ,              'Set', ...
                            'Units',                'pixels', ...
                            'Callback',             @obj.setEditBox, ...
                            'position',             Pos);
        end
        function setEditBox(varargin)
            %%
            obj = varargin{1}
            disp('hello')
            Value = get(obj.handles.edit,'String');
            Value2write = str2num(Value);
            if isempty(Value2write)
                Value2write = Value;
            end
            obj.Value = Value2write;
        end  
    end
end