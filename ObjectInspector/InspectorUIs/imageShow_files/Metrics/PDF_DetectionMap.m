classdef PDF_DetectionMap < handle & ...
                            FeederObject
    properties 
        imageIN
        PDF_Name = 'pdf_neutral_N_out.csv'
        Path = 'C:\sourcecode\matlab\Programs\WhiteBalance\PDF\PDF_Wrapper\pdfs\';
    end
    methods
        function Example(obj)
            %%
            obj = PDF_DetectionMap;
            
            %%
            obj.imageScaled = imageScaled;
            obj.RUN();
            
            %% Check the wgt based on the colour. 
            [neurtal_PDF,PDF_Size] = obj.LoadPDF(obj.PDF_Name);
            [R_Norm_Index,B_Norm_Index] = obj.rbnorm2index(0.33,0.33,PDF_Size);
            wgth = neurtal_PDF(R_Norm_Index,B_Norm_Index)
        end
        function RUN(obj)
            %%
            [neurtal_PDF,PDF_Size] = obj.LoadPDF(obj.PDF_Name);
            Detection = obj.ImageDetection(obj.imageIN,neurtal_PDF,PDF_Size);
            obj.DisplayImage(Detection)
        end
    end
    methods (Hidden = true)
        function obj = PDF_DetectionMap(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end  
            obj.ClassType = 'image';
            try
                obj.LinkObjects;   
                obj.imageIN = obj.InputObject.imageOUT;  
            catch
               warning('parent object not linked') 
            end
        end
        function [neurtal_PDF,PDF_Size] = LoadPDF(obj,filename) %% Load CSV file
            %%
            Path = 'C:\sourcecode\matlab\Programs\WhiteBalance\PDF\PDF_Wrapper\pdfs\';
            neurtal_PDF = xlsread([obj.Path,filename]);
            PDF_Size = max(size(neurtal_PDF));
        end
        function [Detection,Energy] = ImageDetection(obj,imageScaled,neurtal_PDF,PDF_Size)
            %% Image Detection
            [x,y,z] = size(imageScaled);
            imageScaled = double(imageScaled);
            RedAcc = 0;
            GreenAcc = 0;
            BlueAcc = 0;
            
            if x > 100
               h = waitbar(0); 
            end
            for i = 1:x
                if x > 100
                   h = waitbar(i/x,h);  
                end
                for j = 1:y
                    R = imageScaled(i,j,1);
                    G = imageScaled(i,j,2);
                    B = imageScaled(i,j,3);

                    R_Norm = R/(R + G + B);
                    B_Norm = B/(R + G + B);

                    [R_Norm_Index,B_Norm_Index] = obj.rbnorm2index(R_Norm,B_Norm,PDF_Size);
                    wgth = neurtal_PDF(R_Norm_Index,B_Norm_Index);
                    if wgth > 0
                        RedAcc = RedAcc + R*wgth;
                        GreenAcc = GreenAcc + G*wgth;
                        BlueAcc = BlueAcc + B*wgth;
                        Detection(i,j) = 0;
                    else
                        Detection(i,j) = 1;
                    end
                end
            end 
            if x > 100
               close(h); 
            end
            Energy = [RedAcc,GreenAcc,BlueAcc];
        end
        function [R_Norm_Index,B_Norm_Index] = rbnorm2index(obj,R_Norm,B_Norm,PDF_Size)
            %%   
            %  0.0 -> 1
            %  1.0 -> 64
            R_Norm_Index = R_Norm*(PDF_Size-1)+1;
            B_Norm_Index = round(B_Norm*(PDF_Size-1)+1);
            % 64 -> 1
            R_Norm_Index = round(PDF_Size - R_Norm_Index + 1);
        end
        function DisplayImage(obj,Detection)
            imageShow(      'imageOUT',      Detection, ...
                            'ImageName',    'stats prediction', ...
                            'Intial_Zoom_Factor', 30);            
        end
        function CalcGains(obj)
            %%         
            MaxValue = max([RedAcc,GreenAcc,BlueAcc]);
            RedGain = MaxValue/RedAcc;
            GreenGain = MaxValue/GreenAcc;
            BlueGain = MaxValue/BlueAcc;
        end
        function ApplyGains2image(obj)
            %%
            ds_image(:,:,1) = imageScaled(:,:,1).*(RedGain/256);
            ds_image(:,:,2) = imageScaled(:,:,2).*(GreenGain/256);
            ds_image(:,:,3) = imageScaled(:,:,3).*(BlueGain/256);
            imageShow(      'imageOUT',      ds_image, ...
                            'ImageName',    'stats prediction', ...
                            'Intial_Zoom_Factor', 30);            
        end
    end
end

