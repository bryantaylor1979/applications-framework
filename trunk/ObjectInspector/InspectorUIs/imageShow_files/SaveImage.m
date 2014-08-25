classdef SaveImage < handle
    properties (SetObservable = true)
        ImageName = '';
        Visible = true
        Enable = true
        image_handle
        toolbar_handle
        menu_handle
        menusub_handle
    end
    properties (Hidden = true)
        button_handle
    end
    methods 
        function obj = RUN(varargin)
            %%
            obj = varargin{1};
            if isempty(obj.ImageName)
                [filename, pathname] = uiputfile( ...
                                {   '*.bmp'; ...
                                    '*.gif'; ...
                                    '*.hdf'; ...
                                    '*.jpeg'; ...
                                    '*.pgm'; ...
                                    '*.png'; ...
                                    '*.pnm'; ...
                                    '*.ppm'; ...
                                    '*.ras'; ...
                                    '*.tiff'; ...
                                    '*.xwd'; ...
                                    '*.*'}, ...
                                'Save as','Untitled.bmp');
                if ischar(filename)
                    file = fullfile(pathname, filename);
                    imwrite(obj.image_handle.imageOUT.image,file);
                end
            else
                imwrite(obj.image_handle.imageOUT.image,obj.ImageName);
                obj.ImageName = '';
            end
        end
    end
    methods (Hidden = true)
        function obj = SaveImage(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.CreateSaveButton();     
            obj.CreateSaveMenu();
            obj.addlistener('Enable','PostSet',@obj.updateEnable);
            obj.addlistener('Visible','PostSet',@obj.Visible_Update);
            obj.Visible_Update();
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
        function CreateSaveButton(obj)
            filename = fullfile( matlabroot,'toolbox','matlab','icons','savedoc');
            load(filename);
            obj.button_handle = uipushtool(obj.toolbar_handle, ...
                                                'CData',            cdata, ...
                                                'TooltipString',    'Save As', ...
                                                'ClickedCallback',  @obj.RUN);         
        end
        function CreateSaveMenu(obj)
            %%
            obj.menusub_handle = uimenu(obj.menu_handle,'Label','Save');
            set(obj.menusub_handle,'Callback',@obj.RUN); 
        end
        function updateEnable(varargin)
            obj = varargin{1};
            if obj.Enable == true
                set(obj.button_handle,'Enable','on');
                set(obj.menusub_handle,'Enable','on');
            else
                set(obj.button_handle,'Enable','off');   
                set(obj.menusub_handle,'Enable','off');
            end
        end
    end
end