classdef ValueBox_Progress < handle
    properties (SetObservable = true)
        FigureHandle
        FractionComplete = 40;
        paramValue = 'Example';
    end
    properties (Hidden = true, SetObservable = true)
        Pos = [184 222 141 22];
        IMAGEBASE
        handles
    end
    methods
        function Example(obj)
           %% 
           close all
           clear classes
           
           %
           hfig = figure;
           Pos = [184 222 141 22];
           obj = ValueBox_Progress( 'Pos',          Pos, ...
                                    'FigureHandle', hfig)   
           
           %%
           obj.FractionComplete = 32;
           
           %%
           ObjectInspector(obj)
        end
        function RUN(obj)
        end
    end
    methods (Hidden = true)
        function obj = ValueBox_Progress(varargin)
            %%
            x = size(varargin,2);
            for  i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.handles.value = obj.addValueBox(    obj.Pos, ...
                                                    obj.paramValue);
            obj.AddText();
        end
        function h = addValueBox(	obj, Pos, LUT, paramValue)
            %% create a edit box for you to type the desired value
            
            Color = get(obj.FigureHandle,'Color');
            h = axes(   'Units','pixels', ...
                        'Position', Pos, ...
                        'Visible', 'off');
                    
            Color = [0.95,0.95,0.95];
            obj.IMAGEBASE(1:10,1:100,1) =  Color(1);
            obj.IMAGEBASE(1:10,1:100,2) =  Color(2);
            obj.IMAGEBASE(1:10,1:100,3) =  Color(3);
            
            IMAGE = obj.IMAGEBASE;
            IMAGE(1:10,1:obj.FractionComplete,1) = 1;
            IMAGE(1:10,1:obj.FractionComplete,2) = 0;
            IMAGE(1:10,1:obj.FractionComplete,3) = 0;
            
            obj.handles.image = imagesc(IMAGE,'Parent',h);
            set(h,  'Visible','on', ...
                    'XTick',  [], ...
                    'YTick',  []);
            
            obj.addlistener( 'FractionComplete', 'PostSet', @obj.pulldownUpdate)
        end  
        function AddText(obj)
            %%
            obj.handles.text = text(    'Position', [41,7.5,0], ...
                                        'FontWeight', 'bold', ...
                                        'String',    [num2str(obj.FractionComplete),'%']);
        end
        function pulldownUpdate(varargin)
            %%
            obj = varargin{1};
            IMAGE = obj.IMAGEBASE;
            IMAGE(1:10,1:obj.FractionComplete,1) = 1;
            IMAGE(1:10,1:obj.FractionComplete,2) = 0;
            IMAGE(1:10,1:obj.FractionComplete,3) = 0;
            set(obj.handles.image,'CData',IMAGE);
            set(obj.handles.text,'String', [num2str(obj.FractionComplete),'%'])
        end
    end
end