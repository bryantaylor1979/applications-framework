classdef PlotAllGrids < handle
    properties (SetObservable = true)
        PassNumber = 2;
        Ideal_Flash_RBnorm = [0.303419, 0.269231];
        Decode_Grid_OBJ
        Decode_GridProbs_OBJ
        DATASET_LAMPS = dataset([])
    end
    methods
        function Example(obj)
            %%
            close all
            clear classs
            obj = PlotAllGrids
            ObjectInspector(obj)
            %%
            title('Current System - flash proportion: 0, weight: 0')
        end
        function RUN(obj)
            %%
            obj.Decode_Grid_OBJ.GridNo = 0;
            obj.Decode_Grid_OBJ.RUN();
            r_norm = obj.Decode_Grid_OBJ.DATASET_OUT.r_norm;
            b_norm = obj.Decode_Grid_OBJ.DATASET_OUT.b_norm;
            figure,  h = plot(r_norm, b_norm,'rx');
            set(h,'Color',[0.5,0,0])
            
            %%
            obj.Decode_Grid_OBJ.GridNo = 1;
            obj.Decode_Grid_OBJ.RUN();
            r_norm = obj.Decode_Grid_OBJ.DATASET_OUT.r_norm;
            b_norm = obj.Decode_Grid_OBJ.DATASET_OUT.b_norm;
            hold on,  h = plot(r_norm, b_norm,'bx');
            set(h,'Color',[0,0,0.5])
            
            %%
            MarkerSize = 5;
            obj.Decode_GridProbs_OBJ.PassNumber = obj.PassNumber;
            obj.Decode_GridProbs_OBJ.CurveNo = 0;
            obj.Decode_GridProbs_OBJ.RUN();
            r_norm = obj.Decode_GridProbs_OBJ.DATASET_OUT.r_nrm;
            b_norm = obj.Decode_GridProbs_OBJ.DATASET_OUT.b_nrm;
            hold on,  h = plot(r_norm, b_norm, 'r.');
            set(h,  'Color',        [1,0.5,0.5], ...
                    'MarkerSize',   MarkerSize)
            
            %%
            obj.Decode_GridProbs_OBJ.PassNumber = obj.PassNumber;
            obj.Decode_GridProbs_OBJ.CurveNo = 1;
            obj.Decode_GridProbs_OBJ.RUN();
            r_norm = obj.Decode_GridProbs_OBJ.DATASET_OUT.r_nrm;
            b_norm = obj.Decode_GridProbs_OBJ.DATASET_OUT.b_nrm;
            hold on,  h = plot(r_norm, b_norm, 'b.');
            set(h,  'Color',[0.5,0.5,1], ...
                    'MarkerSize',   MarkerSize)
            
            %% ideal flash lamp
            hold on,  h1 = plot(    obj.Ideal_Flash_RBnorm(1), ...
                                    obj.Ideal_Flash_RBnorm(2), 'ks');
            set(h1,'MarkerSize',11.3,'LineWidth',2.3)
            
            %%
            hold on; h1 = plot(     obj.DATASET_LAMPS.r_nrm,    ...
                                    obj.DATASET_LAMPS.b_nrm,    'ks');
            set(h1, 'MarkerSize',   5, ...
                    'LineWidth',    1);              
            
            %%
            xlabel('r_nrm')
            ylabel('b_nrm')
            legend( 'outdoor grid', ...
                    'indoor grid', ...
                    'outdoor flash active', ...
                    'indoor flash active', ...
                    'ideal_flash_norm', ...
                    'manual presets')
                

        end
    end
    methods (Hidden = true)
        function obj = PlotAllGrids()
            obj.Decode_Grid_OBJ = Decode_Grid();
            obj.Decode_GridProbs_OBJ = Decode_GridProbs();
            %%
            conical = [1.01, 1.11];
%             conical = [1, 1];
            Values = {  'Flash_Lamp_Val',       0.303419,        0.269231; ...
                        'Repored Pic - Yellow', 0.282432*conical(1),   0.267739*conical(2)};
            
            Names = Values(:,1);
            r_nrm = cellfun(@double,Values(:,2));
            b_nrm = cellfun(@double,Values(:,3));
            %%
            obj.DATASET_LAMPS = dataset(    {Names,'Names'}, ...
                                            {r_nrm,'r_nrm'}, ...
                                            {b_nrm,'b_nrm'});
        end
    end
end