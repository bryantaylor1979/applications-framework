classdef LoadImage < handle
    % load image
    % if the ImageName is declared (Not empty). The image will be loaded on
    % start-up. 
    properties (SetObservable = true)
        Visible = true
        raw_support = false;
        UserCancel
        figure_handle
        toolbar_handle
        menu_handle
        image_handle
        ImageName = '';
        image = imageCLASS
    end
    properties (Hidden = true)
        button_handle
        listener_handle
        menusub_handle
    end
    methods  
        function Example(obj)
           %%
           close all
           clear classes
           
           file = 'C:\tuning\imx175\output\AL_HW_GED\001-Baffin-BRCM_20120203_040821.jpg';
           RI_OBJ = ReadImage('FileName',file);
           RI_OBJ.RUN();
           figure_handle = figure;
           handle = imshow(RI_OBJ.imageOUT.image)
           toolbar_handle = uitoolbar(figure_handle);
           menu_handle = uimenu(figure_handle,'Label','File');
                       
           
           %%
           OBJ = LoadImage( 'ImageName',        file, ...
                            'toolbar_handle',   toolbar_handle, ...
                            'menu_handle',      menu_handle, ...
                            'figure_handle',    figure_handle);
           
           %% This will force the user prompt. 
           OBJ.ImageName = '';
           
           %%
           figure, imshow(OBJ.image.image)
        end
        function RUN(varargin)
            obj = varargin{1};
            if isempty(obj.ImageName)
                [obj.UserCancel, filename, pathname] = obj.GetImageName();
                if obj.UserCancel == false
                   obj.ImageName = [pathname,filename]; 
                   obj.LoadImageFromFile([pathname,filename]);
                end
            else
                %TODO: Investigate why UserCancel need to be set. 
                obj.UserCancel = false; %It doesn't seem to work without this. Perhaps due to a listener
                obj.LoadImageFromFile(obj.ImageName);
            end
        end
    end
    methods (Hidden = true)
        function obj = LoadImage(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.CreateLoadButton();
            obj.CreateLoadMenu();
            obj.addlistener('ImageName','PostSet',@obj.updateImageName);
            obj.addlistener('Visible','PostSet',@obj.Visible_Update);
            if not(isempty(obj.ImageName))
                obj.LoadImageFromFile(obj.ImageName);
            end
            obj.Visible_Update();
            
            obj.addlistener( 'image', 'PostSet', @obj.UpdateImageFromLoad);
        end
        function UpdateImageFromLoad(varargin)
            obj = varargin{1};
            obj.image_handle.imageOUT = obj.image; 
        end
        function Visible_Update(varargin)
            obj = varargin{1};
            if obj.Visible == true
                set(obj.button_handle,'Visible','on');
                set(obj.menusub_handle,'Visible','on');
            else
                set(obj.button_handle,'Visible','off');
                set(obj.menusub_handle,'Visible','off')
            end
        end
        function CreateLoadButton(obj)
            filename = fullfile( matlabroot,'toolbox','matlab','icons','opendoc');
            load(filename);
            obj.button_handle = uipushtool(obj.toolbar_handle, ...
                                        'CData',cdata, ...
                                        'TooltipString','Load Image', ...
                                        'ClickedCallback',@obj.UserPressCallback);
        end
        function UserPressCallback(varargin)
            obj = varargin{1};
            obj.ImageName = '';
            obj.RUN();
        end
        function CreateLoadMenu(obj)
            obj.menusub_handle = uimenu(obj.menu_handle,'Label','Load');
            set(obj.menusub_handle,'Callback',@obj.UserPressCallback); 
        end
        function [UserCancel, filename, pathname] = GetImageName(obj)
            %%
            UserCancel = false;
            string1 = '';
            string2 = 'All Image Files (';
            array1 = [];
            [string1,string2,array1] = obj.AddType2String('bmp','bitmap',string1,string2,array1);
            [string1,string2,array1] = obj.AddType2String('jpg','jpeg',string1,string2,array1);
%             [string1,string2,array1] = obj.AddType2String('pgm','',string1,string2,array1);
%             [string1,string2,array1] = obj.AddType2String('png','',string1,string2,array1);
            if obj.raw_support == true
                [string1,string2,array1] = obj.AddType2String('raw','',string1,string2,array1);
            end
            string1 = string1(1:end-1);
            string2 = [string2(1:end-1),')'];
            
            [filename, pathname, filterindex] = uigetfile( ...
               [{string1},    {string2}; ...
                array1
                {'*.*'},      {'All Files (*.*)'}], ...
                'Pick a file');
            
            if filterindex == 0
                UserCancel = true;
                disp('user has cancelled') 
                return 
            end           
        end
        function LoadImageFromFile(obj,ImageName)
            %%
            disp('loading image from file')
            PWD = pwd;
            [pathname,filename,ext] = fileparts(ImageName);
            if strcmpi(ext,'.raw')
                image = imageCLASS;
                raw = ReadRaw('FileName',fullfile(pathname,[filename,ext]));
                raw.RUN;
                image.image = raw.imageOUT;
                image.type = 'raw';
                image.fsd = 1;
                image.bitdepth = 10;
            else
                RI_OBJ = ReadImage('FileName',fullfile(pathname,[filename,ext]));
                RI_OBJ.RUN;
                image = RI_OBJ.imageOUT;
            end
            %%
            obj.listener_handle.Enabled = true;
            obj.image = image;
            cd(PWD); 
            disp(' ')
        end
        function [string1,string2,array1] = AddType2String(obj,imageType,imageName,string1,string2,array1) 
            string1 =   [string1,'*.',  imageType,';'];
            string2 =   [string2,' *.', imageType, ','];
            array1 =    [array1; ...
                        {['*.',imageType],   [ imageName,' (*.',imageType,')']}];            
        end
        function updateImageName(varargin)
            %%
            obj = varargin{1};
            if isempty(obj.ImageName)
                figureName =  'image Show';
            else
                figureName =  ['image Show - ',obj.ImageName];
            end
            set(obj.figure_handle,'Name',figureName);
        end
    end
end