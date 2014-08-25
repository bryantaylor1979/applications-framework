classdef Decode_Grid < handle
    properties (SetObservable = true)
        path = 'N:\tuning\ov5693_HTC\output\temp\';
        filename = 'yellow_flash';
        GridNo = 0;
        DATASET_OUT = dataset([]);
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = Decode_Grid();
            ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            [raw] = obj.ReadCsv(obj.GridNo);
            [r_norm, b_norm, p_t_prior] = obj.Decode(raw);
            obj.DATASET_OUT = dataset(  {r_norm,'r_norm'}, ...
                                        {b_norm,'b_norm'}, ...  
                                        {p_t_prior,'p_t_prior'} );
        end
    end
    methods (Hidden = true)
        function obj = Decode_Grid()
            
        end
        function [raw] = ReadCsv(obj,GridNo)
            %%
            raw = xlsread(fullfile(obj.path,[obj.filename,'.t_grid_',num2str(GridNo),'.csv']));
        end
        function [r_norm, b_norm, p_t_prior] = Decode(obj,raw)
            r_norm = raw(:,1);
            b_norm = raw(:,2);    
            p_t_prior = raw(:,3);
        end
    end
end