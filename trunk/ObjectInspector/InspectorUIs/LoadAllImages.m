classdef LoadAllImages < handle
    properties (SetObservable = true)
        Revison  = [];
        UserName = 'cbghoney';
    end
    properties (SetObservable = true, SetAccess = protected)
        RootDir = '/projects/IQ_tuning_data/';
    end
    properties (SetObservable = true, Hidden = true)
        Names
        ImageIO_OBJ
        IM_OBJ
        RootPath = '/projects/IQ_tuning_data/bgentles/run/';
        RunGUI = true;
        Revison_LUT
        UserName_LUT =  {       'cbghoney'; ...
                                'bgentles'; ...
                                'bryant'; ...
                                'ahuggett'};
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = LoadAllImages();
            
            %%
            close all
            clear classes
            Revison = 'bgentles_2014_May_19_14_10_24_ideal_gains';
            obj = LoadAllImages(    'Revison',  Revison);
        end
        function RUN(obj)
            %%
            obj.RootPath = fullfile(obj.RootDir,obj.UserName,'run');
            
            %%
            filenames = obj.GetOrderedFilenames();
            obj.Revison_LUT = filenames;
            
            if isempty(obj.Revison)
                obj.Revison = filenames{1};
            end
            
            %%
            obj.ImageIO_OBJ = ImageIO(  'Path',         fullfile(obj.RootPath,obj.Revison,'jpg'), ...
                                        'ImageType',    '.jpg');
            obj.ImageIO_OBJ.RUN();     
            obj.Names = obj.ImageIO_OBJ.names();
            
            %%
            x = size(obj.Names,1);
            for i = 1:x
                Names{i,1} = fullfile(obj.RootPath,obj.Revison,'jpg',obj.Names{i});
                [~,~,ext] = fileparts(fullfile(obj.RootPath,obj.Revison,'xml',obj.Names{i}));
                XMLNames{i,1} = strrep(fullfile(obj.RootPath,obj.Revison,'xml',obj.Names{i}),ext,'.xml');
            end
            
            %%
            obj.IM_OBJ = imageShow(     'ImageName',                Names, ...
                                        'XmlName',                  XMLNames, ...
                                        'ImageNamePullDown_Width',  450, ...
                                        'Customer',                'Samsung', ...
                                        'CustomerMetric_Enable',    true); 
        end
    end
    methods (Hidden = true)
        function obj = LoadAllImages(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.RootPath = fullfile(obj.RootDir,obj.UserName,'run');
            filenames = obj.GetOrderedFilenames();
            obj.Revison_LUT = filenames;
            
            if isempty(obj.Revison)
                obj.Revison = filenames{1};
            end
            
            %%
            obj.ImageIO_OBJ = ImageIO(  'Path',         fullfile(obj.RootPath,obj.Revison,'jpg'), ...
                                        'ImageType',    '.jpg');
            obj.ImageIO_OBJ.RUN();     
            obj.Names = obj.ImageIO_OBJ.names();
            if obj.RunGUI == true
            	ObjectInspector(obj,    'ParamValueWidth',  450, ...
                                        'ParamNameWidth',   190, ...
                                        'logging',false);
            end 
            obj.addlistener(  'UserName',       'PostSet',  @obj.UpdateFolderList);
        end
        function filenames = GetOrderedFilenames(obj)
            PWD = pwd;
            cd(obj.RootPath);
            filenames = struct2cell(dir);
            filenames = squeeze(filenames(1,3:end,:))';
            ALL = struct2cell(dir);
            ALL = squeeze(ALL(:,3:end,:))';
            filenames = ALL(:,1);
            count = 1;
            x = size(filenames,1);
            for i = 1:x
                name = filenames{i};
                n = findstr(name,'_');
                try
                    try
                        %%
                        datestr = name(1:n(6)-1);
                        Num(count,1) = datenum(datestr,'yyyy_mmm_dd_HH_MM_SS');
                        filenames_NEW{count,1} = filenames{i};
                        count = count + 1;
                    catch
                        %%
                        datestr = name(n(1)+1:n(7)-1);
                        Num(count,1) = datenum(datestr,'yyyy_mmm_dd_HH_MM_SS');
                        filenames_NEW{count,1} = filenames{i};
                        count = count + 1;
                    end
                catch
                    warning(['Output folder is not the correct format: ',name])
                end
            end
            DATASET = dataset({filenames_NEW,'filenames'},{Num,'datenum'});
            DATASET = sortrows(DATASET,'datenum','descend');
            filenames = DATASET.filenames;
            cd(PWD);            
        end
        function UpdateFolderList(varargin)
            obj = varargin{1};
            obj.RootPath = fullfile(obj.RootDir,obj.UserName,'run');
            filenames = obj.GetOrderedFilenames();
            obj.Revison_LUT = filenames;
        end
    end
end
    