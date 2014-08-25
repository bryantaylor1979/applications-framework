classdef imscrollpanel_custom < handle
    properties (SetObservable = true)
        EnablePan = false
        VisibleLocation = [NaN, NaN];
        Zoom_Factor = 1;
        Bottom_Border_Size = 23;
        Top_Border_Size = 23;  %conflict with toolbar. 68 if toolbar is on 23 without.
        FigMonitor_OBJ
        Mouse_StartPos = [NaN, NaN];
        Image_StartPos = [NaN, NaN];
        Mouse_CurrentPos = [NaN, NaN];
        Mouse_DiffPos = [NaN, NaN];
        Image_CurrentPos = [NaN, NaN];
        Mouse_LastPos = [NaN, NaN];
    end
    properties (Hidden  = true)
        handles
        LUT = [2,5,10,15,20,30,37,50,60,80,100,125,150,175,200,300,500,700,1000,2000,3000,5000];
    end
    methods (Hidden = false)
        function Example(obj)
            %%
            close all
            clear classes
            
            image = imread('C:\Users\bryant\Desktop\Purple Cast Luffy\for JIRA\IMAG0061.bmp');
            fHandle = figure;
            imHandle = imshow(image);
            figMonitor_OBJ = CurrentPostionMonitor(fHandle);
            obj = imscrollpanel_custom(fHandle, imHandle, figMonitor_OBJ, ...
                                                    'Zoom_Factor',              1.2, ...
                                                    'Bottom_Border_Size',       23, ...
                                                    'Top_Border_Size',          23);
            ObjectInspector(obj);
        end
        function Zoom_StepIn(obj)
            Mag = obj.handles.zoomapi.getMagnification();
            Diff = abs(obj.LUT - Mag*100);
            n = find(min(Diff) == Diff);
            x = size(obj.LUT,2);
            if n < x
                obj.Zoom_Factor = obj.LUT(n+1)/100;
            end 
            obj.VisibleLocation = round(obj.handles.zoomapi.getVisibleLocation());
        end
        function Zoom_StepOut(obj)
            Mag = obj.handles.zoomapi.getMagnification();
            Diff = abs(obj.LUT - Mag*100);
            n = find(min(Diff) == Diff);
            x = size(obj.LUT,2);
            if n-1 > 0
                obj.Zoom_Factor = obj.LUT(n-1)/100;
            end   
            obj.VisibleLocation = round(obj.handles.zoomapi.getVisibleLocation());
        end
        function ResizeBottom(obj)
            FigPos = get(obj.handles.figure,'Position');
            Height = FigPos(4);             
            set(obj.handles.scrollpanel,'Position',[0 obj.Bottom_Border_Size/Height 1 (Height-obj.Top_Border_Size)/Height]);
            Mag = obj.handles.zoomapi.getMagnification();
            obj.handles.zoomapi.setMagnification(Mag);
            obj.VisibleLocation = round(obj.handles.zoomapi.getVisibleLocation());
            drawnow;
        end 
        function Zoom2fit(obj)
           Mag = obj.handles.zoomapi.findFitMag();
           obj.Zoom_Factor = Mag;
           obj.handles.zoomapi.setMagnification(obj.Zoom_Factor);
        end
        function Zoom1to1(obj)
           obj.handles.zoomapi.setMagnification(1); 
        end
    end
    methods (Hidden  = true)
        function obj = imscrollpanel_custom(varargin)
            %%
            obj.handles.figure = varargin{1};
            obj.handles.imHandle = varargin{2};
            obj.FigMonitor_OBJ = varargin{3};
            x = size(varargin,2);
            for i  = 4:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.handles.scrollpanel = imscrollpanel(obj.handles.figure,obj.handles.imHandle);
            obj.handles.zoomapi = iptgetapi(obj.handles.scrollpanel);
            obj.ZoomFactor(); %set zoom factor
            obj.ResizeBottom(); %set intial zoom factor
            Mag = obj.handles.zoomapi.getMagnification();
            obj.handles.zoomapi.setMagnification(Mag);   
            obj.addlistener(    'Zoom_Factor',  'PostSet',  @obj.ZoomFactor);
            set(obj.handles.figure,'WindowScrollWheelFcn',  @obj.WindowScrollWheelFcn);
            obj.addlistener(    'EnablePan',    'PostSet',  @obj.EnablePanFcn);
        end 
        function EnablePanFcn(varargin)
            %%
            obj = varargin{1};
            if obj.EnablePan == true
                disp('enable pan')
                set(obj.handles.figure, 'Pointer','hand')
                obj.handles.listeners.MouseButtonState = obj.FigMonitor_OBJ.addlistener('MouseButtonState','PostSet',@obj.Pan);
            else
                delete(obj.handles.listeners.MouseButtonState);
                set(obj.handles.figure, 'Pointer','arrow')
                disp('disable pan')
            end
        end
        function Pan(varargin)
            %%
            obj = varargin{1};
            if strcmpi(obj.FigMonitor_OBJ.MouseButtonState,'Down')
                disp('pan starting')
                % get the start position just before flipping
                % MouseButtonState to Down. 
                obj.Mouse_StartPos = round(obj.FigMonitor_OBJ.MouseButtonDown_Pos);
                obj.Image_StartPos = round(obj.handles.zoomapi.getVisibleLocation());
                obj.Image_CurrentPos = obj.Image_StartPos;
                obj.VisibleLocation = obj.Image_StartPos;
                obj.handles.listeners.CurrentPos = obj.FigMonitor_OBJ.addlistener('CurrentPos','PostSet',@obj.Moving);                
            else
                %%
                obj.handles.listeners.CurrentPos.Enabled = false;
                delete(obj.handles.listeners.CurrentPos);
                get(obj.handles.listeners.CurrentPos);
                disp('pan stopping')
            end
        end
        function Moving(varargin)
            %%
            obj = varargin{1};
            if strcmpi(obj.FigMonitor_OBJ.MouseButtonState,'Down')
            
