classdef RB_Norm_ColourSpaceGen < handle
    properties  (SetObservable = true)
        method = 'direct'               %direct or all_possible
        ImageSize = 64;                 % applicable in both modes
        LumTarget = 256;                % 8 bit world. (direct mode only)
        Transparency = 0.4;
        ValueSacrifice_Enable = true    %(direct mode only)
        RemoveClipped = false;          %(direct mode only)
        BackGroundColour = [0.8,0.8,0.8];
        Status = 'Ready';
        Progress = '0%';
        imageOUT
    end
    methods
        function Example(obj)
            %% OLD: Generate Image by going through all possible RGB value. 
            close all
            clear classes
            
            %%
%             close all
%             clear classes
            csp = RB_Norm_ColourSpaceGen(   'method',                   'direct', ...
                                            'ImageSize',                256, ...
                                            'ValueSacrifice_Enable',    true, ...
                                            'LumTarget',                256, ...
                                            'RemoveClipped',            true);
            obj = ObjectInspector(csp)
%             figure, imshow(obj.rgb_image) 
        end
        function RUN(obj)
            obj.Status = 'Running';
            drawnow;
            if strcmpi(obj.method,'direct')
                [obj.imageOUT.image] = obj.GenFromRBNorm(obj.LumTarget,obj.ImageSize); 
                obj.imageOUT.fsd = 1;
                obj.imageOUT.type = 'rgb';
            elseif strcmpi(obj.method,'all_possible')
                [obj.imageOUT.image] = obj.GenFromRGB(8,obj.ImageSize);
                obj.imageOUT.fsd = 1;
                obj.imageOUT.type = 'rgb';
            else
                error('')
            end
            obj.Status = 'Complete';
        end
    end
    methods (Hidden = true)
        function obj = RB_Norm_ColourSpaceGen(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x  
                obj.(varargin{i}) = varargin{i+1};
            end
            if strcmpi(obj.method,'direct')
                [obj.imageOUT.image] = obj.GenFromRBNorm(obj.LumTarget,obj.ImageSize);
                obj.imageOUT.fsd = 255;
            elseif strcmpi(obj.method,'all_possible')
                [obj.imageOUT.image] = obj.GenFromRGB(8,obj.ImageSize);
                obj.imageOUT.fsd = 255;
            else
                error('')
            end
        end
        function [image] = GenFromRBNorm(obj,LumTarget,imagesize)
            h_flip = false;
            v_flip = false;
            image = obj.GenImage([0,1],[0,1],imagesize); % 0-1 red norm, 0-1 blue norm
            image = uint8(obj.chroma2rgb(image,h_flip,v_flip,LumTarget));
        end
        function [image] = GenFromRGB(obj,BitDepth,imagesize)
            if BitDepth > 8
               error('BitDepth to high. Max is 8') 
            end
            FSD = 256;
            GreyLevels = 2^BitDepth;
            GreyStep = FSD/GreyLevels;
            R = [0:GreyStep:FSD-1];
            G = [0:GreyStep:FSD-1];
            B = [0:GreyStep:FSD-1];
            x = size(R,2);
            y = size(G,2);
            z = size(B,2);
            clear image
            h = waitbar(0);
            log = false
            for i = 1:x
                waitbar(i/x,h)
                for j = 1:y
                    for k = 1:z
                        rednorm = R(i)/(R(i) + G(j) + B(k));
                        bluenorm = B(k)/(R(i) + G(j) + B(k));
                        if log == true
                        disp(['Red: ',num2str(R(i))])
                        disp(['Green: ',num2str(G(j))])
                        disp(['Blue: ',num2str(B(k))])
                        disp(['rednorm: ',num2str(rednorm)])
                        disp(['bluenorm: ',num2str(bluenorm)])
                        end

                        if not(and(and(uint8(R(i)) == 0, uint8(G(j))),uint8(B(k))))
                            if not(or(isnan(rednorm),isnan(bluenorm)))
                                int_rednorm = round(rednorm*imagesize) + 1;
                                int_bluenorm = round(bluenorm*imagesize) + 1;
                                if log == true
                                disp(['int_rednorm: ',num2str(int_rednorm)])
                                disp(['int_bluenorm: ',num2str(int_bluenorm)])
                                end
                                image(int_rednorm, int_bluenorm, 1) = uint8(R(i));
                                image(int_rednorm, int_bluenorm, 2) = uint8(G(j));
                                image(int_rednorm, int_bluenorm, 3) = uint8(B(k));
                            end
                        end
                    end
                end
            end
            close(h)
        end
    end
    methods (Hidden = true)
        function image = GenImage(obj,H_Range,V_Range,imagesize)
            %%
            
            %%
            H_StepSize = abs((H_Range(2) - H_Range(1))/(imagesize-1));
            
            if H_Range(2)> H_Range(1)
                Column = [H_Range(1):H_StepSize:H_Range(2)];
            else
                Column = [H_Range(2):-H_StepSize:H_Range(1)];
            end
            image(:,:,1) = repmat(Column,[imagesize,1]);
            
            %%
            V_StepSize = abs((V_Range(2) - V_Range(1))/(imagesize-1));
            if V_Range(2)> V_Range(1)
                Row = rot90([V_Range(1):V_StepSize:V_Range(2)]);
            else
                Row = rot90([V_Range(2):-V_StepSize:V_Range(1)]);
            end
            image(:,:,2) = repmat(Row,[1,imagesize]);
        end
        function image = chroma2rgb(obj,image,h_flip,v_flip,LumTarget)
            %%
            [x,y,z] = size(image);
            imR = ones(x,y,1);
            imG = ones(x,y,1);
            imB = ones(x,y,1);
            
            for i = 1:x
                obj.Progress = [num2str(round(i/x*100)),'%'];
                drawnow;
                for j = 1:y
                    U = image(i,j,1);
                    V = image(i,j,2);
                    [R,G,B] = obj.rbnorm2rgb(U,V,LumTarget);
                    imR(i,j) = R;
                    imG(i,j) = G;
                    imB(i,j) = B;
                end
            end
            if v_flip == true
                imR = flipud(imR);
                imG = flipud(imG);
                imB = flipud(imB);
            end
            if h_flip == true
                imR = fliplr(imR);
                imG = fliplr(imG);
                imB = fliplr(imB);                       
            end
            image(:,:,1) = imR;
            image(:,:,2) = imG;
            image(:,:,3) = imB;
        end
        function [R,G,B] = rbnorm2rgb(obj,rednorm,bluenorm,LumTarget)
            %%
            BackGroundColour = obj.BackGroundColour.*255;
            IntialGreenValueAssumption = 128; 
            
            
            % Eq 1
            %redgain + bluegain + 1 = 1/greennorm
            %redgain = 1/greennorm - bluegain - 1
            
            % Eq 2
            %bluenorm = bluegain/(redgain + greengain + bluegain)
            %bluenorm*redgain + bluenorm + bluenorm*bluegain = bluegain
            %bluenorm*redgain = bluegain - bluenorm - bluenorm*bluegain
            %redgain = (bluegain - bluenorm - bluenorm*bluegain)/bluenorm
            
            % combined Eq 1 & 2
            %1/greennorm - bluegain - 1 = bluegain/bluenorm - 1 - bluegain
            
            greengain = 1;
            greennorm = 1 - rednorm - bluenorm;
            greennorm = round(greennorm*256)/256;
            if greennorm <= 0
                R = BackGroundColour(1);
                G = BackGroundColour(2);
                B = BackGroundColour(3);
                return
            end
            bluegain = bluenorm/greennorm;
            if bluegain > 10000000000
                redgain = 0;
                bluegain = 10000000000;
            else
                redgain =(rednorm*bluegain + rednorm)/(1 - rednorm);
            end
            
            IntialRedValueAssumption = 128*redgain;
            IntialGreenValueAssumption = 128*greengain;
            IntialBlueValueAssumption = 128*bluegain;
            
            Av = mean([IntialRedValueAssumption,IntialGreenValueAssumption,IntialBlueValueAssumption]);
            Correction = LumTarget/Av;
            
            lum_Corrected_RGB_values(1) = round(IntialRedValueAssumption*Correction);
            lum_Corrected_RGB_values(2) = round(IntialGreenValueAssumption*Correction);
            lum_Corrected_RGB_values(3) = round(IntialBlueValueAssumption*Correction);   
            
            %Sacrifice Luminance to retain colour
            if obj.ValueSacrifice_Enable == true
                MaxVal = max(lum_Corrected_RGB_values);
                if MaxVal > 255
                    sacrificedval_RGB_values = round((lum_Corrected_RGB_values./MaxVal).*255);
                else
                    sacrificedval_RGB_values = round(lum_Corrected_RGB_values);
                end
            else
                sacrificedval_RGB_values = lum_Corrected_RGB_values;
            end
            % remove clipped
            if obj.RemoveClipped == true
                n = find(sacrificedval_RGB_values > 255);
                if not(isempty(n))
                    R = BackGroundColour(1);
                    G = BackGroundColour(2);
                    B = BackGroundColour(3);
                    return
                end
            end
            
            
            if false
               disp(['greenNorm: ',num2str(greennorm)])
               disp(['IntialRedValueAssumption: ',num2str(IntialRedValueAssumption)])
               disp(['IntialGreenValueAssumption: ',num2str(IntialGreenValueAssumption)])
               disp(['IntialBlueValueAssumption: ',num2str(IntialBlueValueAssumption)])    
               disp(['Lum Corrected RGB: [',num2str(lum_Corrected_RGB_values(1)),',',num2str(lum_Corrected_RGB_values(2)),',',num2str(lum_Corrected_RGB_values(3)),']'])
               disp(['Sacrified Val Corrected RGB: [',num2str(sacrificedval_RGB_values(1)),',',num2str(sacrificedval_RGB_values(2)),',',num2str(sacrificedval_RGB_values(3)),']'])
               disp(' ')
            end
            
            R = sacrificedval_RGB_values(1)*obj.Transparency;
            G = sacrificedval_RGB_values(2)*obj.Transparency;
            B = sacrificedval_RGB_values(3)*obj.Transparency;  
        end
    end
end


