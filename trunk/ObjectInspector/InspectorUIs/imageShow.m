classdef imageShow < handle
    % IMAGESHOW
    % =========
    %
    % Description
    % Load images and run metrics. Supports most images types including
    % raws
    %
    % Sub-Components: 
    properties (SetObservable = true)
        Rev = 'Release2ReijoForTest';
        Customer = 'KTouch';
        Load_Visible = true;
        Save_Visible = true;
        Raw_Support = false;
        ImageName = []; % add image name and it will appear on the figure name
        XmlName = [];
        boxSelection = false
        
        % BOX
        box_enable = false;
        box_X_Start = 1655;
        box_Y_Start = 1638;
        box_X_End = 1709;
        box_Y_End = 1686;
        
        % LINE
        line_enable = false;
        line_X_Start = 1655;
        line_Y_Start = 1638;
        line_X_End = 1709;
        line_Y_End = 1686;
        Intial_Zoom_Factor = 1;
        
        %% Multiple Image load Pulldown - (Bottom Left)
        ImageNamePullDown_Width = 250;
        
        Visible = true;
        LineMoving = false;
        LinePos
        
        
        PipeView_Enable = false;
        Debug_Enable = false;
        CustomerMetric_Enable = true;
        Process_Enable = true;
        
        FigMonitor_OBJ
        Pixel_OBJ
        BoxDraw_OBJ
        CropSelect_OBJ
        imageProfile_OBJ
        imageLine_OBJ
        Scroller_OBJ
        FileMenu_OBJ
        imageLoad_OBJ
        imageSave_OBJ
        xml_OBJ
        mi_OBJ
        XMLInfo_OBJ
    end
    properties (SetObservable = true)
        imageOUT
        imageOUT_cropped
        imageOUT_line
        MetricOpenStatus %Use to monitor the status of metric (OPEN/CLOSED) 
        
    end
    properties (Hidden = true, SetObservable = true)
        xml_display_enable = false;
        Customer_LUT = {    'Samsung'; ...
                            'HTC'; ...
                            'KTouch'};
        handles
        % DataViewers
        %               Metrix Name             ObjectInspect Mode   Type        RunOnStartUp  LabelName
        Metric = ...
               {        'PixelProfilePlot',      'None',             'line',     true,         'Pixel Profile'; ...
                        'SurfacePlot',           'None',             'image',    false,        'Surface Plot (BL or LS)'; ...
                        'HSV_Viewer',            'None',             'box',      true,         'HSV chroma viewer'; ...
                        'Lab_viewer',            'None',             'box',      true,         'Lab chroma viewer'; ...
                        'PDF',                   'None',             'box',      true,         'RBnorm chroma viewer'; ...
                        'imageHistogram',        'None',             'box',      false,        'Histogram'; ...
                        'imageHistogram',        'None',             'image',    false,        'Histogram'};      
        KTouch_Metrics= ...
               {        'LS_Metric',             'StandAlone',       'image',    true,         'Lens Shading Uniformity'}; 
        Samsung_Metrics= ...
               {        'SamsungWB',             'None',             'box',      true,         'WB spec'};
    end
    methods
        function Example(obj)            
            %%
            close all
            clear classes
            
            %% show grey cord
            obj = imageShow(    'ImageName',    'Z:\projects\IQ_tuning_data\sensors\Sony\imx175\Grass_Images\imx175_Macbeth_Shadow_IMG_20140513_153612.jpg', ...
                                'XmlName',      'Z:\projects\IQ_tuning_data\sensors\Sony\imx175\Grass_Images\imx175_Macbeth_Shadow_IMG_20140513_153612.xml');
            %%                
            obj = imageShow(    'ImageName',    'Z:\projects\IQ_tuning_data\sensors\Sony\imx175\Grass_Images\imx175_Macbeth_Shadow_IMG_20140513_153612.jpg');
            
            %% Use Samsung Metric
            files = 'Z:\projects\IQ_tuning_data\sensors\Sony\imx175\Grass_Images\imx175_Cloudy_IMG_20140513_170349.jpg';
            obj1 = imageShow(   'ImageName',    files, ...
                                'CustomerMetric_Enable', 'on'); 
            
            %% Use Samsung Metric - Unix
            files = {   '//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Macbeth_Shadow_IMG_20140513_153612.jpg'; ...
                        '//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Macbeth_Cloudy_IMG_20140513_170407.jpg'; ...
                        '//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Cloudy_IMG_20140513_170349.jpg'};
                    
            xml_file = {'//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Macbeth_Shadow_IMG_20140513_153612.xml'; ...
                        '//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Macbeth_Cloudy_IMG_20140513_170407.xml'; ...
                        '//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Cloudy_IMG_20140513_170349.xml'};
                    
            obj = imageShow(    'ImageName',     files, ...
                                'XmlName',      xml_file, ...
                                'CustomerMetric_Enable', 'on'); 
            
                            
            %% 
            files = {   ['C:\CTT\TuningData\imx175\Labels\AWB_IDEAL_GAINS\20120204_100757_LABEL_AWB_IDEAL_GAINS.bmp']; ...
                        ['C:\tuning\imx175\raws\20120204_100757.jpg']  };
            obj1 = imageShow(  'ImageName',    files); 
            
            %%
            file = 'C:\tuning\imx175\output\AL_HW_GED\001-Baffin-BRCM_20120203_040821.jpg';
            RI_OBJ = ReadImage('FileName',file);
            RI_OBJ.RUN();
            
            %%
            obj = imageShow(    'imageOUT',     RI_OBJ.imageOUT, ...
                                'ImageName',    file);

            %%
            file = 'C:\tuning\imx175\output\AL_HW_GED\01_Baffin_MC4_bayer.jpg';
            imageOUT = imageCLASS();
            imageOUT.image = imread(file);
            imageOUT.fsd = 255;
            imageOUT.type = 'rgb';
            obj.imageOUT = imageOUT;    
            
            %%
            file = 'C:\tuning\imx175\output\AL_HW_GED\001-Baffin-BRCM_20120203_040821.jpg';
            imageOUT = imageCLASS();
            imageOUT.image = imread(file);
            imageOUT.fsd = 255;
            imageOUT.type = 'rgb';
            obj.imageOUT = imageOUT;   
            
            %%
            
            
            %%
            ObjectInspector(obj)
            
            %%
            delete(obj.handles.customer.parent)
            
            %%
            obj.GenericMetricLoad('Samsung_Metrics','SamsungWB','box',true);
            
            %%
            obj.handles.('box').('SamsungWB').Visible = true
            
            
            %% Test all metrics
            Metrics = { 'Metric'; ...
                        'KTouch_Metrics'; ...
                        'Samsung_Metrics'};            
            x = size(Metrics,1);
            count = 1;
            for i = 1:x
                %
                Names = obj.(Metrics{i})(:,1);
                Type = obj.(Metrics{i})(:,3);
                y = size(Type,1);
                for j = 1:y
                    MetricType{count,1} = Metrics{i};
                    FuncName{count,1} = Names{j};
                    Types{count,1} = Type{j};
                    try
                        obj.GenericMetricLoad(Metrics{i},Names{j},Type{j},false);
                        PASS{count,1} = true;
                        visible = get(obj.handles.(Type{j}).(Names{j}).handles.figure,'visible');
                        if strcmpi(visible,'off')
                            inVisibleStartup{count,1} = true;
                        else
                            inVisibleStartup{count,1} = false;
                        end
                        close(obj.handles.(Type{j}).(Names{j}).handles.figure);
                        obj.GenericMetricLoad(Metrics{i},Names{j},Type{j},true);
                        visible = get(obj.handles.(Type{j}).(Names{j}).handles.figure,'visible');
                        if strcmpi(visible,'on')
                            inVisibleEnd{count,1} = true;
                        else
                            inVisibleEnd{count,1} = false;
                        end                        
                        drawnow;
                    catch
                        PASS{count,1} = false;
                    end
                    count = count + 1;
                end
            end
            %%
            DATASET = dataset(      {MetricType,        'MetricType'}, ...
                                    {FuncName,          'FuncName'}, ...
                                    {Types,             'Types'}, ...
                                    {PASS,              'basicload_PASS'}, ...
                                    {inVisibleStartup,  'inVisibleStartup_PASS'}, ...
                                    {inVisibleEnd,      'inVisibleEnd_PASS'})
        end
    end
    methods %API
        function LoadImage2(varargin)
            x = size(varargin,2);
            obj = varargin{1};
            if x == 2
               obj.FileMenu_OBJ.LoadImage_OBJ.ImageName = varargin{2};
            else
               obj.FileMenu_OBJ.LoadImage_OBJ.ImageName = '';
            end
            obj.FileMenu_OBJ.LoadImage_OBJ.RUN();
        end   
        function SaveImage2(varargin)
            x = size(varargin,2);
            obj = varargin{1};
            if x == 2
            obj.FileMenu_OBJ.SaveImage_OBJ.ImageName = varargin{2};
            end
            obj.FileMenu_OBJ.SaveImage_OBJ.image_handle = obj;
            obj.FileMenu_OBJ.SaveImage_OBJ.RUN();
        end
        function SelectImage(obj)
            %%
        end
    end
    methods (Hidden = true)
        function obj = imageShow(varargin)
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end 
            obj.addlistener('Customer','PostSet',@obj.LoadCustomerMetrics);
            obj.addlistener('Load_Visible','PostSet',@obj.Load_Visible_Update);
            obj.addlistener('Save_Visible','PostSet',@obj.Save_Visible_Update);
            obj.InitGUI();
            
            if obj.Visible == true
            set(obj.handles.figure,'Visible','on');
            else
            set(obj.handles.figure,'Visible','off');    
            end
        end
        function InitGUI(obj)
            if isempty(obj.ImageName)
                figureName =  'image Show';
                ImageName = obj.ImageName;
            else
                if not(iscell(obj.ImageName))
                ImageName =  obj.ImageName;
                else
                ImageName =  obj.ImageName{1};    
                end
                figureName =  ['image Show - ',ImageName];  
            end
            obj.handles.figure = figure(    'Name',         figureName, ...
                                            'NumberTitle',  'off', ...
                                            'MenuBar',      'none', ...
                                            'DeleteFcn',    @obj.DeleteFig, ...
                                            'KeyPressFcn',  @obj.KeyPressFcn, ...
                                            'Visible',      'off');
            
            
            
            try
                parent = obj.AddToolBar(ImageName);
            catch
                uiwait(msgbox('after toolbar - check images are included in compile process'));
            end
            obj.FilePullDown(parent, obj.CustomerMetric_Enable);
            
            LoadWithoutImage = false;
            IntialZoomFactor = 1.0;
            Background_Visible = 'off';
            
            if not(isempty(obj.ImageName))
                warning off
                if isempty(obj.imageOUT)
                obj.imageOUT = obj.FileMenu_OBJ.LoadImage_OBJ.image;
                end
                warning on
            else
                if isempty(obj.imageOUT)
                    imageOUT = imageCLASS;
                    LoadWithoutImage = true;
                    IntialZoomFactor = 0.01;
                    %314   193
                    imageOUT.image = obj.LoadBackGroundImage(240,340);
                    Background_Visible = 'on';
                    obj.imageOUT = imageOUT;
                end
            end
                        
            obj.ImageFormatCheck(obj.imageOUT);
            warning('off','images:initSize:adjustingMag');
            obj.handles.image_DISPLAY = imshow(obj.imageOUT.image);
            warning('on','images:initSize:adjustingMag');
            obj.handles.toolbar.save.image_handle = obj.handles.image_DISPLAY;

            %% if bayer then you need to do something with 10 bit data to 
            % allow it to be displayed. This should really be in the bayer
            % reader 
            if strcmpi(obj.imageOUT.type,   'bayer')
                obj.imageOUT = obj.FormatBayerForDisplay(obj.imageOUT);
            end                  
            
            obj.handles.background = uicontrol(obj.handles.figure, ...
                    'Visible',              Background_Visible, ...
                    'Style',                'frame', ...
                    'BackgroundColor',      [0.5, 0.5, 0.5], ...
                    'ForegroundColor',      [0.5, 0.5, 0.5], ...
                    'Position',             [2,23,489,305]); 
                
            obj.imageOUT_cropped = obj.imageOUT;
            obj.FigMonitor_OBJ = CurrentPostionMonitor(obj.handles.figure);                     % intialise figure event monitor 
            obj.FigMonitor_OBJ.addlistener('IsFigOpen','PostSet',@obj.CloseMetrics);
            obj.Scroller_OBJ = imscrollpanel_custom(   obj.handles.figure, obj.handles.image_DISPLAY, obj.FigMonitor_OBJ, ...
                                                       'Zoom_Factor',  IntialZoomFactor); 
            obj.BoxSelection(); 
