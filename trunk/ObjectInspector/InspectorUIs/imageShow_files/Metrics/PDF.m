classdef PDF < handle & ...
               FeederObject
    properties (SetObservable = true)
        Visible
        Type
        imageIN

                   %                         'pdf_sky_N.tga', ...
        State = 'ready';
        impoint_ENABLE = true;
        impoint_RGB = [100,200,100];
    end
    properties (Hidden = true)
        handles
        gamuts = [];
    end
    methods (Hidden = false)
        function Example(obj)
            %%
            close all
            clear classes
            IM = imageShow();     %Select and image
            obj = PDF('InputObject',IM);
            ObjectInspector(obj)
            
            %%
            close all
            clear classes
            obj = imageShow();     %Select and image
            
            %%
            csv2m_OBJ = csv2array('filename','pdf_grass'); 
            csv2m_OBJ.RUN(); 
            
            cg_OBJ = array2cgamut('array',csv2m_OBJ.array);
            cg_OBJ.RUN
            
            
            %
            struct(1).gamut = cg_OBJ.gamut;
            pdf_OBJ = PDF('impoint_ENABLE',false,'InputObject',obj,'gamuts',struct);
            
            %%
            rle_OBJ = array2rle
            rle_OBJ.imageIN.image(:,:,1) = csv2m_OBJ.array;
            rle_OBJ.imageIN.image(:,:,2) = csv2m_OBJ.array;
            rle_OBJ.imageIN.image(:,:,3) = csv2m_OBJ.array;
            rle_OBJ.imageIN.fsd = 255;
            rle_OBJ.imageIN.type = 'rgb';
            ObjectInspector(rle_OBJ)
            
            %%
            ObjectInspector(pdf_OBJ)
            
            %%
            
            
            %%
            CT = [2000:100:10000];
            x = size(CT,2);
            for i = 1:x
                [R, G, B] = roo2disp(blackbody(CT(i)));
                R/(R + G + B)
            end
            
            
