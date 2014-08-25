classdef csv2array <  handle
    properties (SetObservable = true)
        filename = 'pdf_grass';
        imageOUT
    end
    properties (SetObservable = true, Hidden = true)
        filename_LUT = {    'pdf_grass'; ...
                            'pdf_sky_N'}
    end
    methods
        function Example(obj)
            %%
        end
        function RUN(obj)
            %%
            imageOUT = imageCLASS();
            array = obj.file2image(obj.filename);
            imageOUT.image(:,:,1) = array;
            imageOUT.image(:,:,2) = array;
            imageOUT.image(:,:,3) = array;
            obj.imageOUT = imageOUT;
        end
    end
    methods (Hidden = true)
        function obj = csv2array(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
        end
        function image = file2image(obj,filename)
            image = uint8(xlsread([filename,'.csv']));
        end
    end
end