% 
            % load metrics.
            obj.handles.menu = obj.MasterMenu('Metric','DataViewers', 'on');
            if obj.CustomerMetric_Enable == true
            obj.handles.customer = obj.MasterMenu([obj.Customer,'_Metrics'],[obj.Customer,' Metric'],'on');
            else
            obj.handles.customer = obj.MasterMenu([obj.Customer,'_Metrics'],[obj.Customer,' Metric'],'off');    
            end
            set(obj.handles.customer.box.master,'Enable','off');
            
            obj.AddMagBox();
            
            if obj.Debug_Enable == true
                obj.DebugPullDown();
            end
            if obj.PipeView_Enable == true
                obj.PipeLineView_PullDown();
            end
            if obj.Process_Enable == true
                obj.ProcessPullDown();
            end
              
            set(obj.handles.menu.box.master,'Enable','off');
            set(obj.handles.menu.line.master,'Enable','off');
            
            if LoadWithoutImage == true
                set(obj.handles.menu.parent,'Enable','off');
                
                set(obj.handles.customer.parent,'Enable','off');
                obj.handles.toolbar.save.Enable = false;
%                 set(obj.handles.save,'Enable','off');
%                 set(obj.handles.pulldown.Save,'Enable','off');
                
                set(obj.handles.pointer,'Enable','off');
                set(obj.handles.lineSelection,'Enable','off');
                set(obj.handles.boxSelection,'Enable','off');
                set(obj.handles.zoomin,'Enable','off');
                set(obj.handles.zoomout,'Enable','off');
                
                set(obj.handles.zoom2fit,'Enable','off');
                set(obj.handles.Zoom1to1,'Enable','off');
                
                
            end
            obj.InitCropper();   
            obj.InitLine();      
            
            % if multiple image change the layout at the bottom. 
            if iscell(obj.ImageName)
                Width = obj.ImageNamePullDown_Width;
                mi_OBJ = MultipleImagesPullDown(    'ImageName',        obj.ImageName, ...
                                                    'Width',            Width, ...
                                                    'LoadImage_OBJ',    obj.FileMenu_OBJ.LoadImage_OBJ, ...
                                                    'ImageShow_OBJ',    obj);
                                                
                mi_OBJ.addlistener('ImageSelected','PostSet',@obj.UpdateGreyCords); % When a new image is loaded update the XML data. 
                Position_Left = Width+5; 
                obj.mi_OBJ = mi_OBJ;
            else
                Position_Left = 4;  
            end
            try
                obj.Pixel_OBJ = pixelString(  obj.FigMonitor_OBJ, obj.imageOUT, obj.handles.figure, ...
                                              'Position_Left', Position_Left);    % intialise the pixel monitor.
            catch
                uiwait(msgbox('pixel string was not successfull'));
            end 
            obj.FigMonitor_OBJ.addlistener('FigPosSize','PostSet',@obj.Resize);
            obj.Resize();
        end
        function Load_Visible_Update(varargin)
            obj = varargin{1};
            obj.FileMenu_OBJ.Load_Visible = obj.Load_Visible;
        end
        function Save_Visible_Update(varargin)
            obj = varargin{1};
            obj.FileMenu_OBJ.Save_Visible = obj.Save_Visible;
        end
        function LoadCustomerMetrics(varargin)
            obj = varargin{1};
            Enable = get(obj.handles.customer.parent,   'Enable');
            
            delete(obj.handles.customer.parent);
            obj.handles.customer = obj.MasterMenu([obj.Customer,'_Metrics'],[obj.Customer,' Metric']);
            
            set(obj.handles.customer.parent,   'Enable', Enable);
        end
        function InitLine(obj)
            obj.imageLine_OBJ = imline_custom(obj.handles.figure,obj.FigMonitor_OBJ);
            obj.imageProfile_OBJ = improfile_custom(obj.imageLine_OBJ, obj.imageOUT);
            obj.imageProfile_OBJ.addlistener('imageOUT_line','PostSet',@obj.lineUpdate); 
            obj.imageProfile_OBJ.Enable = false;
            obj.imageLine_OBJ.Enable = false;            
        end
        function InitCropper(obj)
            obj.BoxDraw_OBJ = imrect_custom(obj.handles.figure,obj.FigMonitor_OBJ);
            obj.CropSelect_OBJ = CropSelection(obj.BoxDraw_OBJ,obj.imageOUT);
            obj.CropSelect_OBJ.addlistener('imageOUT_cropped','PostSet',@obj.CropUpdate); 
            obj.CropSelect_OBJ.Enable = false;
            obj.CropSelect_OBJ.box_OBJ.Enable = false;            
        end
        function ImageFormatCheck(obj,image)
            names = fieldnames(image);
            n = find(strcmpi(names,'fsd'));
            if isempty(n)
                error('fsd not defined for image class');
            end 
            n = find(strcmpi(names,'type'));
            if isempty(n)
                error('type not defined for image class');
            end 
        end
        function imageOUT = FormatBayerForDisplay(obj,imageOUT)
            if imageOUT.fsd == 1023 %10bit data stretched to 16bit. 
                image = imageOUT.image;
                image( image > obj.imageOUT.fsd ) = imageOUT.fsd;
                image( image < 0.0 ) = 0.0;
                imageOUT.image = uint16(double(image)*2^6);
            else
                imageOUT.image = obj.imageOUT.image;
            end              
        end
        function imageOUT = LoadBackGroundImage(obj,X,Y)
            % try 
            MakeSameAsFig = false;
            if MakeSameAsFig == true
                Color = get(obj.handles.figure,'Color');
            else
                Color = [0.5,0.5,0.5];
            end
            image(1:X,1:Y,1) = Color(1);
            image(1:X,1:Y,2) = Color(2);
            image(1:X,1:Y,3) = Color(3);
            imageOUT = image;          
        end
        function KeyPressFcn(varargin)
            %% 
            obj = varargin{1};
            keys = varargin{3};
            if strcmpi(keys.Modifier{1},'alt');
                if strcmpi(keys.Character,'s')
                    ObjectInspector(obj);
                end
            end
            if strcmpi(keys.Modifier{1},'alt');
                if strcmpi(keys.Character,'t')
                    BIT_OBJ = ImageShowTestBench();
                    ObjectInspector(BIT_OBJ);
                end
            end
        end
        function updateVisible(varargin)
            %%
            obj = varargin{1};
            if obj.Visible == true
                set(obj.handles.figure,'Visible','on')
            else
                set(obj.handles.figure,'Visible','off')
            end
        end
        function updateImage(varargin)
            %%
            disp('Updating image')
            obj = varargin{1};
            
            %%
            set(obj.handles.image_DISPLAY,'CDATA',obj.imageOUT.image);
            
            %%
            obj.CropSelect_OBJ.imageIN = obj.imageOUT;  
            obj.Pixel_OBJ.imageOUT = obj.imageOUT;
        end
        function FilePullDown(obj,parent,CustomerMetric_Enable)
            %%
            h.parent = parent;
            
            if CustomerMetric_Enable == true
            h.Preferences = uimenu(parent,'Label','Preferences');
            set(h.Preferences,'Callback',@obj.Preferences);
            end
            
            obj.handles.pulldown = h;
        end
        function Preferences(varargin)
            obj = varargin{1};
            h = uiOptions('Customer',obj.Customer);
            uiwait(h.handles.figure);
            obj.Customer = h.Customer;
            delete(h);
        end
        function OpenObjectInspector(varargin)
            obj = varargin{1};
            object = varargin{2};
            ObjectInspector(object);
        end
        function UpdateImageFromLoad(varargin)
            %%
            obj = varargin{1};
