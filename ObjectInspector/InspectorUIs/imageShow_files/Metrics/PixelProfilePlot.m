classdef PixelProfilePlot < handle & ...
                        FeederObject
    properties (Hidden = true, SetObservable = true)
        Visible = true
        Type
        imageIN
    end
    properties (Hidden = true)
        handles 
    end
    methods
        function obj = RUN(varargin)
            obj = varargin{1};
            set(obj.handles.red,'YDATA',obj.imageIN.image(:,1));
            set(obj.handles.green,'YDATA',obj.imageIN.image(:,2));
            set(obj.handles.blue,'YDATA',obj.imageIN.image(:,3));
        end
    end
    methods (Hidden = true)
        function obj = PixelProfilePlot(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end
            obj.ClassType = 'line';
            obj.LinkObjects; 
            obj.imageIN = obj.InputObject.imageOUT_line;
            obj.plot(obj.Visible);
            obj.addlistener('Visible','PostSet',@obj.UpdateVisiblity);
        end
        function plot(obj,Visible)
            if Visible == true
                obj.handles.figure = figure('Visible','on');
            else
                obj.handles.figure = figure('Visible','off');
            end
            obj.handles.red = plot(obj.imageIN.image(:,1),'r'); hold on;
            obj.handles.green = plot(obj.imageIN.image(:,2),'g'); hold on;
            obj.handles.blue = plot(obj.imageIN.image(:,3),'b'); hold on;
            set(obj.handles.figure,'Name','Pixel Profile');
            set(obj.handles.figure,'NumberTitle','off');
            xlabel('Pixel Distance');
            ylabel('Pixel Val (RGB)');
        end
        function UpdateVisiblity(varargin)
            obj = varargin{1};
            if obj.Visible == true
                set(obj.handles.figure,'Visible','on');
            else
                set(obj.handles.figure,'Visible','off');
            end
        end
    end
end