%             if not(obj.Mouse_LastPos == obj.Mouse_CurrentPos)
%                 while and(obj.Mouse_StartPos(1) == obj.Mouse_CurrentPos(1), obj.Mouse_StartPos(2) == obj.Mouse_CurrentPos(2))
                    obj.Mouse_CurrentPos = obj.FigMonitor_OBJ.CurrentPos;
                    Mouse_DiffPos(1) = obj.Mouse_CurrentPos(1) - obj.Mouse_StartPos(1);
                    Mouse_DiffPos(2) = obj.Mouse_CurrentPos(2) - obj.Mouse_StartPos(2);
                    obj.Mouse_DiffPos = Mouse_DiffPos;
                    
                    Image_CurrentPos = round(obj.handles.zoomapi.getVisibleLocation());
                    obj.Image_CurrentPos(1) = obj.Image_CurrentPos(1) - obj.Mouse_DiffPos(1);
                    obj.Image_CurrentPos(2) = obj.Image_CurrentPos(2) - obj.Mouse_DiffPos(2);
                    
                    obj.handles.zoomapi.setVisibleLocation(obj.Image_CurrentPos);
                    drawnow
%                 end
                

                disp('The current and start position should be the same')
                disp(['Mouse_StartPos: [',num2str(obj.Mouse_StartPos(1)),',',num2str(obj.Mouse_StartPos(2)),']'])
                disp(['Mouse_CurrentPos: [',num2str(obj.Mouse_CurrentPos(1)),',',num2str(obj.Mouse_CurrentPos(2)),']'])
                disp(' ')
                disp(['Image_StartPos: [',num2str(obj.Image_StartPos(1)),',',num2str(obj.Image_StartPos(2)),']'])
                disp(['Image_CurrentPos: [',num2str(obj.Image_CurrentPos(1)),',',num2str(obj.Image_CurrentPos(2)),']'])
                disp(['Mouse_DiffPos: [',num2str(obj.Mouse_DiffPos(1)),',',num2str(obj.Mouse_DiffPos(2)),']'])
                disp(' ')
            end
        end
        function WindowScrollWheelFcn(varargin)
            %%
            obj = varargin{1};
            scroll_status = varargin{3};
            if scroll_status.VerticalScrollCount == 1
                obj.Zoom_StepOut();
            else
                obj.Zoom_StepIn();
            end
        end
        function ZoomFactor(varargin)
            obj = varargin{1};
            obj.handles.zoomapi.setMagnification(obj.Zoom_Factor);
        end
    end
end