%             rgb = roo2rgb(, 'srgb')
            
            %%
            load('blackbody')
            r_norm = data.r_norm*255
            b_norm = (1-data.b_norm)*255
            %%
            plot(pdf_OBJ.handles.axes,r_norm,b_norm)
        end
        function RUN(obj)
            try
            RedMean = mean2(obj.imageIN.image(:,:,1));
            GreenMean = mean2(obj.imageIN.image(:,:,2));
            BlueMean = mean2(obj.imageIN.image(:,:,3));
            catch
            RedMean = mean2(obj.imageIN(:,:,1));
            GreenMean = mean2(obj.imageIN(:,:,2));
            BlueMean = mean2(obj.imageIN(:,:,3));                    
            end
            RedNorm = RedMean/(RedMean + GreenMean + BlueMean)*255;
            BlueNorm = 255 - (BlueMean/(RedMean + GreenMean + BlueMean)*255);
            setPosition(obj.handles.impoint,[RedNorm,BlueNorm])
        end
    end
    methods (Hidden = true)
        function obj = PDF(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end  
            
            obj.ClassType = 'box';
            obj.LinkObjects;   
            obj.imageIN = obj.InputObject.imageOUT_cropped;
            
            obj.InitGUI();
            obj.addlistener(    'Visible',  'PostSet', @obj.updateVisible);
        end
        function InitGUI(obj)
            %% display TGA as an image
            % pdf_sky_20090625.tga has a problem. 

            obj.State = 'running';
            drawnow;
            if isempty(obj.gamuts)
                struct = load('tgas.mat');
                obj.gamuts = struct.struct;
            end
            
            %%
            obj.DisplayOnColourSpace(obj.gamuts);
%             title(tgafilelist{Select}) 
            obj.State = 'complete';
            drawnow;
            
            %%
            if obj.impoint_ENABLE == true
                try
                RedMean = mean2(obj.imageIN.image(:,:,1));
                GreenMean = mean2(obj.imageIN.image(:,:,2));
                BlueMean = mean2(obj.imageIN.image(:,:,3));
                catch
                RedMean = mean2(obj.imageIN(:,:,1));
                GreenMean = mean2(obj.imageIN(:,:,2));
                BlueMean = mean2(obj.imageIN(:,:,3));                    
                end
            
                [r_nrm,b_nrm] = obj.rgb2rbNorm(RedMean,GreenMean,BlueMean);
                [x,y] = obj.rbNorm2Axis(r_nrm,b_nrm);
                h = impoint(gca,x,y);
                setColor(h,'w'); 
                obj.handles.impoint = h;
            end     
            obj.handles.datatip = datacursormode(obj.handles.figure);
            set(obj.handles.datatip,'UpdateFcn',@obj.UpdateFcn);
        end
        function TGA2RLE(obj,filename)
            %%
            obj = Make_Pdf_Wrapper( 'ExtractTGAfromPDF',false, ...
                                    'WriteCSVfile', false, ...
                                    'FileName',filename);
        end
        function RLE2TGA(obj,filename)
            %% RLE to TGA
            obj = Make_Pdf_Wrapper( 'ExtractTGAfromPDF',true, ...
                                    'WriteCSVfile', false, ...
                                    'FileName',filename);     
        end
        function [x,y] = rbNorm2Axis(obj,r_nrm,b_nrm)
            %%
            x = r_nrm*255;
            y = 255 - b_nrm*255;
        end
        function [r_nrm,b_nrm] = Axis2rbNorm(obj,x,y)
            %%
            r_nrm = x/255;
            b_nrm = (255 - y)/255;
        end
        function [r_nrm,b_nrm]= rgb2rbNorm(obj,R,G,B)
            r_nrm = R/(R + G + B);
            b_nrm = B/(R + G + B);
        end
    end
    methods (Hidden = true) %GUI
        function DisplayGamuntOnImage(obj,image,gamut1,gamut2,gamut1_Name,gamut2_Name)
            if obj.Visible == true
                obj.handles.figure = figure('Visible','on');
            else
                obj.handles.figure = figure('Visible','off');
            end
            imshow(image);
            
            obj.plotGamut(gamut1,'b:',2);
            obj.plotGamut(gamut2,'r:',2);
            set(gca,'Position',[0.05,0.05,0.58,0.9]);
            h = legend(gamut1_Name,gamut2_Name);
            set(h,  'Position', [0.6396, 0.7811, 0.3465, 0.1556], ...
                    'Location','NorthEastOutside');
        end
        function DisplayOnColourSpace(obj,struct)
            %%
            ImageSize = 256;
%             rbObj = RB_Norm_ColourSpaceGen( 'method',                   'direct', ...
%                                             'ImageSize',                ImageSize, ...
%                                             'ValueSacrifice_Enable',    true, ...
%                                             'LumTarget',                256, ...
%                                             'RemoveClipped',            true);
           
            IMAGE = imread('rb_norm.jpeg');
            if obj.Visible == true
                obj.handles.figure = figure(    'Visible',      'on', ...
                                                'Name',         'Colour Space: red/blue norm', ...
                                                'NumberTitle',  'off');
            else
                obj.handles.figure = figure(    'Visible',      'off', ...
                                                'Name',         'Colour Space: red/blue norm', ...
                                                'NumberTitle',  'off');
            end
                                       
            imshow(uint8(IMAGE));
            obj.handles.axes = gca; 
            Factor = ImageSize/64;
            xlabel('red norm')
            ylabel('blue norm')
            
            x = size(struct,2);
            for i = 1:x
               obj.plotGamut(struct(i).gamut.*Factor,'k:',1.5); 
            end
        end
        function output_txt = UpdateFcn(varargin)
            obj = varargin{1};
            event_obj = varargin{3};
            pos = get(event_obj,'Position')
            [r_nrm,b_nrm] = obj.Axis2rbNorm(pos(1),pos(2))
            output_txt = {  sprintf('red_nrm:  %1.2f',r_nrm), ...
                            sprintf('blue_nrm: %1.2f',b_nrm)};
        end
        function updateVisible(varargin)
            obj = varargin{1};
            if obj.Visible == true
                set(obj.handles.figure,'Visible','on');
            else
                set(obj.handles.figure,'Visible','off');
            end
        end
    end
    methods (Hidden = true)
        function image = RLE2image(obj,filename)
            makeObj = Make_Pdf_Wrapper( 'ExtractTGAfromPDF',true, ...
                                    'WriteCSVfile', true, ...
                                    'FileName',filename);
            image = makeObj.pdf_image;
        end
        function plotGamut(obj,gamut,marker,LineWidth) % common function
            %%
            hold on;
            if not(isempty(gamut))
                obj.handles.gamut = plot(gamut(:,2),gamut(:,1),marker,'LineWidth',LineWidth);  
            end
        end
    end
end