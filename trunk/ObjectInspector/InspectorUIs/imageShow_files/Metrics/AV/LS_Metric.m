classdef LS_Metric < handle & ...
                     FeederObject
    properties (SetObservable = true)
        Visible
        Type = 'image';
        VARS
        imageIN
        rect_size_fraction = 8;
        Plot_enable = false
    end
    properties (SetObservable = true)
        STATUS
        ls_rect_x
        ls_rect_y
        rgb_image
        
        COLOUR_SHADING
        Standard_Pass = 8;
        Tier1_Pass = 5;
        ErrorTable = dataset([])
        Overall_Pass
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes

            %%
            file = 'C:\tuning\imx175\output\AL_HW_GED\001-Baffin-BRCM_20120203_040821.jpg';
            imageOUT = imageCLASS();
            imageOUT.image = imread(file);
            imageOUT.fsd = 255;
            imageOUT.type = 'rgb';
            imshow = imageShow(    'imageOUT',     imageOUT, ...
                                'ImageName',    file);

            
            %% 
            obj = LS_Metric('InputObject',imshow);   
            obj.RUN();
            ObjectInspector(obj);     
        end
        function RUN(obj)
            if isempty(obj.imageIN)
               error('please assigned image before running') 
            end
            rgb_image = obj.imageIN.image;
            obj.CalcRectSize(rgb_image);
            [ch_R,ch_G,ch_B] = obj.ChannelSplit(rgb_image);
            
            ycbcr_image = rgb2ycbcr(rgb_image);
            [ch_Y,ch_Cb,ch_Cr] = obj.ChannelSplit(ycbcr_image);
            
            if obj.Plot_enable == true
            obj.plotContours(ch_Y);
            end
            
            rois = obj.GetROIs(ch_Y);
            rois = obj.CalcMeans(rois);
            rois = obj.CalcRatios(rois);
            if obj.Plot_enable == true
            obj.plotY_results(rois);
            end
            
            %%
            rois_R = obj.GetROIs(ch_R);
            rois_R = obj.CalcMeans(rois_R);
            
            rois_G = obj.GetROIs(ch_G);
            rois_G = obj.CalcMeans(rois_G);
            
            rois_B = obj.GetROIs(ch_B);
            rois_B = obj.CalcMeans(rois_B);
            
            %% R/G
            rois_RG = obj.CalcRatio(rois_R,rois_G);
            rois_RG = obj.CalcMeans(rois_RG);
            rois_RG = obj.CalcError(rois_RG);
            rois_RG = obj.CalcPassFail(rois_RG);
            
            
            if obj.Plot_enable == true
                obj.plot_errors(rois_RG,'R/G');
            end

            
            %% B/G
            rois_BG = obj.CalcRatio(rois_B,rois_G);
            rois_BG = obj.CalcMeans(rois_BG);
            rois_BG = obj.CalcError(rois_BG);
            rois_BG = obj.CalcPassFail(rois_BG);
            
            
            if obj.Plot_enable == true
                obj.plot_errors(rois_BG,'B/G') 
            end
            
            %%
            Colour =    dataset(   {   {    'RG';'';'';''; ...
                                            'BG';'';'';''},         'Colour'});
            Location =  dataset(   {   {    'UL';'UR';'LL';'LR'; ...
                                            'UL';'UR';'LL';'LR'},	'Location'});
                
            RG_Errors = dataset(  {    [    rois_RG.UL.error; ...
                                            rois_RG.UR.error; ...
                                            rois_RG.LL.error; ...
                                            rois_RG.LR.error; ...
                                            rois_BG.UL.error; ...
                                            rois_BG.UR.error; ...
                                            rois_BG.LL.error; ...
                                            rois_BG.LR.error],      'Error'});
            PASS = {                        rois_RG.UL.pass; ...
                                            rois_RG.UR.pass; ...
                                            rois_RG.LL.pass; ...
                                            rois_RG.LR.pass; ...
                                            rois_BG.UL.pass; ...
                                            rois_BG.UR.pass; ...
                                            rois_BG.LL.pass; ...
                                            rois_BG.LR.pass};
            BG_Pass   = dataset(  {    PASS,      'Pass'});
            
            n = find(strcmpi(PASS,'fail'));
            p = find(strcmpi(PASS,'standard'));
            if not(isempty(n))
                obj.Overall_Pass = 'fail';
            elseif not(isempty(p))
                obj.Overall_Pass = 'standard';
            else
                obj.Overall_Pass = 'tier1';
            end
                                        
            obj.ErrorTable = [Colour,Location,RG_Errors,BG_Pass];            
        end
    end
    methods (Hidden = true)
        function obj = LS_Metric(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.ClassType = obj.Type; %image, box of line from calling program. 
            obj.LinkObjects; 
            obj.imageIN = obj.InputObject.imageOUT;
        end  
        function CalcRectSize(obj,rbg_image)
            [image_size_y,image_size_x, z] = size(rbg_image);
            obj.ls_rect_x = fix(image_size_x / obj.rect_size_fraction);
            obj.ls_rect_y = fix(image_size_y / obj.rect_size_fraction);            
        end
        function [Ch1,Ch2,Ch3] = ChannelSplit(obj,image)
            [image_size_y, image_size_x, z] = size(image);
            Ch1      = uint8(zeros(image_size_y, image_size_x));
            Ch2      = uint8(zeros(image_size_y, image_size_x));
            Ch3      = uint8(zeros(image_size_y, image_size_x));
            
            Ch1 = image(:,:,1);
            Ch2 = image(:,:,2);
            Ch3 = image(:,:,3);            
        end
        function rois = CalcMeans(obj,rois)
            rois.C.mean  = mean(mean(rois.C.image));
            rois.UL.mean  = mean(mean(rois.UL.image));
            rois.UR.mean  = mean(mean(rois.UR.image));
            rois.LL.mean  = mean(mean(rois.LL.image));
            rois.LR.mean  = mean(mean(rois.LR.image));
        end
        function rois = CalcRatios(obj,rois)
            rois.UL.ratio = (rois.UL.mean / rois.C.mean) * 100;
            rois.UR.ratio = (rois.UR.mean / rois.C.mean) * 100;
            rois.LL.ratio = (rois.LL.mean / rois.C.mean) * 100;
            rois.LR.ratio = (rois.LR.mean / rois.C.mean) * 100;
        end
        function rois = GetROIs(obj,image)
            [image_size_y,image_size_x, z] = size(image);
            rois.C.image  = image(fix(image_size_y/2)-fix(obj.ls_rect_y/2):fix(image_size_y/2)+fix(obj.ls_rect_y/2), fix(image_size_x/2)-fix(obj.ls_rect_x/2):fix(image_size_x/2)+fix(obj.ls_rect_x/2));
            rois.UL.image = image(1:obj.ls_rect_y, 1:obj.ls_rect_x);
            rois.UR.image = image(1:obj.ls_rect_y, (image_size_x)-(obj.ls_rect_x):image_size_x);
            rois.LL.image = image((image_size_y)-(obj.ls_rect_y):image_size_y, 1:obj.ls_rect_x);
            rois.LR.image = image((image_size_y)-(obj.ls_rect_y):image_size_y, (image_size_x)-(obj.ls_rect_x):image_size_x);
        end
        function rois = CalcRatio(obj,rois1,rois2)
            %%
            rois.C.image = double(rois1.C.image)  ./ double(rois2.C.image);
            rois.UL.image = double(rois1.UL.image) ./ double(rois2.UL.image);
            rois.UR.image = double(rois1.UR.image) ./ double(rois2.UR.image);
            rois.LL.image = double(rois1.LL.image) ./ double(rois2.LL.image);
            rois.LR.image = double(rois1.LR.image) ./ double(rois2.LR.image); 
        end
        function rois = CalcError(obj,rois)
            %%
            rois.UL.error = (rois.C.mean - rois.UL.mean) / rois.C.mean * 100;
            rois.UR.error  = (rois.C.mean - rois.UR.mean) / rois.C.mean * 100;
            rois.LL.error  = (rois.C.mean - rois.LL.mean) / rois.C.mean * 100;
            rois.LR.error  = (rois.C.mean - rois.LR.mean) / rois.C.mean * 100;
        end
        function rois = CalcPassFail(obj,rois)
            if abs(rois.UL.error) <= obj.Tier1_Pass
                rois.UL.pass = 'tier1';
            elseif abs(rois.UL.error) <= obj.Standard_Pass
                rois.UL.pass = 'standard';
            else
                rois.UL.pass = 'fail';
            end
            if abs(rois.UR.error) <= obj.Tier1_Pass
                rois.UR.pass = 'tier1';
            elseif abs(rois.UL.error) <= obj.Standard_Pass
                rois.UR.pass = 'standard';
            else
                rois.UR.pass = 'fail';
            end
            if abs(rois.LL.error) <= obj.Tier1_Pass
                rois.LL.pass = 'tier1';
            elseif abs(rois.LL.error) <= obj.Standard_Pass
                rois.LL.pass = 'standard';
            else
                rois.LL.pass = 'fail';
            end            
            if abs(rois.LR.error) <= obj.Tier1_Pass
                rois.LR.pass = 'tier1';
            elseif abs(rois.LR.error) <= obj.Standard_Pass
                rois.LR.pass = 'standard';
            else
                rois.LR.pass = 'fail';
            end
        end
    end
    methods (Hidden = true)
        function plotY_results(obj,rois)
            %%
            figure(2); title('Y average values from each corner rectangle');
            subplot(3,3,5); imagesc(rois.C.image);  title(['Center Y = ',       num2str(round(rois.C.mean*10)/10)]);
            subplot(3,3,1); imagesc(rois.UL.image); title(['Upper Left Y = ',   num2str(round(rois.UL.mean*10)/10), ' (', num2str(round(rois.UL.ratio*10)/10), '%)']);
            subplot(3,3,3); imagesc(rois.UR.image); title(['Upper Right Y = ',  num2str(round(rois.UR.mean*10)/10), ' (', num2str(round(rois.UR.ratio*10)/10), '%)']);
            subplot(3,3,7); imagesc(rois.LL.image); title(['Lower Left Y =',    num2str(round(rois.LL.mean*10)/10), ' (', num2str(round(rois.LL.ratio*10)/10), '%)']);
            subplot(3,3,9); imagesc(rois.LR.image); title(['Lower Right Y =',   num2str(round(rois.LR.mean*10)/10), ' (', num2str(round(rois.LR.ratio*10)/10), '%)']);
        end
        function plot_errors(obj,rois_RG,string)
            figure; title([string,' average values from each corner rectangle']);
            subplot(3,3,5); imagesc(rois_RG.C.image);  title(['Center ',string,' = ',      num2str(round(rois_RG.C.mean*1000)/1000)]);
            subplot(3,3,1); imagesc(rois_RG.UL.image); title(['Upper Left ',string,' = ',  num2str(round(rois_RG.UL.mean*1000)/1000), ' (', num2str(round(rois_RG.UL.error*10)/10), '%)']);
            subplot(3,3,3); imagesc(rois_RG.UR.image); title(['Upper Right ',string,' = ', num2str(round(rois_RG.UR.mean*1000)/1000), ' (', num2str(round(rois_RG.UR.error*10)/10), '%)']);
            subplot(3,3,7); imagesc(rois_RG.LL.image); title(['Lower Left ',string,' =',   num2str(round(rois_RG.LL.mean*1000)/1000), ' (', num2str(round(rois_RG.LL.error*10)/10), '%)']);
            subplot(3,3,9); imagesc(rois_RG.LR.image); title(['Lower Right ',string,' =',  num2str(round(rois_RG.LR.mean*1000)/1000), ' (', num2str(round(rois_RG.LR.error*10)/10), '%)']);
        end
        function plotContours(obj,ch_Y)
            figure( 'NumberTitle','off', ...
                    'Name','Y contours'); 
            title('Input image');
            imagesc(ch_Y); title('Y contours'); 
        end
    end
end
