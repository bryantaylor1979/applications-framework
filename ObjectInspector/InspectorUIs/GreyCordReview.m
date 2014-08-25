classdef GreyCordReview < handle
    properties (SetObservable = true)
        root_dir = 'Z:\projects\IQ_tuning_data\bgentles\run\';
        Status = 'ready';
        Rev = '2014_Mar_26_17_05_07_e222bfa';
        ImageIO_OBJ
    end
    properties (Hidden = true, SetObservable = true)
        Rev_LUT
    end
    methods (Hidden = false)
        function Example(obj)
            %%
            close all
            clear classes
            obj = GreyCordReview();
            ObjectInspector(obj);
        end
        function RUN(obj)
            %%
            obj.Status = 'running';
            drawnow;
            PWD = pwd;
            obj.ImageIO_OBJ.RUN();
            cd(PWD);

            x = size(obj.ImageIO_OBJ.names,1);
            for i = 1:x
               files{i,1} = fullfile(obj.root_dir,obj.Rev,obj.ImageIO_OBJ.names{i});
               xmlfiles{i,1} = fullfile(obj.root_dir,obj.Rev,strrep(obj.ImageIO_OBJ.names{i},'.bmp','.xml'));
            end      
            %%
            imageShow(    'ImageName',    files, ...
                          'XmlName',      xmlfiles);
            obj.Status = 'complete';
            drawnow;
        end
    end
    methods (Hidden = true)
        function obj = GreyCordReview()
            %%
            obj.ImageIO_OBJ = ...
                    ImageIO(        'Path',         [obj.root_dir,obj.Rev], ...
                                    'ImageType',    '.bmp');         
            obj.Rev_LUT = obj.GetDirList(obj.root_dir);
        end
        function NAMES = GetDirList(obj,root_dir)
           %%
           D = dir(root_dir);
           NAMES = struct2cell(D);
           NAMES = rot90(NAMES(1,3:end));
        end
    end
end

%%


