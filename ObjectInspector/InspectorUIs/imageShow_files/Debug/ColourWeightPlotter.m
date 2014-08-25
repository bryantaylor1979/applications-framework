classdef ColourWeightPlotter < handle
    properties (SetObservable = true)
        Name    = 'awb';
        Path    = 'C:\sourcecode\matlab\Programs\ObjectInspector\InspectorUIs\imageShow_files\Debug\files\';
        curve   = 0;
        filename_str = 'op_pdf_colours_curve';
    end
    properties (Hidden = true)
        filename_str_LUT = {    'op_colour_hist_curve'; ...
                                'op_pdf_colours_curve'; ...
                                'op_weighted_colours_curve'};
    end
    methods 
        function Example(obj)
            %%
            close all
            clear classes
            obj = ColourWeightPlotter;
            ObjectInspector(obj)

            %% hidden function for image show
            Exists = obj.CheckFileExists;
        end
        function RUN(obj)
            %%
            filename = [obj.Name,'.',obj.filename_str,'_',num2str(obj.curve),'.raw'];
            obj.plot(fullfile(obj.Path,filename))      
        end
    end
    methods (Hidden = true)
        function Exists = CheckFileExists(obj)
            filename = [obj.Name,'.',obj.filename_str,'_',num2str(obj.curve),'.raw'];
            fullfilename = fullfile(obj.Path,filename);
            [path,filename,ext] = fileparts(fullfilename);
            PWD = pwd;
            try
            cd(path);
            catch
            cd(PWD);    
            end
            names = struct2cell(dir);
            NAMES = names(1,:);
            n = find(strcmpi(NAMES,[filename,ext]));
            if isempty(n)
                Exists = false;
            else
                Exists = true;
            end
            cd(PWD)
        end
        function obj = ColourWeightPlotter()
            
        end
        function [x,y,im] = read_col_hist(obj,filename)
            %filename = 'Y:\bgentles\isp\imx105\op_colour_hist_curve_0.raw';
            FID= fopen(filename,'rb');
            im = fread(FID,[256,256],'int16');
            im(256,:) = 0;
            fclose(FID);

            %im=flipud(im);

            im = imrotate(im,90);

            % normalise scale to max = 255
            mx = max(im);
            if ( mx > 0)
                im = im .* (255/mx);
            end

            x = 0:1/256:255/256;
            y = x;
        end
        function plot(obj,filename)
            %%
            figure( 'NumberTitle',  'off', ...
                    'Name',         [obj.filename_str])
            
            [x,y,wc] = obj.read_col_hist(filename);
            contour(x,y,wc);
            grid on;
            
            title(['curve ',num2str(obj.curve)]); 
            xlabel('red norm');
            ylabel('blue norm');
        end
    end
end