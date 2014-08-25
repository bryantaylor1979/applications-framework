classdef p_t_prior < handle
    properties (SetObservable = true)
        path = 'C:\Users\bryant\Desktop\ridge_prior\';
        filename = 'awb_debug';
        mode = 'grid';
        GridNo = 0;
        Curve0_Name = 'Outdoor';
        Curve1_Name = 'Indoor';
        Decode_Grid_OBJ
    end
    properties (Hidden = true, SetObservable = true)
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
            obj = p_t_prior();
            ObjectInspector(obj);
        end
        function RUN(obj)  
            % decode
            obj.Decode_Grid_OBJ.path = obj.path;
            switch obj.mode
                case 'grids'
                    obj.Decode_Grid_OBJ.filename = obj.filename;
                    obj.Decode_Grid_OBJ.GridNo = 0;
                    obj.Decode_Grid_OBJ.RUN();
                    curve0.r_norm = obj.Decode_Grid_OBJ.DATASET_OUT.r_norm;
                    curve0.b_norm = obj.Decode_Grid_OBJ.DATASET_OUT.b_norm;
                    curve0.p_t_prior = obj.Decode_Grid_OBJ.DATASET_OUT.p_t_prior;
                    
                    
                    obj.Decode_Grid_OBJ.filename = obj.filename;
                    obj.Decode_Grid_OBJ.GridNo = 1;
                    obj.Decode_Grid_OBJ.RUN(); 
                    curve1.r_norm = obj.Decode_Grid_OBJ.DATASET_OUT.r_norm;
                    curve1.b_norm = obj.Decode_Grid_OBJ.DATASET_OUT.b_norm;
                    curve1.p_t_prior = obj.Decode_Grid_OBJ.DATASET_OUT.p_t_prior;
                    
                    obj.plot_Grids(curve0,curve1);
                case 'grid'
                    raw = obj.ReadCsv(obj.GridNo);
                    [r_norm, b_norm, p_t_prior] = obj.Decode(raw);
                    obj.plot_Grid(      r_norm, b_norm);
                case 'surface'
                    raw = obj.ReadCsv(obj.GridNo);
                    [r_norm, b_norm, p_t_prior] = obj.Decode(raw);
                    obj.plot_Surface(   r_norm, b_norm, p_t_prior);
                case 'scatter'
                    raw = obj.ReadCsv(obj.GridNo);
                    [r_norm, b_norm, p_t_prior] = obj.Decode(raw);
                    obj.plot_Scatter(   r_norm, b_norm, p_t_prior);
                case 'scatters'
                    raw0 = obj.ReadCsv(0);
                    raw1 = obj.ReadCsv(1);
                    [curve0.r_norm, curve0.b_norm, curve0.p_t_prior] = obj.Decode(raw0);
                    [curve1.r_norm, curve1.b_norm, curve1.p_t_prior] = obj.Decode(raw1);
                    obj.plot_Scatters(curve0,curve1);                   
                otherwise
                    error('mode not recognised')
            end
        end
    end
    methods (Hidden = true) 
        function obj = p_t_prior()
            obj.Decode_Grid_OBJ = Decode_Grid();
            obj.Decode_Grid_OBJ.path = obj.path;
        end
        function plot_Grids(obj,curve0,curve1)
            h.figure = figure(  'Name','p_t_prior - Grid', ...
                                'NumberTitle','off')  
            scatter(curve0.r_norm, curve0.b_norm, 'rx'); hold on;
            scatter(curve1.r_norm, curve1.b_norm, 'bx');
            
            [curve0.x_lims, curve0.y_lims] = obj.FindXY_Lims(curve0.r_norm,curve0.b_norm,0.01);
            [curve1.x_lims, curve1.y_lims] = obj.FindXY_Lims(curve1.r_norm,curve1.b_norm,0.01);
            
            xlims(1) = min([curve0.x_lims(1),curve1.x_lims(1)]);
            xlims(2) = max([curve0.x_lims(2),curve1.x_lims(2)]);
            
            ylims(1) = min([curve0.y_lims(1),curve1.y_lims(1)]);
            ylims(2) = max([curve0.y_lims(2),curve1.y_lims(2)]);
            
            xlim(xlims);
            ylim(ylims);
            xlabel('r_-norm');
            ylabel('b_-norm');
            
            legend('curve0','curve1')
        end
        function plot_Grid(obj,r_norm,b_norm)
            h.figure = figure(  'Name','p_t_prior - Grid', ...
                                'NumberTitle','off')
            scatter(r_norm,b_norm,'x');
            [x_lims,y_lims] = obj.FindXY_Lims(r_norm,b_norm,0.01);
            xlim(x_lims);
            ylim(y_lims);
            xlabel('r_-norm');
            ylabel('b_-norm');
        end
        function [x_lims,y_lims] = FindXY_Lims(obj,r_norm,b_norm,margin)
            r_norm_range = [min(r_norm), max(r_norm)];
            b_norm_range = [min(b_norm), max(b_norm)];
            r_norm_mag = r_norm_range(2) - r_norm_range(1);
            b_norm_mag = b_norm_range(2) - b_norm_range(1);
            
            max_mag = max([r_norm_mag,b_norm_mag]);
            
            x_lims = [mean(r_norm_range)-max_mag/2-margin, mean(r_norm_range)+max_mag/2+margin];
            y_lims = [mean(b_norm_range)-max_mag/2-margin, mean(b_norm_range)+max_mag/2+margin];            
        end
        function plot_Surface(obj,r_norm,b_norm,p_t_prior)
            h.figure = figure(  'Name','p_t_prior - Surface', ...
                                'NumberTitle','off')
            %% nearest neibour
            Step = 0.005;
            clear p_t_prior_val
            r_norm_index = [0.16:Step:0.36]
            b_norm_index = [0.18:Step:0.38]
            x = size(r_norm_index,2);
            y = size(b_norm_index,2);
            for i = 1:x
                for j = 1:y
                    p_t_prior_val(i,j) = obj.nn( r_norm, b_norm, r_norm_index(i), b_norm_index(j), p_t_prior);
                end
            end
            surf(r_norm_index,b_norm_index,p_t_prior_val', ...
                            'FaceColor',[1,0,0], ...
                            'EdgeColor','none');
            camlight left; lighting phong;             
        end
        function plot_Scatter(obj,r_norm,b_norm,p_t_prior)
            %%
            h.figure = figure(  'Name','p_t_prior - Surface', ...
                                'NumberTitle','off')
            scatter3(r_norm,b_norm,p_t_prior,'filled');            
        end
        function plot_Scatters(obj,curve0,curve1)
            h.figure = figure(  'Name','p_t_prior - Scatters', ...
                                'NumberTitle','off')
            scatter3(curve0.r_norm,curve0.b_norm,curve0.p_t_prior,'r','filled');  hold on;   
            scatter3(curve1.r_norm,curve1.b_norm,curve1.p_t_prior,'b','filled');  hold on; 
            legend('Curve0','Curve1')
        end
        function p_t_prior_val = nn(obj, r_norm, b_norm, r_norm_val, b_norm_val, p_t_prior)
            %%
            magFrom_rnorm = abs(r_norm - r_norm_val);
            magFrom_bnorm = abs(b_norm - b_norm_val);
            mag = (magFrom_rnorm.^2 + magFrom_bnorm.^2).^0.5;
            n = find(mag == min(mag));
            if min(mag) > 0.005
                p_t_prior_val = NaN;
                return
            end
            p_t_prior_val = p_t_prior(n);
        end
    end
end