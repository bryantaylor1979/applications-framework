classdef plotAWBDebug < handle
    properties (SetObservable = true)
        mode = 'Scatter3D';
        fileName = 'N:\tuning\ov5693_HTC\output\temp\yellow_flash.t_grid_probs_pass_1_curve_0.csv';
        Decode_GridProbs_OBJ
    end
    properties (Hidden = true, SetObservable = true)
        mode_LUT = {    'Scatter3D'; ...
                        'ContourPlot_Posteriors'; ...
                        'ContourPlot_Priors'; ...
                        'Surface3D'};
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           obj = plotAWBDebug
           ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            
            name = obj.ExtractImageName(obj.fileName);

            % data is r_nrm,b_nrm, prior_prob, posterior_prob
            % prior_prob is probility surface from our model  "a priori" 
            % posterior prob is result of convolution with all patches and all colurs
            % in the search space.

            % normalise the probabilities in each surface.
            % column titles are: 
            % r_nrm, b_nrm, p_t_prior, likelihood, t_curve, ccm_index
            %
            obj.Decode_GridProbs_OBJ.fileName = obj.fileName;
            obj.Decode_GridProbs_OBJ.RUN();
            r_nrm = obj.Decode_GridProbs_OBJ.DATASET_OUT.r_nrm;
            b_nrm = obj.Decode_GridProbs_OBJ.DATASET_OUT.b_nrm;
            priors = obj.Decode_GridProbs_OBJ.DATASET_OUT.priors;
            posteriors = obj.Decode_GridProbs_OBJ.DATASET_OUT.posteriors;

%             ct = [ 3.1397 -2.9879 0.8219 ];
%             x = 0.016:0.01: 0.42;
%             y = polyval(ct,x);
%             plot(x,y,'o');
            
            switch obj.mode
                case 'Scatter3D'
                    obj.Scatter3D(r_nrm, b_nrm, priors, posteriors, name);
                case 'ContourPlot_Posteriors'
                    obj.ContourPlot(r_nrm, b_nrm, posteriors,'posteriors',name);
                case 'ContourPlot_Priors'
                    obj.ContourPlot(r_nrm, b_nrm, priors,'priors',name);
                case 'Surface3D'
                    obj.Surface3D(r_nrm, b_nrm, priors, posteriors);
                otherwise
            end
        end
    end
    methods (Hidden = true) %plots
        function obj = plotAWBDebug()  
            obj.Decode_GridProbs_OBJ = Decode_GridProbs();
        end
        function Surface3D(obj,r_nrm, b_nrm, priors, posteriors)
            figure;
            [X,Y,CDATA_double] = obj.PrepareNonUniform3d(r_nrm, b_nrm, priors, 200 );
            h = surf(        CDATA_double, ...
                            'FaceColor',[0,0,1], ...
                            'EdgeColor','none');
            camlight left; lighting phong;
            [X,Y,CDATA_double] = obj.PrepareNonUniform3d(r_nrm, b_nrm, posteriors, 200 );
            hold on
            h = surf(        CDATA_double, ...
                            'FaceColor',[1,0,0], ...
                            'EdgeColor','none');
            camlight left; lighting phong;
        end
        function Scatter3D(obj,r_nrm, b_nrm, priors, posteriors, name)
            figure, plot3(r_nrm, b_nrm, priors, 'b*', r_nrm, b_nrm, posteriors,'r*'), grid
            xlabel('r nrm');
            ylabel('b nrm');
            title(['prior and posterior probilibility surfaces ', name]);
            legend('priors', 'posteriors');  
        end
        function ContourPlot(obj,r_nrm,b_nrm,prob,type,name)
            [X,Y,Z] = obj.PrepareNonUniform3d( r_nrm, b_nrm, prob, 1000 );
            % 
            figure, contour( X, Y, Z ), grid;
            %figure, imagesc( Z );
            title([type,' ' name]);          
        end
    end
    methods (Hidden = true)
        function name = ExtractImageName(obj,filename)
            name = regexp( filename, '\\(\w+)\.', 'tokens'); % use string between '\' and '.'
            name = strrep( name{1}, '_', ' ');            
        end
        function [X,Y,Z] = PrepareNonUniform3d(obj, x, y, z, NumPoints )
            % PrepareNonUniform3d( x, y, z )
            % 
            % PrepareNonUniform3d functions accepts x and y coordinate vectors and the
            % respective vector of z data and generates regular X, Y, coordinate meshes
            % togeteher with the grid of Z data
            % NumPoints - specify the resolution if the final grid

            if( isempty( NumPoints ) ),
               NumPoints = 512;
            end

            xlin = linspace( min(x), max(x), NumPoints );
            ylin = linspace( min(y), max(y), NumPoints );
            [X,Y] = meshgrid( xlin, ylin );
            Z = griddata( x, y, z, X, Y, 'cubic' );
        end
    end
end

