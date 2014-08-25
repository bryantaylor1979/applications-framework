classdef csv2dataset < handle
    properties (SetObservable = true)
        filename = 'results.csv';
        DATASET = dataset([]);
    end
    properties (Hidden = true)
        format_in_all = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s';
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           obj = csv2dataset();
           ObjectInspector(obj)
           
           %% unix
           close all
           clear classes
           filename = '/projects/IQ_tuning_data/bgentles/run/cbghoney_2014_Jun_04_07_09_30_42e8358/results_matlab.csv';
           obj = csv2dataset(   'filename',     filename);
           ObjectInspector(obj);
        end
        function RUN(obj)
            %%
            format = obj.format_in_all;
            fid = fopen(obj.filename,'r');
            DATA = textscan(fid,format,'Delimiter',',','HeaderLines',0);
            
            %%
            x = size(DATA,2);
            for i = 1:x
                names = DATA{i};
                ColumnName = names{1};
                if isempty(ColumnName)
                    break
                end
                ColumnNames{i,1} = names{1};
            end
            SIZE = size(ColumnNames,1);
            
            %%
            fclose(fid);

            %%
            DATASET = [];
            for i = 1:SIZE
               Values = DATA{i}; 
               VarName = Values{1};
               VALUES = str2double(Values(2:end));
               n = find(isnan(VALUES));
               %%
               if size(n,1) == size(VALUES,1)
                   VALUES = Values(2:end);
               end
               %%
               if i == 1
                   DATASET = dataset({VALUES,VarName});
               else
                   DATASET = [DATASET,dataset({VALUES,VarName})];
               end
            end
            obj.DATASET = DATASET;    
        end
    end
    methods (Hidden = true)
        function obj = csv2dataset(varargin)  
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
        end
    end
end
