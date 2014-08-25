classdef csv2rle < handle
    properties (SetObservable = true)
        filename = 'pdf_grass';
        Log = true
        imageOUT
    end
    properties (SetObservable = true, Hidden = true)
        filename_LUT = {    'pdf_grass'; ...
                            'pdf_sky_N'};
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = csv2rle();
            obj.RUN();
            ObjectInspector(obj);            
        end
        function RUN(obj)
            csvOBJ = csv2array();      
            csvOBJ.filename = obj.filename;
            csvOBJ.RUN();
            rle_OBJ = array2rle('imageIN',csvOBJ.imageOUT);
            rle_OBJ.RUN();
            if obj.Log == true
                rle_OBJ.Log;   
            end
            obj.imageOUT = csvOBJ.imageOUT;
        end
    end
    methods (Hidden =  true)
        function obj = csv2rle(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
        end
    end
end
    
