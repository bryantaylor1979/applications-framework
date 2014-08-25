classdef wb_stats_calc_from_tiff < handle                                     
    properties
        ResizeDim = [12,16];
        BlackLevel = 0;
        mode = 'median';
        Path = 'C:\Users\bryant\Desktop\BlueCast\ov blue cast\simulated_neutral_pdf\'
        filename = 'ov12830_Studio_D50_Indoors_800lx_4950K_v0_561_LABEL_sat8_pdf_N_from_pipeline_wg.tiff';
        imageOUT
    end
    properties
        mode_LUT = {    'mean'; ...
                        'median'};
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = wb_stats_calc_from_tiff;
            obj.RUN();
        end
        function RUN(obj)
            image = obj.ReadTiff();
            obj.imageOUT = obj.ResizeMean(image,obj.ResizeDim,obj.BlackLevel,obj.mode);
            imageShow('imageOUT',obj.imageOUT,'Intial_Zoom_Factor',30);            
        end
    end
    methods (Hidden = true)
        function image = ReadTiff(obj)
            image = imread(fullfile(obj.Path,obj.filename));
        end
        function image_ = ResizeMean(obj,image,ResizeDim,BlackLevel,mode)
            B = image(1:2:end,1:2:end,1);
            GR = image(2:2:end,1:2:end,1);
            GB = image(1:2:end,2:2:end,1);
            R = image(2:2:end,2:2:end,1);
            

            % 16 x 12
            
            [x,y] = size(R);
            block_x = floor(x/ResizeDim(1));
            block_y = floor(y/ResizeDim(2));

            for i = 1:ResizeDim(1)
                endof_x = i*block_x;
                start_x = (i-1)*block_x+1;
            %     disp([num2str(start),',',num2str(endof)])
                for j = 1:ResizeDim(2)
                    endof_y = j*block_y;
                    start_y = (j-1)*block_y+1;
            %         disp([num2str(start),',',num2str(endof)])  
                    if strcmpi(mode,'mean')
                        mean.R(i,j) = round(mean2(R(start_x:endof_x,start_y:endof_y)))-BlackLevel;
                        mean.GR(i,j) = round(mean2(GR(start_x:endof_x,start_y:endof_y)))-BlackLevel;
                        mean.GB(i,j) = round(mean2(GB(start_x:endof_x,start_y:endof_y)))-BlackLevel;
                        mean.B(i,j) = round(mean2(B(start_x:endof_x,start_y:endof_y)))-BlackLevel;
                    else                       
                        %%
                        mean.R(i,j) = round(median(median(double(R(start_x:endof_x,start_y:endof_y)))))-BlackLevel;
                        mean.GR(i,j) = round(median(median(double(GR(start_x:endof_x,start_y:endof_y)))))-BlackLevel;
                        mean.GB(i,j) = round(median(median(double(GB(start_x:endof_x,start_y:endof_y)))))-BlackLevel;
                        mean.B(i,j) = round(median(median(double(B(start_x:endof_x,start_y:endof_y)))))-BlackLevel;                        
                    end
                end
            end
            mean.G = round((mean.GR + mean.GB)./2); 
            div = 2^13;
            image_(:,:,1) = mean.R./div;
            image_(:,:,2) = mean.G./div;
            image_(:,:,3) = mean.B./div;
        end
    end
end
