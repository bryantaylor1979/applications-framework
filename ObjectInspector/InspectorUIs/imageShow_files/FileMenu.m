classdef FileMenu < handle
    properties (SetObservable = true)
        ImageName
        Raw_Support = false;
        Load_Visible = true;
        Save_Visible = true;
        figure_handle
        image_handle
        LoadImage_OBJ
        SaveImage_OBJ
    end
    properties (Hidden = true)
        handles
    end
    methods
        function Example(obj)
           close all
           clear classes
           
           file = 'C:\tuning\imx175\output\AL_HW_GED\001-Baffin-BRCM_20120203_040821.jpg';
           RI_OBJ = ReadImage('FileName',file);
           RI_OBJ.RUN();
           figure_handle = figure;
           handle = imshow(RI_OBJ.imageOUT.image)
                       
           
           %%
           OBJ = FileMenu(  'ImageName',        file, ...
                            'figure_handle',    figure_handle, ...
                            'image_handle',     RI_OBJ);
           
           
           %%
           figure, imshow(OBJ.LoadImage_OBJ.image.image)
           
           %%
           figure, imshow(RI_OBJ.imageOUT.image)
        end
    end
    methods (Hidden = true)
        function obj = FileMenu(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            %% Load
            obj.handles.toolbar_handle = uitoolbar(obj.figure_handle);
            obj.handles.menu_handle = uimenu(obj.figure_handle,'Label','File');
            
            %%
            obj.LoadImage_OBJ =        LoadImage(   'ImageName',        obj.ImageName, ...
                                                    'toolbar_handle',   obj.handles.toolbar_handle, ...
                                                    'menu_handle',      obj.handles.menu_handle, ...
                                                    'Visible',          obj.Load_Visible, ...
                                                    'raw_support',      obj.Raw_Support, ...
                                                    'image_handle',     obj.image_handle, ...
                                                    'figure_handle',    obj.figure_handle);  
                                                
            %%                                     
            obj.SaveImage_OBJ        = SaveImage(   'toolbar_handle',   obj.handles.toolbar_handle, ...
                                                    'menu_handle',      obj.handles.menu_handle, ...
                                                    'image_handle',     obj.image_handle, ...
                                                    'Visible',          obj.Save_Visible);
            obj.addlistener('Load_Visible','PostSet',@obj.Load_Visible_Update);
            obj.addlistener('Save_Visible','PostSet',@obj.Save_Visible_Update);
        end
        function Load_Visible_Update(varargin)
            %%
            obj = varargin{1};
            obj.LoadImage_OBJ.Visible = obj.Load_Visible;
        end
        function Save_Visible_Update(varargin)
            obj = varargin{1};
            obj.SaveImage_OBJ.Visible = obj.Save_Visible;
        end
    end
end