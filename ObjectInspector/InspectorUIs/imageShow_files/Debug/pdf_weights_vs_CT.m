classdef pdf_weights_vs_CT < handle
    properties (SetObservable = true)
        path = 'C:\Users\bryant\Desktop\Temp\';
        filename = '2013-03-26_Samsung_1830_01_Baffin_DL_bayer_LABEL_Test';
        mode = 'grid';
        GridNo = 0;
    end
    properties (Hidden = true)
        mode_LUT = {    'grid'; ...
                        'grids'; ...
                        'surface'; ...
                        'scatter'};
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = pdf_weights_vs_CT();
            ObjectInspector(obj);
        end
        function RUN(obj)
            %%
        	raw = obj.ReadCsv(obj.GridNo);
        	[r_norm, pdf0, pdf1, pdf2, pdf3] = obj.Decode(raw);
            
            figure( 'NumberTitle',  'off', ...
                    'Name',         ['PDF Weights vs Red Norm - Grid',num2str(obj.GridNo)]);
                
            handles.pdf0 = plot(r_norm,pdf0,'r'); hold on;
            handles.pdf1 = plot(r_norm,pdf1,'g'); hold on;
            handles.pdf2 = plot(r_norm,pdf2,'b'); hold on;
            handles.pdf3 = plot(r_norm,pdf3,'y'); hold on;
            set(handles.pdf0,'LineWidth',8);
            set(handles.pdf1,'LineWidth',6);
            set(handles.pdf2,'LineWidth',4);
            set(handles.pdf3,'LineWidth',2);
            legend('pdf0','pdf1','pdf2','pdf3');
            xlabel('r_norm');
            ylabel('weight');
        end
    end
    methods (Hidden = true) 
        function obj = pdf_weights_vs_CT()
        end
        function [raw] = ReadCsv(obj,GridNo)
            %%
            raw = xlsread(fullfile(obj.path,[obj.filename,'.t_grid_',num2str(GridNo),'.csv']));
        end
        function [r_norm, pdf0, pdf1, pdf2, pdf3] = Decode(obj,raw)
            r_norm = raw(:,1);
            p_t_prior = raw(:,3);
            pdf0 = raw(:,4);    
            pdf1 = raw(:,5);
            pdf2 = raw(:,5);
            pdf3 = raw(:,5);
            n = find(p_t_prior == 1);
            
            r_norm = r_norm(n);
            pdf0 = pdf0(n);
            pdf1 = pdf1(n);
            pdf2 = pdf2(n);
            pdf3 = pdf3(n);
        end
    end
end