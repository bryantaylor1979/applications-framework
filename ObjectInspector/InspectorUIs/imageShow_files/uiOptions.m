classdef uiOptions < handle
    properties (SetObservable = true)
        Customer = 'KTouch';
    end
    properties (Hidden = true, SetObservable = true)

        Customer_LUT = {'Samsung'; ...
                        'KTouch'};       
    end
    properties (Hidden = true)
        handles        
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = uiOptions
            ObjectInspector(obj)
        end
    end
    methods (Hidden = true)
        function obj = uiOptions(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) = varargin{i+1};
            end
            
            %% Figure
            obj.handles.figure = figure(    'Visible',      'off', ...
                                            'Menubar',      'none', ...
                                            'Name',         'Preferences', ...
                                            'Position',     [953   869   356   138], ...
                                            'NumberTitle',  'off');
            set(obj.handles.figure,         'ResizeFcn',    @(x,y)obj.Resize(true));
            
            val = 0.9;
            set(obj.handles.figure,'Color', [val, val, val]);
            
            %% Header
            obj.handles.Header = uicontrol(obj.handles.figure);
            obj.handles.Header1 = uicontrol(obj.handles.figure);
            val = 0.8;
            set(obj.handles.Header, 'Style',                'text', ...
                                    'BackgroundColor',      [val, val, val], ...
                                    'Position',             [10 380 540 30]);
            set(obj.handles.Header1, 'Style',                'text', ...
                                    'BackgroundColor',      [val, val, val], ...
                                    'Position',             [19 384 201 17], ...
                                    'FontName',             'Times Roman', ...
                                    'String',               'Custom Viewer Preferences', ...
                                    'FontSize',             9, ...
                                    'FontWeight',           'bold', ...
                                    'HorizontalAlignment',  'left');
                                
            %% Customer Selection
            
            obj.handles.Param1 = uicontrol(obj.handles.figure);
            obj.handles.Param1_pulldown = uicontrol(obj.handles.figure);
            %%
            fontsize = 9;
            set(obj.handles.Param1, 'Style',                'text', ...
                                    'BackgroundColor',      [0.9, 0.9, 0.9], ...
                                    'Position',             [20 337.45 540 30], ...
                                    'FontName',             'Times Roman', ...
                                    'String',               'Customer:', ...
                                    'FontSize',             fontsize, ...
                                    'FontWeight',           'normal', ...
                                    'HorizontalAlignment',  'left');   
                                

            n = find(strcmpi(obj.Customer,obj.Customer_LUT));
            set(obj.handles.Param1_pulldown, ...
                                    'Style',                'popupmenu', ...
                                    'BackgroundColor',      [0.9, 0.9, 0.9], ...
                                    'Position',             [83 341.45 106 30], ...
                                    'FontName',             'Times Roman', ...
                                    'String',               obj.Customer_LUT, ...
                                    'FontSize',             fontsize, ...
                                    'Value',                n, ...
                                    'FontWeight',           'normal', ...
                                    'HorizontalAlignment',  'left'); 
                                
            %% OK and Cancel Button. 
            obj.handles.OK = uicontrol(obj.handles.figure);
            obj.handles.Cancel = uicontrol(obj.handles.figure);
            set(obj.handles.Cancel,     'String',   'Cancel', ...
                                        'Position', [460 10 90 26], ...
                                        'Callback', @obj.CancelCallback );
            set(obj.handles.OK,         'String',   'OK', ...
                                        'Position', [364 10 90 26], ...
                                        'Callback', @obj.OkCallback);
            obj.Resize(false);
            set(obj.handles.figure,     'Visible',      'on');
        end
        function CancelCallback(varargin)
            %%
            obj = varargin{1};
            close(obj.handles.figure);
        end
        function OkCallback(varargin)
            %%
            obj = varargin{1};
            n = get(obj.handles.Param1_pulldown,'Value');
            obj.Customer = obj.Customer_LUT{n};
            close(obj.handles.figure);
        end
        function Resize(varargin)
            %%
            obj = varargin{1};
            Lock = varargin{2};
            
            %%
            if Lock == false
                Position = get(obj.handles.figure,'Position');
                Height = Position(4);
                Width = Position(3);
                % [10 380 540 30]
                set(obj.handles.Header,         'Position',         [10 Height-40 Width-20 30]);
                % [19 384 201 17]
                set(obj.handles.Header1,        'Position',         [19 Height-36 201 17]);
                % [20 337.45 540 30]
                set(obj.handles.Param1,         'Position',         [20 Height-93 540 30]);
                % [83 341.45 106 30]
                set(obj.handles.Param1_pulldown,'Position',         [83 Height-89 106 30]);
                % [364 10 90 26]
                set(obj.handles.OK,             'Position',         [Width-195 10 90 26]);
                set(obj.handles.Cancel,         'Position',         [Width-99 10 90 26]);
            else
                Position = get(obj.handles.figure,'Position');
                set(obj.handles.figure,'Position',[Position(1)   Position(2)   356   138]);
            end
        end
    end
end