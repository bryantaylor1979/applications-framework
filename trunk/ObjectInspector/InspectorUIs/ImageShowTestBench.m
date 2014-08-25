classdef ImageShowTestBench < handle
    properties (SetObservable = true)
       TestImagePath = 'C:\p4\software\projects\isp_tools\software\projects\isp_tools\cambs_matlab\ObjectInspector\InspectorUIs\imageShow_files\TestImages\'
       NumberOfTests = 17; 
       Progess = '';
       DATASET = dataset([]);
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = ImageShowTestBench();
            ObjectInspector(obj)
        end
        function RUN(obj)
            for i = 1:obj.NumberOfTests
               obj.Progess = [num2str(i),' of ',num2str(obj.NumberOfTests)];
               Result = obj.(['Test',num2str(i)]);
               PASS(i,1) = Result.PASS;
               TestName{i,1} = Result.TestName;
               ID(i,1) = i;
            end
            obj.DATASET = dataset(  {ID,        'TestID'}, ...
                                    {TestName,  'TestName'}, ...
                                    {PASS,      'PASS'});
        end
    end
    methods (Hidden = true)
        function Result = Test1(obj) % Multiple instances
            %% THIS WILL CRASH MATLAB IF FAILS - Multi
            Result.TestName = 'Crash Test - Multiple Instances';
            try
                file = [obj.TestImagePath,'001-Baffin-BRCM_20120203_040821.bmp'];
                imageOUT.image = imread(file);
                imageOUT.fsd = 1;
                imageOUT.type = 'rgb';
                obj1 = imageShow(    'imageOUT',     imageOUT, ...
                                    'ImageName',     file);    

                obj2 = imageShow(    'imageOUT',     imageOUT, ...
                                    'ImageName',     file);   

                pause(2);
                close(obj1.handles.figure);
                close(obj2.handles.figure);
                Result.PASS = true;
            catch
                Result.PASS = false;    
            end
        end
        function Result = Test2(obj)
            %% THIS WILL CRASH MATLAB IF FAILS - Single
            file = [obj.TestImagePath,'001-Baffin-BRCM_20120203_040821.bmp'];
            imageOUT = imageCLASS;
            imageOUT.image = imread(file);
            obj1 = imageShow(   'imageOUT',     imageOUT, ...
                                'ImageName',    file);             
            pause(2);
            close(obj1.handles.figure);
            
            % the only warning we should get is 
            [msgstr, msgid] = lastwarn;
            if strcmpi(msgid,'images:initSize:adjustingMag')
                Result.PASS = true;
            else
                Result.PASS = false;
            end
            Result.TestName = 'Open/Close - No Warnings';
        end 
        function Result = Test3(obj)
            %% Load a new image via API. 
            Result.TestName = 'Load via API';
            %%
            image_OBJ = imageShow();  
            IMAGE = get(image_OBJ.handles.image_DISPLAY,'CData');
            if IMAGE(1,1,1) == 0.5
                % no image loaded. Grey backdrop is present. 
                Result.PASS = true;
            else
                % fail. Something else is loaded. 
                Result.PASS = false;
                close(image_OBJ.handles.figure);
                return;
            end
            %%
            image_OBJ.LoadImage2([obj.TestImagePath,'001-Baffin-BRCM_20120203_040821.bmp']);
            IMAGE = get(image_OBJ.handles.image_DISPLAY,'CData');
            if IMAGE(1,1,1) == 52
                % expect pixel value so must be loaded. 
                Result.PASS = true;
            else
                % fail. Something else is loaded. 
                Result.PASS = false;
                close(image_OBJ.handles.figure);
                return;
            end
            close(image_OBJ.handles.figure);
        end
        function Result = Test4(obj)
           %% Max resolution test            
            Result.TestName = 'Max Resolution - 42MP';
            imageOUT = imageCLASS();
            file = [obj.TestImagePath,'nokia_42MP.jpg'];
            imageOUT.image = imread(file);
            imageOUT.fsd = 255;
            imageOUT.type = 'rgb';
            obj1 = imageShow(   'imageOUT',     imageOUT, ...
                                'ImageName',    file);     
            IMAGE = get(obj1.handles.image_DISPLAY,'CData');
            if IMAGE(1,1,1) == 85
                % expect pixel value so must be loaded. 
                Result.PASS = true;
            else
                % fail. Something else is loaded. 
                Result.PASS = false;
            end
            close(obj1.handles.figure);
        end
        function Result = Test5(obj)
           %% minimum resolution test
            Result.TestName = 'Min Resolution - thumb';
            imageOUT = imageCLASS();
            file = [obj.TestImagePath,'small.jpg'];
            imageOUT.image = imread(file);
            imageOUT.fsd = 255;
            imageOUT.type = 'rgb';
            obj1 = imageShow(   'imageOUT',     imageOUT, ...
                                'ImageName',    file);  
            IMAGE = get(obj1.handles.image_DISPLAY,'CData');
            if IMAGE(1,1,1) == 250
                % expect pixel value so must be loaded. 
                Result.PASS = true;
            else
                % fail. Something else is loaded. 
                Result.PASS = false;
            end
            close(obj1.handles.figure);
        end
        function Result = Test6(obj)
           %% Load image with just the name
           Result.TestName = 'LoadImage - by name';
           file = [obj.TestImagePath,'nokia_42MP.jpg'];
           obj1 = imageShow(  'ImageName',    file);    
           IMAGE = get(obj1.handles.image_DISPLAY,'CData');
           if IMAGE(1,1,1) == 85
                % expect pixel value so must be loaded. 
                Result.PASS = true;
           else
                % fail. Something else is loaded. 
                Result.PASS = false;
           end
           close(obj1.handles.figure);
        end
        function Result = Test7(obj) % MULTIPLE IMAGES
           %% Load multiple images
           Result.TestName = 'Multiple Image - Switch';
           files = {    [obj.TestImagePath,'001-Baffin-BRCM_20120203_040821.bmp']; ...
                        [obj.TestImagePath,'20_Baffin_PREF-OFF_No_log.bmp']; ...
                        [obj.TestImagePath,'41_Baffin_PREF-OFF.bmp']; ...
                        [obj.TestImagePath,'51_Baffin_PREF-OFF_Sunny_No_log.bmp']; ...
                        [obj.TestImagePath,'59_Baffin_PREF-OFF_Sunny.bmp']};
           obj1 = imageShow(  'ImageName',    files); 
           
           %%
           Result.PASS = obj.CheckPixelOnDisplay(obj1,52);
           if Result.PASS == false
               close(obj1.handles.figure);
               return
           end
           obj1.mi_OBJ.ImageSelected = '59_Baffin_PREF-OFF_Sunny.bmp';
           Result.PASS = obj.CheckPixelOnDisplay(obj1,142);
           close(obj1.handles.figure);
        end
        function Result = Test8(obj)
            %% Save image through API
            Result.TestName = 'Save Image - via API';
            file = [obj.TestImagePath,'nokia_42MP.jpg'];
            
            tempfile = [obj.TestImagePath,'temp.jpg'];
            image_OBJ = imageShow(  'ImageName',    file); 
            image_OBJ.SaveImage2(tempfile); 
            IMAGE = imread(tempfile);
            if IMAGE(1,1,1) == 81
                Result.PASS = true;
            else
                Result.PASS = false;
            end
            delete(tempfile)
            close(image_OBJ.handles.figure);
        end
        function Result = Test9(obj)
           %% Ensure the load button AND menu do NOT appear
           Result.TestName = 'Load Button - Disabled via API at Start';
           file = [obj.TestImagePath,'nokia_42MP.jpg'];
           image_OBJ = imageShow(  'ImageName',    file, ...
                                   'Load_Visible', false); 
                               
           %%
           Visible = get(image_OBJ.FileMenu_OBJ.LoadImage_OBJ.button_handle,'Visible');
           if strcmpi(Visible,'off')
               Result.PASS = true;
           else
               Result.PASS = false;
           end
           close(image_OBJ.handles.figure);
        end
        function Result = Test10(obj)
           %% Ensure the load button AND menu do NOT appear
           Result.TestName = 'Load Button - Disabled via API after loaded';
           file = [obj.TestImagePath,'nokia_42MP.jpg'];
           image_OBJ = imageShow(  'ImageName',    file, ...
                                   'Load_Visible', true); 
           image_OBJ.Load_Visible = false;                    
                               
           %%
           Visible = get(image_OBJ.FileMenu_OBJ.LoadImage_OBJ.button_handle,'Visible');
           if strcmpi(Visible,'off')
               Result.PASS = true;
           else
               Result.PASS = false;
           end
           close(image_OBJ.handles.figure);
        end
        function Result = Test11(obj)
           %% Ensure the load button AND menu do NOT appear
           Result.TestName = 'Load Button - Enable via API at Start';
           file = [obj.TestImagePath,'nokia_42MP.jpg'];
           image_OBJ = imageShow(  'ImageName',    file, ...
                                   'Load_Visible', true); 
                               
           %%
           Visible = get(image_OBJ.FileMenu_OBJ.LoadImage_OBJ.button_handle,'Visible');
           if strcmpi(Visible,'on')
               Result.PASS = true;
           else
               Result.PASS = false;
           end
           close(image_OBJ.handles.figure);
        end
        function Result = Test12(obj)
           %% Ensure the load button AND menu do NOT appear
           Result.TestName = 'Load Button - Enable via API after loaded';
           file = [obj.TestImagePath,'nokia_42MP.jpg'];
           image_OBJ = imageShow(  'ImageName',    file, ...
                                   'Load_Visible', false); 
           image_OBJ.Load_Visible = true;                    
                               
           %%
           Visible = get(image_OBJ.FileMenu_OBJ.LoadImage_OBJ.button_handle,'Visible');
           if strcmpi(Visible,'on')
               Result.PASS = true;
           else
               Result.PASS = false;
           end
           close(image_OBJ.handles.figure);
        end
        function Result = Test13(obj)
           %% Ensure the load button AND menu do NOT appear
           Result.TestName = 'Save Button - Disabled via API at Start';
           file = [obj.TestImagePath,'nokia_42MP.jpg'];
           image_OBJ = imageShow(  'ImageName',    file, ...
                                   'Save_Visible', false); 
                               
           %%
           Visible = get(image_OBJ.FileMenu_OBJ.SaveImage_OBJ.button_handle,'Visible');
           if strcmpi(Visible,'off')
               Result.PASS = true;
           else
               Result.PASS = false;
           end
           close(image_OBJ.handles.figure);
        end
        function Result = Test14(obj)
           %% Ensure the load button AND menu do NOT appear
           Result.TestName = 'Save Button - Disabled via API after loaded';
           file = [obj.TestImagePath,'nokia_42MP.jpg'];
           image_OBJ = imageShow(  'ImageName',    file, ...
                                   'Save_Visible', true); 
           image_OBJ.Save_Visible = false;                    
                               
           %%
           Visible = get(image_OBJ.FileMenu_OBJ.SaveImage_OBJ.button_handle,'Visible');
           if strcmpi(Visible,'off')
               Result.PASS = true;
           else
               Result.PASS = false;
           end
           close(image_OBJ.handles.figure);
        end
        function Result = Test15(obj)
           %% Ensure the load button AND menu do NOT appear
           Result.TestName = 'Save Button - Enable via API at Start';
           file = [obj.TestImagePath,'nokia_42MP.jpg'];
           image_OBJ = imageShow(  'ImageName',    file, ...
                                   'Save_Visible', true); 
                               
           %%
           Visible = get(image_OBJ.FileMenu_OBJ.SaveImage_OBJ.button_handle,'Visible');
           if strcmpi(Visible,'on')
               Result.PASS = true;
           else
               Result.PASS = false;
           end
           close(image_OBJ.handles.figure);
        end
        function Result = Test16(obj)
           %% Ensure the load button AND menu do NOT appear
           Result.TestName = 'Save Button - Enable via API after loaded';
           file = [obj.TestImagePath,'nokia_42MP.jpg'];
           image_OBJ = imageShow(  'ImageName',    file, ...
                                   'Save_Visible', false); 
           image_OBJ.Save_Visible = true;                    
                               
           %%
           Visible = get(image_OBJ.FileMenu_OBJ.SaveImage_OBJ.button_handle,'Visible');
           if strcmpi(Visible,'on')
               Result.PASS = true;
           else
               Result.PASS = false;
           end
           close(image_OBJ.handles.figure);
        end
        function Result = Test17(obj)
            %%
            Result.TestName = 'Update IMAGE via API';
            file = [obj.TestImagePath,'001-Baffin-BRCM_20120203_040821.bmp'];
            imageOUT = imageCLASS();
            imageOUT.image = imread(file);
            imageOUT.fsd = 255;
            imageOUT.type = 'rgb';
            imageShow_OBJ = imageShow(    'imageOUT',     imageOUT, ...
                                'ImageName',    file);
            Result.PASS = obj.CheckPixelOnDisplay(imageShow_OBJ,52);
            if Result.PASS == false
               close(imageShow_OBJ.handles.figure);
               return
            end
                            
            %%
            file = [obj.TestImagePath,'59_Baffin_PREF-OFF_Sunny.bmp'];           
            imageOUT = imageCLASS();
            imageOUT.image = imread(file);
            imageOUT.fsd = 255;
            imageOUT.type = 'rgb';
            imageShow_OBJ.imageOUT =  imageOUT;     
            Result.PASS = obj.CheckPixelOnDisplay(imageShow_OBJ,142);
            close(imageShow_OBJ.handles.figure);        
        end
    end
    methods (Hidden = true) %NOT INCLUDED 
        function Test25(obj)
            %% Try all the metric and see if these update. 
            % Box - HSV - PASS
            % Box - Lab - PASS
            % Box - Rb norm - PASS
            % Box - Histogram - PASS
            close all
            clear classes
            file = '001-Baffin-BRCM_20120203_040821.bmp';
            imageOUT = imageCLASS();
            imageOUT.image = imread(file);
            imageOUT.fsd = 255;
            imageOUT.type = 'rgb';
            obj = imageShow(    'imageOUT',     imageOUT, ...
                                'ImageName',    file);
            %%                
            file = '59_Baffin_PREF-OFF_Sunny.bmp';           
            imageOUT = imageCLASS();
            imageOUT.image = imread(file);
            imageOUT.fsd = 255;
            imageOUT.type = 'rgb';
            obj.imageOUT =  imageOUT;      
            
            %%
            file = '001-Baffin-BRCM_20120203_040821.bmp';
            imageOUT = imageCLASS();
            imageOUT.image = imread(file);
            imageOUT.fsd = 255;
            imageOUT.type = 'rgb';
            obj.imageOUT =  imageOUT; 
        end
        function Test26(obj)
            %% Raw image load check
            close all
            clear classes
            file = '01_Baffin_MC4_bayer.raw';
            
            %%
            obj = imageShow(    'ImageName',    file, ...
                                'Raw_Support',  true);
            % you should now have a .raw option when you load and image.
        end
        function Test27(obj)
            %% Ensure figures are closed when main window is closed
            close all
            clear classes
            file = '001-Baffin-BRCM_20120203_040821.bmp';
            obj = imageShow(    'ImageName',    file);   
            %load a couple of metric's
            %close the main window
        end
        function Test18(obj)
            %% Debug testing. RUN an image with AWB_debug ON. 
            close all
            clear classes
            file = 'C:\CTT\TuningData\imx175\Output\02_Baffin_MC4_bayer.bmp';
            obj = imageShow(    'ImageName',    file, ...
                                'Debug_Enable', true);              
        end
        function Test19(obj)
            %% CRASH - This is effectively multiple instances. 
            close all
            clear classes
            file = 'C:\CTT\TuningData\imx175\Output\02_Baffin_MC4_bayer.bmp';
            obj = imageShow(    'ImageName',    file, ...
                                'Debug_Enable', true); 
                            
            % load wb_stats metric. 
            % close metric 
            % crash. 
        end
        function Test20(obj)
            %% Ensure grey cords can be displayed. 
            close all
            clear classes
            imageName = '001-Baffin-BRCM_20120203_040821.bmp';
            file =      ['Z:\projects\IQ_tuning_data\zionmo\imx175\2014_Mar_22_15_00_00_phase3_brcm\',imageName];
            xml_file =  ['Z:\projects\IQ_tuning_data\zionmo\imx175\xml\',strrep(imageName,'.bmp','.xml')];
            obj = imageShow(    'ImageName',    file, ...
                                'XmlName',      xml_file, ...
                                'Debug_Enable', true);               
        end
        function Test21(obj)
            %% Ensure grey cords can be displayed. 
            close all
            clear classes
            imageName = '001-Baffin-BRCM_20120203_040821.bmp';
            file =      ['Z:\projects\IQ_tuning_data\zionmo\imx175\2014_Mar_22_15_00_00_phase3_brcm\',imageName];
            xml_file =  ['Z:\projects\IQ_tuning_data\zionmo\imx175\xml\',strrep(imageName,'.bmp','.xml')];
            obj = imageShow(    'ImageName',    file, ...
                                'XmlName',      xml_file, ...
                                'Debug_Enable', true);    
                            
            %%
            imageName = '02_Baffin_PREF-OFF.bmp';                
            obj.XmlName =  ['Z:\projects\IQ_tuning_data\zionmo\imx175\xml\',strrep(imageName,'.bmp','.xml')];          
            
            %%
            imageName = '001-Baffin-BRCM_20120203_040821.bmp';                
            obj.XmlName =  ['Z:\projects\IQ_tuning_data\zionmo\imx175\xml\',strrep(imageName,'.bmp','.xml')];       
        end
        function Test22(obj)
           %% Read in multiple images and multiple xml files
           close all
           clear classes
           
           %%
           root_dir = 'Z:\projects\IQ_tuning_data\zionmo\imx175\';
           files = {    [root_dir, '2014_Mar_22_15_00_00_phase3_brcm\001-Baffin-BRCM_20120203_040821.bmp']; ...
                        [root_dir, '2014_Mar_22_15_00_00_phase3_brcm\02_Baffin_PREF-OFF.bmp']};
           xmlfiles = { [root_dir, 'xml\001-Baffin-BRCM_20120203_040821.xml']; ...
                        [root_dir, 'xml\02_Baffin_PREF-OFF.xml']};
                    
           obj = imageShow(    'ImageName',    files, ...
                                'XmlName',      xmlfiles);  
                            
           % try changing the image selection pull-down. This should change
           % both the image and XML file. 
        end
        function Test23(obj)
           %% Same Test as 22 with a large file list
           close all
           clear classes  
           
           %%
           root_dir = 'Z:\projects\IQ_tuning_data\bgentles\run\';
           Rev = '2014_Mar_26_17_05_07_e222bfa';
           obj = ImageIO(   'Path',         [root_dir,Rev], ...
                            'ImageType',    '.bmp');
           obj.RUN();
           ObjectInspector(obj);
           
           
           %%
           clear files
           x = size(obj.names,1);
           for i = 1:x
               files{i,1} = fullfile(root_dir,Rev,obj.names{i});
               xmlfiles{i,1} = fullfile(root_dir,Rev,strrep(obj.names{i},'.bmp','.xml'));
           end
            
           %%
           obj = imageShow(    'ImageName',    files, ...
                                'XmlName',      xmlfiles);  
        end
    end
    methods (Hidden  = true)
        function obj = ImageShowTestBench(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
        end
        function PASS = CheckPixelOnDisplay(obj,imageShow_OBJ,Value)
            IMAGE = get(imageShow_OBJ.handles.image_DISPLAY,'CData');
            if IMAGE(1,1,1) == Value
                % expect pixel value so must be loaded. 
                PASS = true;
            else
                % fail. Something else is loaded. 
                PASS = false;
                disp(['Failed: Value was ',num2str(IMAGE(1,1,1))])
            end
        end
    end
end