%             obj.handles.toolbar.load.listener_handle.Enable = false;
            
            %%
            %obj.handles.listener.image.Enabled = false;
%             obj.imageOUT = obj.handles.toolbar.load.image;
            %obj.handles.listener.image.Enabled = true;
            
            if obj.FileMenu_OBJ.LoadImage_OBJ.UserCancel == false
                obj.ImageName = [];
                delete(obj.CropSelect_OBJ);
                delete(obj.BoxDraw_OBJ);
                delete(obj.Pixel_OBJ);
                delete(obj.FigMonitor_OBJ);
            
                Position = get(obj.handles.figure,'Position');
                close(obj.handles.figure);
                
                drawnow
                obj.imageOUT = obj.FileMenu_OBJ.LoadImage_OBJ.image;
                obj.InitGUI();

                %%
                set(obj.handles.figure,  'Position',  Position);
                set(obj.handles.menu.parent,    'Enable', 'on');
                if obj.CustomerMetric_Enable == true
                set(obj.handles.customer.parent,'Enable', 'on');
                end
                obj.handles.toolbar.save.Enable = true;
%                 set(obj.handles.save,           'Enable', 'on');
                set(obj.handles.pointer,        'Enable', 'on');
                set(obj.handles.lineSelection,  'Enable', 'on');
                set(obj.handles.boxSelection,   'Enable', 'on');
                set(obj.handles.zoomin,         'Enable', 'on');
                set(obj.handles.zoomout,        'Enable', 'on');
                set(obj.handles.pulldown.parent,        'Enable', 'on');
                set(obj.handles.zoom2fit,       'Enable', 'on');
                set(obj.handles.Zoom1to1,       'Enable', 'on');
                set(obj.handles.figure,         'Visible','on');
            end
%             obj.handles.toolbar.load.listener_handle.Enable = true;
        end
        function DeleteFig(varargin)
            %%
            obj = varargin{1};
            obj.ClearCurrentMonitors();
        end
        function CloseMetrics(varargin)
            %%
            obj = varargin{1};
            
            %%
            if isempty(obj.MetricOpenStatus)
                return
            else
                NAMES = fieldnames(obj.MetricOpenStatus);
                x = size(NAMES,1);
                for i = 1:x
                    type = NAMES{i}
                    NAMES_ = fieldnames(obj.MetricOpenStatus.(type));
                    y = size(NAMES_,1);
                    for j = 1:y
                        close(obj.handles.(type).(NAMES_{j}).handles.figure);
                    end
                end
            end
	end
        function ClearCurrentMonitors(varargin) % delete function for imageShow
            obj = varargin{1};  
            %%
            if not(isempty(obj.imageProfile_OBJ))
                if isvalid(obj.imageProfile_OBJ)
                    delete(obj.imageProfile_OBJ);
                end
                obj.imageProfile_OBJ = [];
            end
            if not(isempty(obj.imageLine_OBJ))
                if isvalid(obj.imageLine_OBJ)
                    delete(obj.imageLine_OBJ); 
                end
                obj.imageLine_OBJ = [];
            end
%             if not(isempty(obj.CropSelect_OBJ))
%                 if isvalid(obj.CropSelect_OBJ)
%                     delete(obj.CropSelect_OBJ); 
%                 end
%                 obj.CropSelect_OBJ = [];
%             end
            if not(isempty(obj.Pixel_OBJ))
                if isvalid(obj.Pixel_OBJ)
                    delete(obj.Pixel_OBJ); 
                end
                obj.Pixel_OBJ = [];
            end
            if not(isempty(obj.FigMonitor_OBJ))
                if isvalid(obj.FigMonitor_OBJ)
                    delete(obj.FigMonitor_OBJ); 
                end
                obj.FigMonitor_OBJ = [];
            end
        end
        function delete(obj)
            obj.ClearCurrentMonitors();
        end
    end
    methods (Hidden = true) % Grey Cords
        function InitGreyCords(obj,xml_file)           
            %%
            [path,filename,ext] = fileparts(xml_file);
            OBJ = xmlRead('path',path,'imagename',[filename,ext]);

            obj.box_enable = true;
            OBJ.Name = 'GreyPatchCoords.X';
            OBJ.RUN();
            obj.box_X_Start = OBJ.Value;
 
            OBJ.Name = 'GreyPatchCoords.Y';
            OBJ.RUN();
            obj.box_Y_Start = OBJ.Value;

            OBJ.Name = 'GreyPatchCoords.Width';
            OBJ.RUN();
            Width = OBJ.Value;
            
            OBJ.Name = 'GreyPatchCoords.Height';
            OBJ.RUN();
            Height = OBJ.Value;
            
            obj.box_X_End = obj.box_X_Start + Width;
            obj.box_Y_End = obj.box_Y_Start + Height;  
            obj.addlistener('XmlName','PostSet',@obj.UpdateGreyCords);
            
            %%
            obj.XMLInfo_OBJ = XML_Info(	'xml_file_found',   'TRUE', ...
                                        'greycords_height', Height, ...
                                        'greycords_width',  Width, ...                    
                                        'greycords_x',      obj.box_X_Start, ...
                                        'greycords_y',      obj.box_Y_Start);
            %%
            obj.xml_OBJ = OBJ;
        end
        function UpdateGreyCords(varargin)
            %%
            disp('Updating XML data')
            obj = varargin{1};
            
            %%
            [path,filename,ext] = fileparts(obj.mi_OBJ.ImageSelected);
            filename = strrep(obj.mi_OBJ.ImageSelected,ext,'.xml');
            n = find(strcmpi(obj.XmlName,filename));
            if isempty(n) %must be LSF farm
            filename = strrep(strrep(obj.mi_OBJ.ImageSelected,ext(2:end),'xml'),ext,'.xml');
