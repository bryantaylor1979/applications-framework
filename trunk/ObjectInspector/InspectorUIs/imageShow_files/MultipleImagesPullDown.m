classdef MultipleImagesPullDown < handle
    properties (SetObservable = true)
        Width = 250;
        ImageSelected
        ImageName
        LoadImage_OBJ
        ImageShow_OBJ
    end
    properties (Hidden = true)
        handles
        FILES
    end
    methods
        function obj = MultipleImagesPullDown(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.FILES = obj.FilterImageNameOnly(obj.ImageName);
            obj.handles.pulldown = uicontrol();
            set(obj.handles.pulldown, ...
                    'Style',    'popupmenu', ...
                    'String',   obj.FILES, ...
                    'Callback', @obj.Update, ...
                    'Position', [0 2 obj.Width 22])
            obj.handles.imageselected_listen = obj.addlistener('ImageSelected','PostSet',@obj.UpdateLoadImage);
        end
        function FILES = FilterImageNameOnly(obj,files)
            %%
            x = size(files,1);
            for i = 1:x
               [path,filename,ext] = fileparts(files{i});
               FILES{i} = [filename,ext];
            end
        end
        function UpdateLoadImage(varargin)
            %%
            obj = varargin{1};
            obj.LoadImage(obj.ImageSelected);
        end
        function Update(varargin)
            obj = varargin{1};
            [fullfilename] = obj.GetSelectedImageName();
            
            % We have a listener on ImageSelected So the next line will load a new
            % image into the viewer. 
            obj.ImageSelected = fullfilename;
            
%             %TODO: Should the xml box plot really should be here? 
%             if not(isempty(obj.ParentHandle_OBJ.XmlName)) 
%                 obj.ImageShow_OBJ.xml_OBJ.filename = XML_FileName;
%                 obj.ImageShow_OBJ.xml_OBJ.RUN();
%                 obj.ImageShow_OBJ.box_X_Start = obj.ImageShow_OBJ.xml_OBJ.GreyPatchCoords_X;
%                 obj.ImageShow_OBJ.box_Y_Start = obj.ImageShow_OBJ.xml_OBJ.GreyPatchCoords_Y;  
%                 obj.ImageShow_OBJ.box_X_End = obj.ImageShow_OBJ.xml_OBJ.GreyPatchCoords_X + obj.ImageShow_OBJ.xml_OBJ.GreyPatchCoords_Width;
%                 obj.ImageShow_OBJ.box_Y_End = obj.ImageShow_OBJ.xml_OBJ.GreyPatchCoords_Y + obj.ImageShow_OBJ.xml_OBJ.GreyPatchCoords_Height;  
%             end
        end
        function LoadImage(obj,fullfilename)
            obj.LoadImage_OBJ.ImageName = fullfilename;
            obj.LoadImage_OBJ.LoadImageFromFile(fullfilename);           
        end
        function [fullfilename] = GetSelectedImageName(varargin)
            obj = varargin{1};
            Value = get(obj.handles.pulldown,'Value');
            String = get(obj.handles.pulldown,'String');
            Filename = String{Value};
            n = find(strcmpi(obj.FILES,Filename));
            fullfilename = obj.ImageName{n};
        end
    end
end