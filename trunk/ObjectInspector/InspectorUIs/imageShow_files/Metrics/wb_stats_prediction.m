classdef wb_stats_prediction <   handle & ...
                                FeederObject
    properties (SetObservable = true)
        imageSize = [12,16];
        Method = 'bilinear';
    end
    properties (Hidden = true)
        imageIN
    end
    properties (Hidden = true)
        handles
        Method_LUT = {  'nearest'; ...
                        'bilinear'; ...
                        'bicubic'};
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            im = ReadImage;
            obj = wb_stats_prediction('InputObject',im);
            im.RUN();
            ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            imageIN = obj.imageIN;
            
            %%
            Size = [12,16];
            imageScaled = imresize(     imageIN, obj.imageSize, ...
                                        'method', obj.Method);                            
            imageShow(  'imageOUT',      imageScaled, ...
                        'ImageName',    'stats prediction', ...
                        'Intial_Zoom_Factor', 30);
            obj.handles.figure = gcf;
            
            %%
            obj = NeutralPDF_Detection;
            obj.imageScaled = imageScaled;
            obj.RUN();
       end
    end
    methods (Hidden = true)
        function obj = wb_stats_prediction(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end  
            
            obj.ClassType = 'image';
            obj.LinkObjects;   
            obj.imageIN = obj.InputObject.imageOUT;
            
            % plot code here
  
        end
    end
end

