classdef CurrentPostionMonitor < handle
    % When using this function you MUST clear this class before closing the
    % figure. 
    properties (SetObservable = true)
        FigPosLoc = [NaN, NaN]
        FigPosSize = [NaN, NaN]
        MouseButtonState = 'Up';
        CurrentPos = [NaN, NaN];
        indexInAxesArray
        IsFigOpen
    end
    properties (Hidden = true)
        hfigure
        hbox
        haxes 
    end
    methods
        function Example(obj)
            %%
            close all
            clear clases
            imageOUT = imageCLASS;
            imageOUT.image = imread('Z:\projects\IQ_tuning_data\bgentles\run\2014_Apr_01_07_52_28_e70ca2b\001-Baffin-BRCM_20120203_040821.bmp');
            imageOUT.fsd = 1;
            imageOUT.type = 'rgb';
            imHandle = imageShow('imageOUT',imageOUT);
            
            %%
            obj = CurrentPostionMonitor(imHandle.handles.figure)
            %%
            ObjectInspector(obj)
            
            %% Allow deletion
            delete(obj)
        end
        function TestBench(obj)
            %% Test 1
            close all
            clear clases
            imageOUT.image = imread('C:\tuning\imx175\output\AL_HW_GED\001-Baffin-BRCM_20120203_040821.jpg');
            imageOUT.fsd = 1;
            imageOUT.type = 'rgb';
            imHandle = imageShow('imageOUT',imageOUT);
            obj = CurrentPostionMonitor(imHandle.handles.figure)
            ObjectInspector(obj)
        end
    end
    methods (Hidden =  true)
        function obj = CurrentPostionMonitor(figHandle)
            obj.hfigure = figHandle;
            obj.haxes = imhandles(obj.hfigure);
            obj.haxes = gca;
            set(obj.hfigure,    'WindowButtonMotionFcn',    @obj.WindowButtonMotionFcn, ...
                                'WindowButtonDownFcn',      @obj.WindowButtonDownFcn, ...
                                'ResizeFcn',                @obj.Resize, ...
                                'WindowButtonUpFcn',        @obj.WindowButtonUpFcn, ...
                                'CloseRequestFcn',          @obj.FigCloseRequestFcn);  
            obj.IsFigOpen = true;
        end
        
        function Resize(varargin)
            obj = varargin{1};
            if obj.IsFigOpen == false
               delete(obj)
               error('current position still running when fig is closed. The class has been cleared to avoid crash') 
            end
            FigPos = get(obj.hfigure,'Position');
            obj.FigPosLoc = FigPos(1:2);
            obj.FigPosSize = FigPos(3:4);
        end
        function WindowButtonMotionFcn(varargin)
            obj = varargin{1};
            if obj.IsFigOpen == false
               delete(obj)
               error('current position still running when fig is closed. The class has been cleared to avoid crash') 
            end
            [obj.indexInAxesArray,x,y] = obj.findAxesThatTheCursorIsOver(obj.haxes);
            obj.CurrentPos = [x,y];
        end
        function WindowButtonDownFcn(varargin)
            obj = varargin{1};
            if obj.IsFigOpen == false
               delete(obj)
               error('current position still running when fig is closed. The class has been cleared to avoid crash') 
            end
            obj.MouseButtonState = 'Down';
        end
        function WindowButtonUpFcn(varargin)
            obj = varargin{1};
            if obj.IsFigOpen == false
               delete(obj)
               error('current position still running when fig is closed. The class has been cleared to avoid crash') 
            end
            obj.MouseButtonState = 'Up';
        end
        
        function [indexInAxesArray,x,y] = findAxesThatTheCursorIsOver(obj,axHandles)
            %findAxesThatTheCursorIsOver returns an index of the axes below cursor.
            %   [indexInAxesArray,x,y] = findAxesThatTheCursorIsOver(axHandles) determines which axes
            %   the cursor is over and returns the location K of this axes in the
            %   axHandles array. X and Y represent the cursor location.

            %   Copyright 1993-2004 The MathWorks, Inc.
            %   $Revision: 1.1.6.1 $  $Date: 2005/03/31 16:33:19 $

            axesCurPt = get(axHandles,{'CurrentPoint'});
            indexInAxesArray = true;

            % determine which image the cursor is over.
            for k = 1:length(axHandles)
                pt = axesCurPt{k};
                x = pt(1,1);
                y = pt(1,2);
                xlim = get(axHandles(k),'Xlim');
                ylim = get(axHandles(k),'Ylim');
                
                if x >= xlim(1) && x <= xlim(2) && y >= ylim(1) && y <= ylim(2)
                   indexInAxesArray = false; 
                   break;
                end
            end
        end        
        function FigCloseRequestFcn(varargin)
            obj = varargin{1};
            hfig = varargin{2};
            set(hfig,'Visible','off');
            drawnow;
            disp('close request function is being executed')
            try obj.IsFigOpen = false; end %This will purge any other close commands
            drawnow();
            delete(hfig);
        end
        
        function delete(obj)
            set(obj.hfigure,'WindowButtonDownFcn','');
            set(obj.hfigure,'WindowButtonMotionFcn','');
            set(obj.hfigure,'WindowButtonUpFcn',''); 
            set(obj.hfigure,'ResizeFcn','');
        end
    end
end