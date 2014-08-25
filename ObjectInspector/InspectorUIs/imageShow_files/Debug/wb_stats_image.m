classdef wb_stats_image < handle
    properties (SetObservable = true)
        scalefactor = 100;
        filename
        bitDepth = 16;
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            Path = 'C:\sourcecode\matlab\Programs\ObjectInspector\InspectorUIs\imageShow_files\Debug\files\';
            filename = 'awb.awb_stats_mean.csv'
            obj = wb_stats_image;
            obj.filename = fullfile(Path,filename);
            
            ObjectInspector(obj)
            
            %% Hidden function for image show
            Exists = obj.CheckFileExists;
        end
        function RUN(obj)
            raw = xlsread(obj.filename);

            %%
            IMAGE = imageCLASS;
            image(:,:,1) = raw(:,1:4:end);
            image(:,:,2) = raw(:,2:4:end);
            image(:,:,3) = raw(:,3:4:end);
            IMAGE.image = image;
            IMAGE.image = IMAGE.image./2^13;

            imageShow( 'imageOUT',              IMAGE, ...
                       'Intial_Zoom_Factor',    30 );           
        end
    end
    methods (Hidden  = true)
        function obj = wb_stats_image()
        end
        function Exists = CheckFileExists(obj)
            %%
            [path,filename,ext] = fileparts(obj.filename);
            PWD = pwd;
            try
            cd(path);
            catch
            cd(PWD);    
            end
            names = struct2cell(dir);
            NAMES = names(1,:);
            n = find(strcmpi(NAMES,[filename,ext]));
            if isempty(n)
                Exists = false;
            else
                Exists = true;
            end
            cd(PWD)
        end
    end
end