%             [path,filename,ext] = fileparts(obj.mi_OBJ.ImageSelected);
            n = find(strcmpi(obj.XmlName,filename));
            end
            
            %%
            n = find(strcmpi(obj.XmlName,filename));
            xml_file = obj.XmlName{n};

            
            %%
            [path,filename,ext] = fileparts(xml_file);
            obj.xml_OBJ.path = path;
            obj.xml_OBJ.imagename = [filename,ext];
            
            %%
            obj.xml_OBJ.Name = 'GreyPatchCoords.X';
            obj.xml_OBJ.RUN();
            
            if not(obj.xml_OBJ.Error == -1)
                obj.box_X_Start = obj.xml_OBJ.Value;

                obj.xml_OBJ.Name = 'GreyPatchCoords.Y';
                obj.xml_OBJ.RUN();
                obj.box_Y_Start = obj.xml_OBJ.Value;

                obj.xml_OBJ.Name = 'GreyPatchCoords.Width';
                obj.xml_OBJ.RUN();
                Width = obj.xml_OBJ.Value;

                obj.xml_OBJ.Name = 'GreyPatchCoords.Height';
                obj.xml_OBJ.RUN();
                Height = obj.xml_OBJ.Value;

                obj.box_X_End = obj.box_X_Start + Width;
                obj.box_Y_End = obj.box_Y_Start + Height;  
%                 obj.xml_display_enable = true;
                if obj.xml_display_enable == true
                    obj.box_enable = true;
                    obj.XMLInfo_OBJ.Visible = true;
                    obj.XMLInfo_OBJ.xml_file_found = 'TRUE';
                    obj.XMLInfo_OBJ.greycords_height = Height;
                    obj.XMLInfo_OBJ.greycords_width = Width;
                    obj.XMLInfo_OBJ.greycords_x = obj.box_X_Start;
                    obj.XMLInfo_OBJ.greycords_y = obj.box_Y_Start;
                end
            else
                obj.box_enable = false;
                obj.XMLInfo_OBJ.Visible = true;
                obj.XMLInfo_OBJ.xml_file_found = 'FALSE';
                obj.XMLInfo_OBJ.greycords_height = 0;
                obj.XMLInfo_OBJ.greycords_width = 0;
                obj.XMLInfo_OBJ.greycords_x = 0;
                obj.XMLInfo_OBJ.greycords_y = 0;
                disp(['Don''t update the ROI. Do something else']) 
            end
        end
    end
    methods (Hidden = true) % Visible draggable box
        function BoxSelection(obj)
            obj.DrawRectangles;
            if obj.box_enable == 1
                set(obj.handles.rect,'Visible','on');
            else
                set(obj.handles.rect,'Visible','off');
            end
            addlistener(obj,'box_enable','PostSet',@obj.boxEnableUpdate);
            addlistener(obj,{'box_X_Start','box_Y_Start','box_X_End','box_Y_End'},'PostSet',@obj.boxResize);
            addlistener(obj,'imageOUT','PostSet',@obj.updateImage);
            addlistener(obj,'Visible','PostSet',@obj.updateVisible);  
        end
        function boxEnableUpdate(varargin)
            %%
            obj = varargin{1};
            if obj.box_enable == 1
                try
                set(obj.handles.rect,'Visible','on')
                obj.handles.rect.setResizable(false);
                end
                set(obj.handles.menu.box.master,'Enable','on')
            else
                try
                set(obj.handles.rect,'Visible','off')
                obj.handles.rect.setResizable(false);
                end
                set(obj.handles.menu.box.master,'Enable','off')
            end
        end
        function DrawRectangles(obj)
            %%
            box = [obj.box_X_Start, obj.box_Y_Start, obj.box_X_End - obj.box_X_Start, obj.box_Y_End - obj.box_Y_Start];
            try
            obj.handles.rect = imrect(gca, box);
            obj.handles.rect.setResizable(false);
            obj.handles.rect.setPositionConstraintFcn(@obj.PositionConstraint);
            end
        end
        function boxResize(varargin)
            %%
            obj = varargin{1};
            box = [obj.box_X_Start, obj.box_Y_Start, obj.box_X_End - obj.box_X_Start, obj.box_Y_End - obj.box_Y_Start];
            obj.handles.rect.setPosition(box);
        end
        function constrained_position = PositionConstraint(varargin)
           obj = varargin{1};
           constrained_position = [obj.box_X_Start, obj.box_Y_Start, obj.box_X_End - obj.box_X_Start, obj.box_Y_End - obj.box_Y_Start];
        end
    end
    methods (Hidden = true) % Zoom tool bar
        function ZoomIn(varargin)
            %%
            obj = varargin{1};
            obj.Scroller_OBJ.Zoom_StepIn();
        end
        function ZoomOut(varargin)
            %%
            obj = varargin{1};
            obj.Scroller_OBJ.Zoom_StepOut();
        end
    end
    methods (Hidden = true) % imshow features
        function AddMagBox(obj)
            obj.handles.hMagBox = immagbox(obj.handles.figure,obj.handles.image_DISPLAY);
            pos = get(obj.handles.hMagBox,'Position');
            FigPos = get(obj.handles.figure,'Position');
            set(obj.handles.hMagBox,'Position',[FigPos(3)-59 2 pos(3) pos(4)]); 
        end
        function SetMinFigSize(obj)
                MinFigWidth = 200;
                MinFigHeight = 200;
                
                FigPos = get(obj.handles.figure,'Position');
                if FigPos(3) < MinFigWidth
                	FigPos(3) = MinFigWidth;
                end
                if FigPos(4) < MinFigHeight
                	FigPos(4) = MinFigHeight;
                end
                set(obj.handles.figure,'Position',FigPos);
                drawnow;            
        end
        function logic = CheckMinFig(obj)
            logic = true;
            MinFigWidth = 200;
            MinFigHeight = 200;
            FigPos = get(obj.handles.figure,'Position');
            if FigPos(3) < MinFigWidth
               logic = false;
            end 
            if FigPos(4) < MinFigHeight
                FigPos(4) = MinFigHeight;
                logic = false;
            end  
            if logic == false
               disp('detected wrong size') 
            end
        end
        function Resize(varargin)
            obj = varargin{1};
            try
                %%
                logic = false;
                while logic == false
                    logic = obj.CheckMinFig();
                    obj.SetMinFigSize();
                    pause(0.01)
                    drawnow;
                end
                
                %%
                pos = get(obj.handles.hMagBox,'Position');
                FigPos = get(obj.handles.figure,'Position');
                set(obj.handles.hMagBox,'Position',[FigPos(3)-61 2 pos(3) pos(4)]); 

                %% Resizing of the image viewer
                obj.Scroller_OBJ.ResizeBottom(); 
                
                %% [2,23,489,305]
                set(obj.handles.background,'Position',[2,23,FigPos(3),FigPos(4)]);
            end
        end
    end
    methods (Hidden = true) % METRIC (Hidden = true)
        function h = MasterMenu(obj,MetricType,Label,Enable)
            h.parent = uimenu(obj.handles.figure,   'Label',    Label,  'Visible', Enable);
            %%
            h = obj.LoadSetOfMetric(MetricType,     'box',              h);
            h = obj.LoadSetOfMetric(MetricType,     'image',            h);
            h = obj.LoadSetOfMetric(MetricType,     'line',             h);
        end
        function h = LoadSetOfMetric(obj,MetricType,Type,h)
            %% MetricType = CustomerName, Metric, KTouch_Metrics, or Samsung_Metrics
            Metric = obj.(MetricType);
            n = find(strcmpi(Metric(:,3),Type));
            if not(isempty(n))
                if strcmpi(Type,'image')
                    h.(Type).master = uimenu(h.parent,'Label','full image');
                else
                    h.(Type).master = uimenu(h.parent,'Label',Type);
                end
                BoxMetric = Metric(n,:);
                x = size(BoxMetric,1);
                for i = 1:x
                    h = obj.CreatePullDown(MetricType, BoxMetric{i,1}, h, Type);     % histogram
                end
            else
                h.(Type).master = uimenu(h.parent,'Label',     Type, ...
                                                  'Enable',   'off');                
            end            
        end
        function wb_stats_prediction_Callback(varargin)
            %%
            obj = varargin{1};
            object = wb_stats_prediction('InputObject',obj);
            object.imageIN = obj.imageOUT;
            object.RUN
            obj.ObjectPullDown(object)
%             obj.ObjectPullDown(hist)
        end
        function pdf_map_detection_Callback(varargin)
            %%
            obj = varargin{1};
            disp('hello')
            object = PDF_DetectionMap('InputObject',obj);
            object.imageIN = obj.imageOUT;
            object.RUN
            obj.ObjectPullDown(object)
