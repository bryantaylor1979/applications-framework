classdef pixelString < handle
    properties (SetObservable = true)
        Position_Left = 255;
        imageOUT
        cpm_OBJ
        String
    end
    properties (Hidden = true)
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes 
            is_OBJ = imageShow();
            
            %% Load an image
            hFigure = gcf;
            cpm_OBJ = CurrentPostionMonitor(hFigure);
            obj = pixelString(cpm_OBJ,is_OBJ.imageOUT,hFigure);
        end
    end
    methods (Hidden = true)
        function obj = pixelString(varargin)
            cpm_OBJ = varargin{1};
            image = varargin{2};
            hFigure = varargin{3};
            inputs = varargin(4:end);
            x = size(inputs,2);
            for i = 1:2:x
                obj.(inputs{i}) = inputs{i+1};
            end
            
            obj.handles.figure = hFigure;
            obj.cpm_OBJ = cpm_OBJ;
            
            obj.cpm_OBJ.addlistener('CurrentPos','PostSet',@obj.Update);
            obj.imageOUT = image;
            obj.InitGUI();
        end
        function Update(varargin)
            obj = varargin{1};
            CurrentPos = round(obj.cpm_OBJ.CurrentPos);
            if obj.cpm_OBJ.indexInAxesArray == false
    %             CurrentPos = [765, 976];
                FSD = 2^obj.imageOUT.bitdepth-1;
                if obj.imageOUT.fsd == FSD
                    R = obj.imageOUT.image(CurrentPos(2),CurrentPos(1),1);
                    G = obj.imageOUT.image(CurrentPos(2),CurrentPos(1),2);
                    B = obj.imageOUT.image(CurrentPos(2),CurrentPos(1),3);
                else
                    R = obj.imageOUT.image(CurrentPos(2),CurrentPos(1),1)*(FSD+1);
                    G = obj.imageOUT.image(CurrentPos(2),CurrentPos(1),2)*(FSD+1);
                    B = obj.imageOUT.image(CurrentPos(2),CurrentPos(1),3)*(FSD+1);                   
                end
                
                cord = ['(',num2str(CurrentPos(1)),',',num2str(CurrentPos(2)),')'];
                rgb = ['[',num2str(round(R)),' ',num2str(round(G)),' ',num2str(round(B)),']'];
                obj.String = ['Pixel info: ',cord,' ',rgb,' {',num2str(obj.imageOUT.bitdepth),'-BIT}'];
                set(obj.handles.uicontrol,'String',   obj.String);
            else
                set(obj.handles.uicontrol,'String',   'Pixel info: (X,Y) [R G B]');    
            end
        end
        function InitGUI(obj)
            obj.handles.uicontrol = uicontrol(obj.handles.figure);
            Color = get(obj.handles.figure,'Color');
            set(obj.handles.uicontrol, ...
                            'Style',    'text', ...
                            'String',   obj.String, ...
                            'Position', [obj.Position_Left,6,257,14], ...
                            'HorizontalAlignment','left', ...
                            'BackgroundColor',Color);            
        end
    end
end