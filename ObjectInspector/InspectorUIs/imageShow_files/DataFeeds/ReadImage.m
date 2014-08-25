classdef ReadImage < handle
    properties (SetObservable = true)
        FileName = 'V:\imx175\sessions\imx175\BRCM_colourpipe\rev1\imx175_Baffin-Photoshoot1_2.jpg'
        imageOUT
    end
    properties (Hidden = true)  
        Header
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            file = 'C:\tuning\imx175\output\AL_HW_GED\001-Baffin-BRCM_20120203_040821.jpg';
            obj = ReadImage('FileName',file);
            obj.RUN;
            ObjectInspector(obj);
            
            %% unix example
            files = '//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Cloudy_IMG_20140513_170349.jpg';
            obj = ReadImage('FileName',files);
            ObjectInspector(obj)
            
            %%
            imageShow(  'image',    obj.imageOut)
        end
        function RUN(obj)
            disp(['FileName: ',obj.FileName]);
            obj.imageOUT = []; %Save memory
            imageOUT = imageCLASS;
            [Img, obj.Header] = imread(obj.FileName);
            imageOUT.image = Img;
            obj.imageOUT = imageOUT;
            obj.imageOUT.class = class(Img);
        end
    end
    methods (Hidden = true)
        function obj = ReadImage(varargin)
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end     
        end
    end
end