%             obj.ObjectPullDown(hist)
        end
        function h = CreatePullDown(obj,MetricType,Name,h,Type)
            %%
            Metrics = obj.(MetricType);
            
            %%
            MetricNames = Metrics(:,1);
            n = find(strcmpi(MetricNames,Name));
            LabelName = Metrics(n,:);
            %%
            n = find(strcmpi(LabelName(:,3),Type));
            if isempty(n)
               error('No metric of this type available') 
            end
            LabelName = LabelName{n,5};
            %%
            h.(Type).(Name) = uimenu(h.(Type).master,'Label',LabelName);
            %%
            set(h.(Type).(Name),'Callback',@(x,y)obj.GenericMetricLoad(MetricType,Name,Type));               
        end
        function GenericMetricLoad(varargin)
            x = size(varargin,2);
            
            obj = varargin{1};
            MetricType = varargin{2};
            Name = varargin{3};
            Type = varargin{4};
            if x > 4
                Visible = varargin{5};
            else
                Visible = true;
            end
            
            %% Check the figure is not already open
            % If open return as multiple metric of the same thing is not
            % supported. 
            try
                Names = fieldnames(obj.MetricOpenStatus.(Type));
                n = find(strcmpi(Names,Name));
                if not(isempty(n))
                    if strcmpi(obj.MetricOpenStatus.(Type).(Name),'open');
                        disp('Already loaded') 
                        figure(obj.handles.(Type).(Name).handles.figure); % bring the figure to the top to make it obvious it's still loaded. 
                        return
                    end
                end
            end
            
            %%
            disp('Trying to run init metric')
            Metric = obj.(MetricType);
            
            MetricNames = Metric(:,1);
            n = find(strcmpi(MetricNames,Name));
            
            ObjectInspectMode = Metric{n,2};
            RunOnStartUp = Metric{n,4};   
            
            [handle] = feval(Name,       'InputObject',  obj, ...
                                         'Type',         Type, ...
                                         'Visible',      false);
            
            switch Type
                case 'line'
                    handle.imageIN = obj.imageOUT_line;
                case 'image'
                    handle.imageIN = obj.imageOUT;
                case 'box'
                    handle.imageIN = obj.imageOUT_cropped;
                otherwise
                    error('type not recognised')
            end
            if RunOnStartUp == true
                handle.RUN;
            end
            switch ObjectInspectMode
                case 'Pulldown'
                    obj.ObjectPullDown(handle);
                case 'StandAlone'
                    ObjectInspector(handle); 
                case 'None'
                    %do nothing.
            end
            obj.handles.(Type).(Name) = handle;   
            obj.MetricOpenStatus.(Type).(Name) = 'open';
            
            %% Add a function to the close figure to monitor the figure status
            try
            set(obj.handles.(Type).(Name).handles.figure,'CloseRequestFcn',@(x,y)obj.CloseMetric(Name, obj.handles.(Type).(Name), Type));
            
            %% Move to a valid position
            MetricPosition = get(obj.handles.(Type).(Name).handles.figure,'Position');
            MainFigPosition = get(obj.handles.figure,'Position');
            Position = MetricPosition;
            Position(1:2) = MainFigPosition(1:2);
            Position(2) = Position(2) + MainFigPosition(4)-MetricPosition(4) - 84;
            Position(1) = Position(1) + 7;
            set(obj.handles.(Type).(Name).handles.figure,'Position',Position);
            end
            
            handle.Visible = Visible;
        end
        function CloseMetric(varargin)
           %
           obj = varargin{1};
           Name = varargin{2};
           Handle = varargin{3};
           Type = varargin{4};
           obj.MetricOpenStatus.(Type).(Name) = 'closed';
           delete(Handle.ListenerHandle); %delete listener
           delete(Handle.handles.figure);
        end
        function ObjectPullDown(obj,object)
            figHandle = object.handle.figure;
            set(figHandle,'MenuBar','none');
            h.parent = uimenu(figHandle);
            set(h.parent,'Label','Options');
            h.Save = uimenu(h,'Label','Inspect');
            set(h.Save,'Callback',@(x,y)obj.OpenObjectInspector(object));
        end  
    end
    methods (Hidden = true) %Image Processing
        function ProcessPullDown(obj)
            h.parent = uimenu(obj.handles.figure);
            if obj.Process_Enable == true
                Process_Enable = 'on';
            else
                Process_Enable = 'off';
            end
            set(h.parent,'Label','ProcessImage','Enable',Process_Enable);   
            
            
            %% White Balance
            h.whitebalance = uimenu(h.parent, 'Label', 'WB');
            obj.WhiteBalance_PullDown(h);
        end
        function WhiteBalance_PullDown(obj,h)
            % op_pdf_colours_curve0
            handles = uimenu(h.whitebalance, 'Label',    'Grey World');
            set(handles,        'Callback', @obj.GreyWorld); 
        end
        function GreyWorld(varargin)
            
            %%
            obj = varargin{1};
            OBJ = WhiteBalance('imageIN',obj.imageOUT);
            OBJ.RUN();
            obj.imageOUT = OBJ.imageOUT;
        end
    end
    methods (Hidden = true) % DEBUG
        function DebugPullDown(obj)
            h.parent = uimenu(obj.handles.figure);
            if obj.Debug_Enable == true
                Debug_Enable = 'on';
            else
                Debug_Enable = 'off';
            end
            set(h.parent,'Label','Debug','Enable',Debug_Enable);   
            
            
            %% White Balance
            h.whitebalance = uimenu(h.parent,'Label','White Balance');
            obj.BuildWhiteBalancePullDown(h);
            
            %% Lens Shading
            h.lenshading = uimenu(   h.parent, ...
                                    'Label','Lens Shading');
            obj.BuildLensShadingPullDown(h);
        end
        function BuildLensShadingPullDown(obj,h)
            h.LS_SurfacePLot = uimenu(h.lenshading,'Label','Applied LS Surface Plot');
            set(h.LS_SurfacePLot,'Callback',@obj.LS_SurfacePLot_RUN);
        end
        function LS_SurfacePLot_RUN(varargin)
            obj = varargin{1};
            disp('LS hello') 
            [PATH,NAME,EXT] = fileparts(obj.ImageName);
            filename = [NAME,'.sim_log.txt']
            
            LSV = LensShadingViewer(    'Path',PATH, ...
                                        'filename',filename);
            LSV.RUN;
        end
        function BuildWhiteBalancePullDown(obj,h)
            %
            Exists = obj.ColourWeightPlotter_Check(0,'op_pdf_colours_curve');
            
            %
            if Exists == true
                h.colourweight = uimenu(h.whitebalance, 'Label','colour weight plots', ...
                                                        'Enable','on');
            else
                h.colourweight = uimenu(h.whitebalance, 'Label','colour weight plots', ...
                                                        'Enable','off');
            end
            
            % op_pdf_colours_curve0
            h.op_pdf_colours_curve0 = uimenu(h.colourweight,'Label','op_pdf_colours_curve0');
            set(h.op_pdf_colours_curve0,'Callback',@(x,y)obj.ColourWeightPlotter_RUN(0,'op_pdf_colours_curve'));
            
            % op_pdf_colours_curve1
            h.op_pdf_colours_curve1 = uimenu(h.colourweight,'Label','op_pdf_colours_curve1');
            set(h.op_pdf_colours_curve1,'Callback',@(x,y)obj.ColourWeightPlotter_RUN(1,'op_pdf_colours_curve'));            
            
            % op_colour_hist_curve0
            h.op_colour_hist_curve0 = uimenu(h.colourweight,'Label','op_colour_hist_curve0');
            set(h.op_colour_hist_curve0,'Callback',@(x,y)obj.ColourWeightPlotter_RUN(0,'op_colour_hist_curve'));
            
            % op_pdf_colours_curve1
            h.op_colour_hist_curve1 = uimenu(h.colourweight,'Label','op_colour_hist_curve1');
            set(h.op_colour_hist_curve1,'Callback',@(x,y)obj.ColourWeightPlotter_RUN(1,'op_colour_hist_curve'));
            
            % op_weighted_colours_curve0
            h.op_weighted_colours_curve0 = uimenu(h.colourweight,'Label','op_weighted_colours_curve0');
            set(h.op_weighted_colours_curve0,'Callback',@(x,y)obj.ColourWeightPlotter_RUN(0,'op_weighted_colours_curve'));
            
            % op_weighted_colours_curve1
            h.op_weighted_colours_curve1 = uimenu(h.colourweight,'Label','op_weighted_colours_curve1');
            set(h.op_weighted_colours_curve1,'Callback',@(x,y)obj.ColourWeightPlotter_RUN(1,'op_weighted_colours_curve'));
            
      
            
            
            %% op_weighted_colours_curve1
            Exists = obj.wb_stats_image_Check();
            if Exists == true
            h.wb_stats_image = uimenu(h.whitebalance,   'Label',    'wb_stats_image', ...
                                                        'Enable',   'on', ...
                                                        'Callback', @obj.wb_stats_image_RUN);
            else
            h.wb_stats_image = uimenu(h.whitebalance,   'Label',    'wb_stats_image', ...
                                                        'Enable',   'off', ...
                                                        'Callback', @obj.wb_stats_image_RUN);  
                                                    
     
            end    
            
            %% bayesian white balance plotter.
            h.idealgainplotter = uimenu(h.whitebalance,'Label','bayes limits plotter');
            set(h.idealgainplotter,'Callback',@obj.BayesLimitsPlotter);   
            
            %% op_weighted_colours_curve1
            h.wb_stats_image_from_tiff = uimenu(h.whitebalance,'Label','wb_stats_image_from_tiff');
            set(h.wb_stats_image_from_tiff, 'Callback',@obj.wb_stats_calc_from_tiff_RUN);     
            
            %% plotAWB Scatter3D
            h.Scatter3D = uimenu(h.whitebalance,'Label','Scatter3D');
            set(h.Scatter3D,'Callback',@(x,y)obj.plotAWBDebug_RUN('Scatter3D'));
            
            %% plotAWB Surface3D
            h.Surface3D = uimenu(h.whitebalance,'Label','Surface3D');
            set(h.Surface3D,'Callback',@(x,y)obj.plotAWBDebug_RUN('Surface3D'));
            
            %% plotAWB ContourPlot_Posteriors
            h.ContourPlot_Posteriors = uimenu(h.whitebalance,'Label','ContourPlot_Posteriors');
            set(h.ContourPlot_Posteriors,'Callback',@(x,y)obj.plotAWBDebug_RUN('ContourPlot_Posteriors'));
            
            %% plotAWB ContourPlot_Priors
            h.ContourPlot_Priors = uimenu(h.whitebalance,'Label','ContourPlot_Priors');
            set(h.ContourPlot_Priors,'Callback',@(x,y)obj.plotAWBDebug_RUN('ContourPlot_Priors'));
            
            %% Grids
            h.p_t_prior.grids = uimenu(h.whitebalance,'Label','p_t_prior.grids');
            set(h.p_t_prior.grids,'Callback',@(x,y)obj.p_t_prior_RUN('grids',NaN));   
            
            %% pdf_weights_vs_CT
            h.pdf_weights_vs_CT_Grid0 = uimenu(h.whitebalance,'Label','pdf_weights_vs_CT - Grid0');
            set(h.pdf_weights_vs_CT_Grid0,'Callback',@(x,y)obj.pdf_weights_vs_CT_RUN(0)); 
            
            %% pdf_weights_vs_CT
            h.pdf_weights_vs_CT_Grid1 = uimenu(h.whitebalance,'Label','pdf_weights_vs_CT - Grid1');
            set(h.pdf_weights_vs_CT_Grid1,'Callback',@(x,y)obj.pdf_weights_vs_CT_RUN(1));             
        end
        function BayesLimitsPlotter(varargin)
           %%
           obj = varargin{1};
           [path,filename,ext] = fileparts(obj.ImageName);
           IG_OBJ = IdealGains('ImShow_OBJ',obj,'ImageSelected',[filename,ext],'ImagePath',[path,'\']);
           IG_OBJ.RUN();
        end
        function ColourWeightPlotter_RUN(obj,CurveNum,filename_str)
            %%
            cp = ColourWeightPlotter;
            [path,filename,ext] = fileparts(obj.ImageName);
            cp.Name = filename;
            cp.Path = path;
            cp.curve = CurveNum;
            cp.filename_str = filename_str;
            cp.RUN;
        end
        function Exists = ColourWeightPlotter_Check(obj,CurveNum,filename_str)
            cp = ColourWeightPlotter;
            [path,filename,ext] = fileparts(obj.ImageName);
            cp.Name = filename;
            cp.Path = path;
            cp.curve = CurveNum;
            cp.filename_str = filename_str;
            Exists = cp.CheckFileExists;
        end
        function wb_stats_image_RUN(varargin) %NO ERROR
            %%
            obj = varargin{1};
            [path,filename,ext] = fileparts(obj.ImageName);
            
            wb = wb_stats_image;
            wb.bitDepth = 11;
            wb.filename = fullfile(path,[filename,'.awb_stats_mean.csv']);
            wb.RUN;
        end
        function Exists = wb_stats_image_Check(obj) %NO ERROR
            [path,filename,ext] = fileparts(obj.ImageName);
            
            wb = wb_stats_image;
            wb.bitDepth = 11;
            wb.filename = fullfile(path,[filename,'.awb_stats_mean.csv']);
            
            Exists = wb.CheckFileExists; 
        end
        function wb_stats_calc_from_tiff_RUN(varargin) %NO ERROR
            obj = varargin{1};
           [path,filename,ext] = fileparts(obj.ImageName);
            wb = wb_stats_calc_from_tiff;
            wb.Path = path;
            wb.filename = [filename,'_from_pipeline_wg.tiff'];
            wb.RUN();
        end
        function wb_stats_image_scatter_RUN(varargin) %NO ERROR
            %%
            obj = varargin{1};
            [path,filename,ext] = fileparts(obj.ImageName);
            
            wb = wb_stats_image_scatter;
            wb.filename = fullfile(path,[filename,'.awb_stats_mean.csv']);
            wb.RUN;
        end
        function p_t_prior_RUN(varargin) %NO ERROR
            %%
            obj = varargin{1};
            mode = varargin{2};
            gridNo = varargin{3};
            [path,filename,ext] = fileparts(obj.ImageName); 
            
            ptPrior = Decode_GridProbs;
            ptPrior.CurveNo = 0;
            ptPrior.Path = path;
            ptPrior.name = fullfile([filename]);
            ptPrior.fileName = [];
            
            ptPrior.RUN;
            r_nrm = ptPrior.DATASET_OUT.r_nrm
            b_nrm = ptPrior.DATASET_OUT.b_nrm
            figure, plot(r_nrm,b_nrm,'rx'); hold on; 
            
            ptPrior.CurveNo = 1;
            ptPrior.Path = path;
            ptPrior.name = fullfile([filename]);
            ptPrior.fileName = [];
            
            ptPrior.RUN;
            r_nrm = ptPrior.DATASET_OUT.r_nrm
            b_nrm = ptPrior.DATASET_OUT.b_nrm
            plot(r_nrm,b_nrm,'bx');
        end
        function plotAWBDebug_RUN(obj,mode)
            %%
            awb_OBJ = plotAWBDebug;
            awb_OBJ.mode = mode;
            awb_OBJ.fileName = strrep(obj.ImageName,'.bmp','.t_grid_probs_pass_2_curve_0.csv');
            awb_OBJ.RUN;
        end  %NO ERROR
    end
    methods (Hidden = true)
        function PipeLineView_PullDown(obj)
            %%
            h.parent = uimenu(obj.handles.figure);
            if obj.PipeView_Enable == true
                PipeView_Enable = 'on';
            else
                PipeView_Enable = 'off';
            end
            set(h.parent,'Label','PipeView','Enable',PipeView_Enable);   
            
            
            %% BAYER
         
%             obj.handles.pipe.tx = uimenu(h.parent,'Label','TX - Transposer');
%             set(obj.handles.pipe.tx, 'Callback',@(x,y)obj.ImBD_RUN('tx'));
            
            obj.handles.pipe.bl = uimenu(h.parent,'Label','BL - Black Level');
            set(obj.handles.pipe.bl, 'Callback',@(x,y)obj.ImBD_RUN('bl'));

%             obj.handles.pipe.bd = uimenu(h.parent,'Label','BD - Bayer denoise');
%             set(obj.handles.pipe.bd, 'Callback',@(x,y)obj.ImBD_RUN('bd'));
            
            obj.handles.pipe.ls = uimenu(h.parent,'Label','LS - Lens Shading');
            set(obj.handles.pipe.ls, 'Callback',@(x,y)obj.ImBD_RUN('ls')); 
            
            obj.handles.pipe.wg = uimenu(h.parent,'Label','WG - White balance/gain');
            set(obj.handles.pipe.wg, 'Callback',@(x,y)obj.ImBD_RUN('wg'));             
            
            obj.handles.pipe.dp = uimenu(h.parent,'Label','DP - Defective pixel auto correction');
            set(obj.handles.pipe.dp, 'Callback',@(x,y)obj.ImBD_RUN('dp'));  

            obj.handles.pipe.stills = uimenu(h.parent,'Label','STILLS');
            set(obj.handles.pipe.stills, 'Callback',@(x,y)obj.ImBD_RUN('stills'));
            
%             obj.handles.pipe.st = uimenu(h.parent,'Label','ST - Statistics');
%             set(obj.handles.pipe.st, 'Callback',@(x,y)obj.ImBD_RUN('st'));
%             

%             
%             obj.handles.pipe.dp = uimenu(h.parent,'Label','DP - Defective pixel auto correction');
%             set(obj.handles.pipe.dp, 'Callback',@(x,y)obj.ImBD_RUN('dp'));   
%             
%             obj.handles.pipe.rs = uimenu(h.parent,'Label','RS - Bayer resampling');
%             set(obj.handles.pipe.rs, 'Callback',@(x,y)obj.ImBD_RUN('rs'));    
%             
%             obj.handles.pipe.xc = uimenu(h.parent,'Label','XC - Crosstalk correction');
%             set(obj.handles.pipe.xc, 'Callback',@(x,y)obj.ImBD_RUN('xc'));           
%             
%             %% RGB
%             %demosaic? 
%             obj.handles.pipe.dm = uimenu(h.parent,'Label','DM - Demosaicing/Sharpening');
%             set(obj.handles.pipe.dm, 'Callback',@(x,y)obj.ImBD_RUN('dm'));           
%             
%             % colour correction? 
%             %gamma
%             obj.handles.pipe.gm = uimenu(h.parent,'Label','GM - Gamma correction');
%             set(obj.handles.pipe.gm, 'Callback',@(x,y)obj.ImBD_RUN('gm'));    
            
%             %% YUV
%             obj.handles.pipe.yg = uimenu(h.parent,'Label','YG - YCbCr conversion');
%             set(obj.handles.pipe.yg, 'Callback',@(x,y)obj.ImBD_RUN('yg'));             
%             
%             obj.handles.pipe.fc = uimenu(h.parent,'Label','FC - False colour suppression');
%             set(obj.handles.pipe.fc, 'Callback',@(x,y)obj.ImBD_RUN('fc'));               
%             
%             obj.handles.pipe.cp = uimenu(h.parent,'Label','CP - Colour processing');
%             set(obj.handles.pipe.cp, 'Callback',@(x,y)obj.ImBD_RUN('cp'));               
%             
%              
%             obj.handles.pipe.gd = uimenu(h.parent,'Label','GD - Distortion correction/high resolution resize');
%             set(obj.handles.pipe.gd, 'Callback',@(x,y)obj.ImBD_RUN('gd'));             
% 
%             obj.handles.pipe.ho = uimenu(h.parent,'Label','HR - High resolution output');
%             set(obj.handles.pipe.ho, 'Callback',@(x,y)obj.ImBD_RUN('ho'));      
%             
%             obj.handles.pipe.cc = uimenu(h.parent,'Label','CC - Colour conversion');
%             set(obj.handles.pipe.cc, 'Callback',@(x,y)obj.ImBD_RUN('cc'));     
%             
%             obj.handles.pipe.yc = uimenu(h.parent,'Label','YC - YUV colour conversion/colour correction');
%             set(obj.handles.pipe.yc, 'Callback',@(x,y)obj.ImBD_RUN('yc'));            
            
            
            %% STAGE UNKNOWN

%             
%             obj.handles.pipe.yd = uimenu(h.parent,'Label','YD - YCbCr denoise');
%             set(obj.handles.pipe.yd, 'Callback',@(x,y)obj.ImBD_RUN('yd'));       
% 
%             
%             obj.handles.pipe.co = uimenu(h.parent,'Label','CO - Clear overlaps');
%             set(obj.handles.pipe.co, 'Callback',@(x,y)obj.ImBD_RUN('co'));    
%             

%             h.lr = uimenu(h.parent,'Label','LR - Low resolution resize');
%             set(h.lr, 'Callback',@(x,y)obj.ImBD_RUN('lr'));   
            

            
%             obj.handles.pipe.lo = uimenu(h.parent,'Label','LO - Low resolution output');
%             set(obj.handles.pipe.lo, 'Callback',@(x,y)obj.ImBD_RUN('lo'));
%             
%             obj.handles.pipe.sw = uimenu(h.parent,'Label','SW - Software stage output');
%             set(obj.handles.pipe.sw, 'Callback',@(x,y)obj.ImBD_RUN('sw'));         
%             
%             obj.handles.pipe.ca = uimenu(h.parent,'Label','CA - Chromatic aberration correction');
%             set(obj.handles.pipe.ca, 'Callback',@(x,y)obj.ImBD_RUN('ca'));
%             
%             obj.handles.pipe.cb = uimenu(h.parent,'Label','CB - Colour bias/preferred colours');
%             set(obj.handles.pipe.cb, 'Callback',@(x,y)obj.ImBD_RUN('cb'));   
        end
        function ImBD_RUN(varargin)
            %%
            obj = varargin{1};
            stage = varargin{2};
            %%
            switch lower(stage)
                %% RGB Assumed
                case {      'ho','sw', ...
                            'yg', 'yc', ...
                            'gm'}
                    obj.imageOUT =  image_IN.*2^3;  
                case {'stills'}
                    image.image = [];
                    image.type = 'rgb';
                    image.fsd = 1;
                    obj.imageOUT =  image;
                    
                    image_IN = imread(obj.ImageName); 
                    image.image = image_IN;
                    image.type = 'rgb';
                    if strcmpi(class(image_IN),'uint8')
                        image.fsd = 255;
                    else
                        error('image depth not supported') 
                    end
                    
                    image.bitdepth = 8;
                    
                    obj.imageOUT =  image;                    
                    
                case {'bl'} % bayer start
                    image.image = [];
                    image.type = 'bayer';
                    image.fsd = 1;
                    obj.imageOUT =  image;
                    
                    [pathname, filename] = fileparts(obj.ImageName);
                    filename = [filename,'.from_pipeline_',stage,'.tiff'];
                    image_IN = imread(fullfile(pathname,filename));
                    
                    imageOUT(:,:,1) = double(image_IN)./2^10;
                    imageOUT(:,:,2) = double(image_IN)./2^10;
                    imageOUT(:,:,3) = double(image_IN)./2^10;
                    
                    image.image = imageOUT;
                    image.type = 'bayer';
                    image.fsd = 1;
                    image.bitdepth = 10;
                    obj.imageOUT =  image;
                    
                case {'bd','tx','ls','st','wg','dp'} % images are blue
                    image.image = [];
                    image.type = 'bayer';
                    image.fsd = 1;
                    obj.imageOUT =  image;
                    
                    [pathname, filename] = fileparts(obj.ImageName);
                    filename = [filename,'.from_pipeline_',stage,'.tiff'];
                    image_IN = imread(fullfile(pathname,filename));
                    
                    imageOUT(:,:,1) = double(image_IN)./2^13;
                    imageOUT(:,:,2) = double(image_IN)./2^13;
                    imageOUT(:,:,3) = double(image_IN)./2^13;
                    image.image = imageOUT;
                    image.type = 'bayer';
                    image.fsd = 1;
                    image.bitdepth = 13;
                    obj.imageOUT =  image;
                    
%                 case {'dp','rs','xc','dm'}
%                     imageOUT(:,:,1) = double(image_IN)./2^14;
%                     imageOUT(:,:,2) = double(image_IN)./2^14;
%                     imageOUT(:,:,3) = double(image_IN)./2^14;
%                     obj.imageOUT =  imageOUT;                    
                otherwise 
                    obj.imageOUT =  image_IN./2^6;
            end
            names = fieldnames(obj.handles.pipe);
            x = max(size(names));
            for i  = 1:x
               set(obj.handles.pipe.(names{i}),'Checked','off') ;
            end
            set(obj.handles.pipe.(stage),'Checked','on');
        end
    end
    methods (Hidden = true) % UI box selection
        function parent = AddToolBar(obj,figureName)
            %%
            obj.FileMenu_OBJ = FileMenu(    'ImageName',        figureName, ...
                                            'figure_handle',    obj.handles.figure, ...
                                            'Load_Visible',     obj.Load_Visible, ...
                                            'Save_Visible',     obj.Save_Visible, ...
                                            'image_handle',     obj);
            
            parent = obj.FileMenu_OBJ.handles.menu_handle;                        
            h = obj.FileMenu_OBJ.handles.toolbar_handle;
            obj.handles.toolbar.master = h;
            obj.FileMenu_OBJ.LoadImage_OBJ.addlistener(  'image', 'PostSet', @obj.UpdateImageFromLoad);            
            
            %% arrow OLD
            try
                filename = fullfile( matlabroot,'toolbox','matlab','icons','pointer');
                load(filename)
                hpt = uitoggletool(h,   'CData',cdata, ...
                                        'TooltipString','Arrow', ...
                                        'Separator','on');
                obj.handles.pointer = hpt;
                set(obj.handles.pointer,'State','on');
                set(hpt,'ClickedCallback',@obj.Escape2);
            catch
                uiwait(msgbox('pointer toolbar not successfull'));
            end        
            
            %% new line
            try
                filename = fullfile( matlabroot,'toolbox','matlab','icons','line');
                load(filename);
                icon = obj.ChangeBG_Colour(lineCData,   [NaN,NaN,NaN],  [lineCData(1,1,1),lineCData(1,1,2),lineCData(1,1,3)]);
                hpt = uitoggletool(h,'CData',icon,'TooltipString','Line Selection');
                set(hpt,'ClickedCallback',@obj.SelectLine);
                obj.handles.lineSelection = hpt;              
            catch
                uiwait(msgbox('line toolbar not successfull'));
            end            
            
            %% box NEW
            try
                filename = fullfile( matlabroot,'toolbox','matlab','icons','help_block.png');
                [X] = imread(filename);
                X = double(X)/256;
                icon = obj.ChangeBG_Colour(X,           [NaN,NaN,NaN],  [0,0,0]);
                hpt = uitoggletool(h,'CData',icon,'TooltipString','Box Selection');
                set(hpt,'ClickedCallback',@obj.SelectBox);
                obj.handles.boxSelection = hpt;
            catch
                uiwait(msgbox('box toolbar not successfull'));
            end
            
            %% Add XML display
            try 
                %%
                [X,map] = imread('mime_xml.png'); 
                RGB = ind2rgb(X,map);
                icon = obj.ChangeBG_Colour(RGB,    [NaN,NaN,NaN],      [RGB(1,1,1),RGB(1,1,2),RGB(1,1,3)]);
                hpt = uitoggletool(h, 'CData',        icon, ...
                                      'TooltipString','XML Info');
                set(hpt,'OnCallback', @obj.On_DisplayXML_Info);   
                set(hpt,'OffCallback',@obj.Off_DisplayXML_Info);   
                obj.handles.xml_info = hpt;
            catch
                uiwait(msgbox('XML info toolbar not successfull')); 
            end
            
            %% zoom in
            try
                filename = fullfile( matlabroot,'toolbox','matlab','icons','tool_zoom_in.png');
                [X] = imread(filename);
                X = double(X)/2^16;
                icon = obj.ChangeBG_Colour(X,           [NaN,NaN,NaN],  [0,0,0]);
                hpt = uipushtool(h,     'CData',icon, ...
                                        'TooltipString','Zoom In', ...
                                        'Separator','on');
                set(hpt,'ClickedCallback',@obj.ZoomIn);
                obj.handles.zoomin = hpt;
            catch
                uiwait(msgbox('zoomin toolbar not successfull'));
            end
            

            %% zoom out
            try
                filename = fullfile( matlabroot,'toolbox','matlab','icons','tool_zoom_out.png');
                [X] = imread(filename);
                X = double(X)/2^16;
                icon = obj.ChangeBG_Colour(X,           [NaN,NaN,NaN],  [0,0,0]);
                hpt = uipushtool(h,'CData',icon,'TooltipString','Zoom Out');
                set(hpt,'ClickedCallback',@obj.ZoomOut);
                obj.handles.zoomout = hpt;
            catch
                uiwait(msgbox('zoomout toolbar not successfull'));
            end
            
            %% zoom to fit
            try
                [X] = imread('wuib_view_zoom_fit.png');
    %             X = double(X);
                icon = obj.ChangeBG_Colour(X,           [NaN,NaN,NaN],  [X(1,1,1),X(1,1,2),X(1,1,3)]);
                icon = imresize(icon,0.5);
                hpt = uipushtool(h, 'CData',        icon, ...
                                    'TooltipString','Zoom To Fit');
                set(hpt,'ClickedCallback',@obj.Zoom2Fit);
                obj.handles.zoom2fit = hpt;
            catch
                uiwait(msgbox('zoom to fit toolbar not successfull'));
            end
            
            %% zoom 1:1
            try
                [X] = imread('ZoomOne2One.gif');
                X = double(X)/2^8;
                image = zeros(16,16,3);
                image(:,:,1) = X;
                image(:,:,2) = X;
                image(:,:,3) = X;
                icon = obj.ChangeBG_Colour(image,           [NaN,NaN,NaN],  [image(1,1,1),image(1,1,2),image(1,1,3)]);
                hpt = uipushtool(h, 'CData',            icon, ...
                                    'TooltipString',    'Actual Size');
                set(hpt,'ClickedCallback',@obj.Zoom1to1);
                obj.handles.Zoom1to1 = hpt;
            catch
                uiwait(msgbox('zoom to 1to1 toolbar not successfull'));
            end
        end
        function On_DisplayXML_Info(varargin)
            obj = varargin{1};
            
            disp('ON')
            obj.xml_display_enable = true;
            disp(['xml_display_enable:', num2str(obj.xml_display_enable)])
            %%
            if not(isempty(obj.XmlName))
                if iscell(obj.XmlName)
                    obj.InitGreyCords(obj.XmlName{1});   
                else
                    obj.InitGreyCords(obj.XmlName);
                end
            else
               disp('No xml file has been specified') 
            end
            if obj.xml_OBJ.Error == -1
                obj.box_enable = false;
            end
        end
        function Off_DisplayXML_Info(varargin)
            obj = varargin{1};
            obj.xml_display_enable = false;
            disp('OFF')
            obj.box_enable = false;
            obj.XMLInfo_OBJ.Visible = false;
        end
        function Zoom1to1(varargin)
            obj = varargin{1};
            obj.Scroller_OBJ.Zoom1to1();
        end
        function Zoom2Fit(varargin)
           obj = varargin{1};
           obj.Scroller_OBJ.Zoom2fit();
        end
        function SelectBox(varargin)
            %%
            obj = varargin{1};
            drawnow
            if strcmpi(get(obj.handles.boxSelection,'State'),'on')
                disp('SelectBox State on')
                obj.imageProfile_OBJ.Enable = false;
                obj.imageLine_OBJ.Enable = false;
                
                obj.CropSelect_OBJ.Enable = true;
                obj.CropSelect_OBJ.box_OBJ.Enable = true;
                

                
                set(obj.handles.pointer,        'State','off');
                set(obj.handles.boxSelection,   'State','on');
                set(obj.handles.lineSelection,  'State','off'); 
                set(obj.handles.figure ,'Pointer',  'crosshair' );
                
                % check to see if any box metrics are preset on customer
                % pulldown.
                NAMES = fieldnames(obj.handles.customer.box);
                x = max(size(NAMES));
                
                if x > 1 %if metric exists enable box pull down.
                set(obj.handles.customer.box.master,'Enable','on');
                end
                set(obj.handles.menu.box.master,'Enable','on');
            else
                disp('SelectBox State off')
                obj.CropSelect_OBJ.Enable = false;
                obj.CropSelect_OBJ.box_OBJ.Enable = false;
                set(obj.handles.figure ,'Pointer',  'arrow' );
                set(obj.handles.boxSelection,   'State','off');
                set(obj.handles.pointer,        'State','on');
                set(obj.handles.lineSelection,  'State','off');
                
                set(obj.handles.menu.box.master,'Enable','off');
                set(obj.handles.customer.box.master,'Enable','off');
            end
        end
        function CropUpdate(varargin)
            obj = varargin{1};
            obj.imageOUT_cropped = obj.CropSelect_OBJ.imageOUT_cropped;
        end
        function lineUpdate(varargin)
            obj = varargin{1};
            disp('Executing line update')
            obj = varargin{1};
            obj.imageOUT_line = obj.imageProfile_OBJ.imageOUT_line;            
        end
        function SelectLine(varargin)
            obj = varargin{1};
            if strcmpi(get(obj.handles.lineSelection,'State'),'on')
                obj.CropSelect_OBJ.Enable = false;
                obj.CropSelect_OBJ.box_OBJ.Enable = false;
                        
                obj.imageProfile_OBJ.Enable = true;
                obj.imageLine_OBJ.Enable = true;
                
                set(obj.handles.pointer,        'State',    'off'   );
                set(obj.handles.boxSelection,   'State',    'off'   );
                set(obj.handles.lineSelection,  'State',    'on'    ); 
                
                % check to see if any box metrics are preset on customer
                % pulldown.                
                NAMES = fieldnames(obj.handles.customer.line);
                x = max(size(NAMES));
                if x > 1 %if metric exists enable box pull down.
                    set(obj.handles.customer.line.master,'Enable','on');
                end
                set(obj.handles.menu.line.master,'Enable','on');
            else
                
                obj.imageProfile_OBJ.Enable = false;
                obj.imageLine_OBJ.Enable = false;
                
                set(obj.handles.boxSelection,   'State',    'off'   );
                set(obj.handles.pointer,        'State',    'on'    );
                set(obj.handles.lineSelection,  'State',    'off'   );  
                
                set(obj.handles.menu.line.master,'Enable','off');
            end
        end
        function icon_out = ChangeBG_Colour(obj,icon,ColourOut,ColourIn)
            %%
            [x,y,z] = size(icon);
            icons = reshape(icon,x*y,3);
            MASK = (icons(:,1)==ColourIn(1)).*(icons(:,2)==ColourIn(2)).*(icons(:,3)==ColourIn(3));
            n = find(MASK == 1);
            icons(n,1) = ColourOut(1);
            icons(n,2) = ColourOut(2);
            icons(n,3) = ColourOut(3);
            icon_out = reshape(icons,x,y,3);         
        end
        function Escape2(varargin)
            %%
            obj = varargin{1};
            obj.CropSelect_OBJ.Enable = false;
            obj.CropSelect_OBJ.box_OBJ.Enable = false;
            
            obj.imageProfile_OBJ.Enable = false;
            obj.imageLine_OBJ.Enable = false;
                
            set(obj.handles.lineSelection,  'State','off');
            set(obj.handles.boxSelection,   'State','off');
            set(obj.handles.figure ,'Pointer',  'arrow' );
        end
    end
end