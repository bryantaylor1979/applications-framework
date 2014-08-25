classdef ObjectToolbar < handle
    properties
        Params = {'Spec'};
        INPUT_OBJ
    end
    properties (Hidden = true)
        handle
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
        end
    end
    methods (Hidden = true)
        function obj = ObjectToolbar(varargin)
            %%
            obj.INPUT_OBJ = varargin{1};
            x = size(varargin,2);
            for i = 2:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            x = max(size(obj.Params));
            for i = 1:x
                obj.handle = obj.CreatePopupMenu(obj.Params{i})  
            end
        end
        function handle = CreatePopupMenu(obj,Param)
            %%
            handle.figure = obj.INPUT_OBJ.handles.figure;
            handle.(Param).control = uicontrol(handle.figure);
            
            set(handle.(Param).control, ...
                                'Style',        'popupmenu',    ...
                                'String',       obj.INPUT_OBJ.([Param,'_LUT']), ...
                                'Position',     [20, 20, 100, 20], ...
                                'Callback',     @(x,y)obj.PopupMenu(Param));
                            
            obj.INPUT_OBJ.addlistener(Param,  'PostSet', @(x,y)obj.PopupMenuUpdate(Param));
        end
        function PopupMenu(varargin)
            %%
            obj = varargin{1};
            Param = varargin{2};  
            %%
            String = get(obj.handle.(Param).control,'String');
            Value = get(obj.handle.(Param).control,'Value');
            obj.INPUT_OBJ.(Param) = String{Value};
        end
        function PopupMenuUpdate(varargin)
            %%
            obj = varargin{1};
            Param = varargin{2};
            %%
            ValueSet = obj.INPUT_OBJ.(Param);
            String = get(obj.handle.(Param).control,'String');
            Value = get(obj.handle.(Param).control,'Value');
            
            %%
            n = find(strcmpi(String,ValueSet));
            set(obj.handle.(Param).control,'Value',n);
        end
    end
end