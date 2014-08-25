classdef Make_Pdf_Wrapper <     handle
    properties (SetObservable = true)
        DataDir = 'C:\p4\software\projects\isp_tools\software\projects\isp_tools\cambs_matlab\ObjectInspector\InspectorUIs\imageShow_files\Metrics\PDF_Wrapper\pdfs\';
        FileName = 'pdf_sky.tga'
        ExtractTGAfromPDF = false
        WriteCSVfile = true;
        InstallDir = 'C:\p4\software\projects\isp_tools\software\projects\isp_tools\cambs_matlab\ObjectInspector\InspectorUIs\imageShow_files\Metrics\PDF_Wrapper\';
        Status
        DosShell
    end
    properties (Hidden = true, SetObservable = true) %outputs
        pdf_image = [] 
        handles
        FileName_LUT = {	'pdf_both_grass_20090625.tga'; ...
                            'pdf_burnt_grass.tga'; ...
                            'pdf_grass.tga'; ...
                            'pdf_horizon_grey.tga'; ...
                            'pdf_neutral_N.tga'; ...
                            'pdf_skin.tga'; ...
                            'pdf_sky.tga'; ...
                            'pdf_sky_20090625.tga'; ...
                            'pdf_sky_N_mod2.tga'; ...
                            'pdf_sky_N.tga'};
                            
    end
    methods
        function Example(obj)
            %% TGA to RLE
            close all 
            clear classes
            obj = Make_Pdf_Wrapper( 'ExtractTGAfromPDF',false, ...
                                    'WriteCSVfile', false, ...
                                    'FileName','pdf_sky.tga');
            ObjectInspector(obj)
            
            %% HTC mod
            close all 
            clear classes
            obj = Make_Pdf_Wrapper( 'DataDir','C:\sourcecode\matlab\Programs\WhiteBalance\PDF\PDF_Wrapper\htc_pdfs\', ...
                                    'ExtractTGAfromPDF',true, ...
                                    'WriteCSVfile', false, ...
                                    'FileName','pdf_sky_N_mod2.tga');               
            obj.RUN()
            figure, imshow(obj.pdf_image)            
            
            %% RLE to TGA
            close all 
            clear classes
            obj = Make_Pdf_Wrapper( 'ExtractTGAfromPDF',true, ...
                                    'WriteCSVfile', false, ...
                                    'FileName','pdf_sky.rle.txt');         
                                
            %% Display RLE
            obj = Make_Pdf_Wrapper( 'ExtractTGAfromPDF',true, ...
                                    'WriteCSVfile', true, ...
                                    'FileName','pdf_sky.rle.txt');   
            obj.RUN()
            figure, imshow(obj.pdf_image)
            
            %% Display TGA
            obj = Make_Pdf_Wrapper( 'ExtractTGAfromPDF',false, ...
                                    'WriteCSVfile', true, ...
                                    'FileName','pdf_sky.tga');   
            figure, imshow(obj.pdf_image)  
            
        end
    end
    methods
        function RUN(obj)
            %%
            obj.Status = 'running';
            drawnow;
            PWD = pwd;
            string = obj.StringBuilder;
            obj.handles.DOS_Shell.CommandStr = string;
            obj.handles.DOS_Shell.RUN;
            
            %%
            
            
            filename = strrep(obj.FileName,'.tga','');
            filename = strrep(filename,'.rle.txt','');
            
            if obj.WriteCSVfile == true
            obj.pdf_image = obj.ReadPdfCsv();
            movefile([obj.InstallDir,'pdf_out.csv'],[obj.DataDir,filename,'_out.csv'],'f')
            end
            cd(PWD)
               
            if obj.ExtractTGAfromPDF == true
            	movefile([obj.InstallDir,'pdf_out.tga'],[obj.DataDir,filename,'_out.tga'],'f')
            else
                movefile([obj.InstallDir,'pdf_out.rle.txt'],[obj.DataDir,filename,'_out.rle.txt'],'f')
            end
            obj.Status = 'complete';
            drawnow;
        end
    end
    methods (Hidden = true) %Support functions
        function pdf_image = ReadPdfCsv(obj)
           %%
           pdf_image = uint8(xlsread([obj.InstallDir,'pdf_out.csv']));        
        end
        function obj = Make_Pdf_Wrapper(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            %%
            PWD = pwd;
            cd(obj.InstallDir)
            obj.handles.DOS_Shell = DOS_Command_Logger;
            obj.handles.DOS_Shell.ProgramName = 'DOS Shell:';
            obj.handles.DOS_Shell.LogOutputs = true;
%             obj.handles.DOS_Shell.Mode = 'system';
            
            obj.DosShell = obj.handles.DOS_Shell;
        end
        function string = StringBuilder(obj)
            %%
            string = 'make_pdf.exe';
            if obj.ExtractTGAfromPDF == true
                string = [string,' -x'];
            end
            if obj.WriteCSVfile == true
                string = [string,' -c'];
            end
            string = [obj.InstallDir, string,' ',obj.DataDir,obj.FileName];
        end
    end
end