classdef Decode_GridProbs < handle
    properties (SetObservable = true)
        PassNumber = 2
        CurveNo = 0;
        Path = 'N:\tuning\ov5693_HTC\output\temp\';
        name = 'yellow_flash';
        fileName = 'yellow_flash.t_grid_probs_pass_2_curve_0.csv';
        DATASET_OUT = dataset([]);
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = Decode_GridProbs();
            ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            if isempty(obj.fileName)
                obj.fileName = fullfile(obj.Path,[obj.name,'.t_grid_probs_pass_',num2str(obj.PassNumber),'_curve_',num2str(obj.CurveNo),'.csv']);
            end
            [num,txt] = obj.ReadCsv(obj.fileName);
            [r_nrm,b_nrm,priors,posteriors] =  obj.DecodeCsv(txt,num);
            obj.DATASET_OUT = dataset(  {r_nrm,         'r_nrm'}, ...
                                        {b_nrm,         'b_nrm'}, ...
                                        {priors,        'priors'}, ...
                                        {posteriors,    'posteriors'})
        end
    end
    methods (Hidden = true) 
        function obj = Decode_GridProbs()  
        end
    end 
    methods (Hidden = true) % t_grid_probs_pass_1_curve_0.csv
        function [r_nrm,b_nrm,priors,posteriors] =  DecodeCsv(obj,txt,num)
            %%
            num_nrml = num;
            r_nrm_index = obj.simResColIndex('r_nrm',txt);
            b_nrm_index = obj.simResColIndex('b_nrm',txt);
            priors_index = obj.simResColIndex('p_t_prior',txt);
            likelihood_index = obj.simResColIndex('likelihood',txt);

            r_nrm = num_nrml(:,r_nrm_index);
            b_nrm = num_nrml(:,b_nrm_index);
            priors     = num(:,priors_index)/max(num(:,priors_index));% return the scale used to allow comparisons of different analyses.
            scale = max(num(:,likelihood_index));
            if (scale == 0)
                scale = 1;
            end
            posteriors = num(:,likelihood_index)/scale;

%             cog_r = sum( r_nrm.*posteriors ) / sum( posteriors );
%             cog_b = sum( b_nrm.*posteriors ) / sum( posteriors );
        end
        function [num,txt] = ReadCsv(obj,fileName)
            [num,txt,raw] = xlsread(fileName);
        end
        function colIndex = simResColIndex ( obj, fieldName, txt)
            colIndex=-1;
            for i=1:size(txt,2)
                % sim_Vc4 inserts a space before the column title string
                if strcmp(fieldName,txt(1,i))
                    colIndex = i;
                    break;
                end
                % sim_Vc4 inserts a space before the column title string
                if strcmp([' ',fieldName],txt(1,i))
                    colIndex = i;
                    break;
                end
            end

            if (colIndex < 0)
                for i=1:size(txt,2)
                    name = txt(1,i);
                    name
                end
                error('Cannot find column named %s in CSV column header',fieldName)
            end
        end
    end
end