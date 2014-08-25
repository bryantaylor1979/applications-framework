classdef rawReader < handle
    properties (SetObservable = true)
        filename = 'Q:\bryant\isp_tools\cambs_matlab\ObjectInspector\InspectorUIs\imageShow_files\DataFeeds\lab_capture_4.raw';
        Mode
        Stretch2_16Bit = false;
        ReadRaw_OBJ
        ParseHeader_OBJ
        imageOUT;
    end
    properties (SetObservable = true, Hidden = true)
        Mode_LUT = [];
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           
           %% not working
           obj = rawReader('filename','IMG_20130923_121257.raw');   
           obj.imageOUT = []; 
            
           % Get raw image. 
           obj.filename = 'IMG_20130923_121257.raw';
           obj.RUN();
           imageOUT = obj.imageOUT;
           ObjectInspector(obj)   
           
           
           %%
           obj = rawReader
           obj.RUN()
           ObjectInspector(obj)
           
           %% unix example
           close all
           clear classes
           filename = '/projects/IQ_tuning_data/sensors/Sony/imx175/2013-05-14_S4_Indoor_with_Baffin_Bayer/01_Baffin_MC4_bayer.raw';
           obj = rawReader('filename',  filename);
           obj.RUN()
           ObjectInspector(obj)
        end
        function RUN(obj)
           [path,filename,ext] = fileparts(obj.filename);
           if strcmpi(computer,'GLNXA64');
              separator = '/'; 
           else
              separator = '\'; 
           end
           obj.ParseHeader_OBJ.Path = [path,separator];
           obj.ParseHeader_OBJ.FileName = [filename,ext];
           obj.ParseHeader_OBJ.RUN_READ();
           
           obj.ReadRaw_OBJ.Stride = obj.ParseHeader_OBJ.stride;
           obj.ReadRaw_OBJ.SizeX = obj.ParseHeader_OBJ.width;
           obj.ReadRaw_OBJ.SizeY = obj.ParseHeader_OBJ.height;
           obj.ReadRaw_OBJ.Stretch2_16Bit = obj.Stretch2_16Bit;
           obj.ReadRaw_OBJ.Mode = obj.Mode;
            
           obj.ReadRaw_OBJ.FileName = obj.filename;
           obj.ReadRaw_OBJ.RUN();
           
           obj.imageOUT.image = obj.ReadRaw_OBJ.imageOUT;
           obj.imageOUT.fsd = 1023;
           obj.imageOUT.class = 'double';
           obj.imageOUT.type = 'bayer';
        end
    end
    methods (Hidden = true)
        function obj = rawReader(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end    
            
            %%
            obj.ReadRaw_OBJ = ReadRaw('FileName',obj.filename);
            [path,filename,ext] = fileparts(obj.filename);
            if strcmpi(computer,'GLNXA64');
              separator = '/'; 
            else
              separator = '\'; 
            end
            obj.ParseHeader_OBJ = ParseHeader('Path',[path,separator],'FileName',[filename,ext]);
            obj.ReadRaw_OBJ.Stride = obj.ParseHeader_OBJ.stride;
            obj.ReadRaw_OBJ.SizeX = obj.ParseHeader_OBJ.width;
            obj.ReadRaw_OBJ.SizeY = obj.ParseHeader_OBJ.height;
            obj.Mode_LUT = obj.ReadRaw_OBJ.Mode_LUT;
            obj.Mode = obj.ReadRaw_OBJ.Mode;
        end
    end
end