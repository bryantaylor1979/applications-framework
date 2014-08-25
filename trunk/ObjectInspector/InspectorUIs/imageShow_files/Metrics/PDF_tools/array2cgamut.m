classdef array2cgamut < handle
    properties (Hidden = false, SetObservable = true)
        array
        Status = '';
        gamut
    end
    properties (Hidden = true)
        makeObj
    end
    methods
        function Example(obj)
            %%
            filelist = { 'pdf_both_grass_20090625', ...
                     'pdf_burnt_grass', ...
                     'pdf_neutral_N', ...
                     'pdf_skin', ...
                     'pdf_sky_N_mod2'};
                 
            %%
            close all
            clear classes
            %%
            obj = csv2array('filename','pdf_burnt_grass'); 
            obj.RUN(); 
            
            cg_OBJ = array2cgamut('array',obj.array);
            ObjectInspector(cg_OBJ)
        end
        function RUN(obj)
            %%
            obj.Status = 'Running';
            obj.gamut = obj.GetColourGamut(obj.array); 
            obj.Status = 'Complete';
        end
    end
    methods (Hidden = true)
        function obj = array2cgamut(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
        end
        function gamut = GetColourGamut(obj,image)
            %%
            ClipImage = obj.ChannelClipDetector(image);
            gamut = obj.FindColourGamut(ClipImage)
        end
        function ClipImage = ChannelClipDetector(obj,channel) % common function 
            %%
            [x,y] = size(channel);
            pixelimage = reshape(channel,1,x*y);
            n = find(pixelimage >= 0.999999);
            
            ClipImage(1,1:x*y) = 0;
            ClipImage(n) = 1;
            
            ClipImage = reshape(ClipImage,y,x);            
        end
        function boundary = FindColourGamut(obj,ClipImage) % common function
            %%
            dim = size(ClipImage)
            for row = 1:dim(1)
                for col = 1:dim(2)
                    value = ClipImage(row,col);
                    if value > 0.5
                        break;
                    end
                end
                if value >0.5
                   break 
                end
            end
             
            %%
            if isempty(row)
                boundary = [];
            else
                boundary = bwtraceboundary(ClipImage,[row, col],'N'); 
            end
        end
    end
end