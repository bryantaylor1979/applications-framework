classdef imageHistogram <   handle & ...
                            FeederObject
    properties (Hidden = true, SetObservable = true)
        Visible
        Type = 'image';
        imageIN
        histo_averages
        nBins = 256;
        BitDepth = 16;
        NumberOfFrames = 30;
    end
    properties (Hidden = true)
        Type_LUT = {    'image'; ...
                        'box'};
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            im = ReadImage;
            obj = imageHistogram('InputObject',im);
            im.RUN();
            ObjectInspector(obj)
        end
        function RUN(obj)
            image = obj.imageIN.image;
            % Convert RGB image to YCbCr to find luma values
            imageycbcr = rgb2yuv(image);
            im_luma = imageycbcr(:,:,1);

            % Calculate the histograms
            if strcmpi(obj.imageIN.type,'rgb')
                [rHist,gHist,bHist,lumaHist] = obj.CalculateHistRGB(image,im_luma);
                set(obj.handles.red,     'YData',rHist);
                set(obj.handles.green,   'YData',gHist);
                set(obj.handles.blue,    'YData',bHist);
                set(obj.handles.luma,    'YData',lumaHist);
                LumMax = max([max(rHist), max(gHist), max(bHist), max(lumaHist)]);
                String = obj.CalculateMeansRGB(image);
                MAX = max([max(rHist),max(gHist),max(bHist), max(lumaHist)]);
            else
                [rHist,grHist,gbHist,bHist] = obj.CalculateHistBayer(image);
                set(obj.handles.red, 'YData',rHist);
                set(obj.handles.gr,  'YData',grHist);
                set(obj.handles.gb,  'YData',gbHist);
                set(obj.handles.blue,'YData',bHist);
                LumMax = max([max(rHist), max(grHist), max(gbHist), max(bHist)]);
                String = obj.CalculateMeansBayer(image);
                MAX = max([max(rHist),max(grHist),max(gbHist),max(bHist)]);
            end

            %Set Axis limits
            Values = obj.histo_averages.pixno;
            Values(obj.histo_averages.count) = LumMax;
            obj.histo_averages.pixno = Values;
            MaxPixNosOverFrames = mean(Values);
            set(obj.handles.axis,'ylim',[0 MAX*1.2]);
            set(obj.handles.axis,'xlim',[0 255 + 5]); % + 5  to see clipped pixels
            set(obj.handles.text,    'Position', [255*0.85,MAX,0], ...
                                    'String',   String);
        end
    end
    methods (Hidden = true)
        function obj = imageHistogram(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end  
            obj.histo_averages.count = 1;
            obj.histo_averages.pixno = [];
            obj.histo_averages.codes = [];
            
            obj.ClassType = obj.Type;
            obj.LinkObjects;   
            if strcmpi(obj.Type,'box')
                obj.imageIN = obj.InputObject.imageOUT_cropped;
            else
                obj.imageIN = obj.InputObject.imageOUT;
            end
            
            if strcmpi(obj.imageIN.type,'bayer') %bayer
                [MAX,String] = obj.plotBayer_Hist(obj.imageIN.image);
            else
                [MAX,String] = obj.plotRGB_Hist(obj.imageIN.image);
            end
            obj.handles.text = text(255*0.85,MAX,String);
            
            set(obj.handles.axis,'ylim',[0 MAX*1.2]);
            set(obj.handles.axis,'xlim',[0 255 + 5]); % + 5  to see clipped pixels
            set(obj.handles.text,   'Position', [255*0.85,MAX,0], ...
                                    'String',   String);
            obj.addlistener(    'Visible',  'PostSet', @obj.updateVisible);
        end
        function [MAX,String] = plotRGB_Hist(obj,image)
            % Convert RGB image to YCbCr to find luma values
            imageycbcr = rgb2ycbcr(image);
            im_luma = imageycbcr(:,:,1);

            % Calculate the histograms
            rHist = imhist(image(:,:,1), obj.nBins); % Change nBins to the depth of the image
            gHist = imhist(image(:,:,2), obj.nBins);
            bHist = imhist(image(:,:,3), obj.nBins);
            lumaHist = imhist(im_luma, obj.nBins);

            % Draw the figure
            if obj.Visible == true
                h.figure = figure('Visible','on');
            else
                h.figure = figure('Visible','off');
            end
            
            h.red = plot(1:256, rHist,'r');
            hold on
            h.green = plot(1:256, gHist,'g');
            hold on
            h.blue = plot(1:256, bHist,'b');
            hold on
            h.luma = plot(1:256, lumaHist,'k');
            h.axis = gca;
            set(h.figure,'Name',        'Histogram');
            set(h.figure,'NumberTitle', 'off');
            xlabel('Pixel Value (Codes)');
            ylabel('Number Of Pixels');
            
            obj.handles.figure = h.figure;
            obj.handles.red = h.red;
            obj.handles.green = h.green;
            obj.handles.blue = h.blue;
            obj.handles.luma = h.luma;
            obj.handles.axis = h.axis;
            
            %% Put mean value in corner
            MAX = max([max(rHist),max(gHist),max(bHist), max(lumaHist)]);
            String = obj.CalculateMeansRGB(image);
        end
        function [MAX,String] = plotBayer_Hist(obj,image)
            %%
            h.figure = figure;
            %%
            [rHist,grHist,gbHist,bHist] = CalculateHistBayer(obj,image);
             % Change nBins to the depth of the image  
%             h.grey = plot(1:20, Hist,'k');
            obj.handles.red = plot(1:256, rHist,'r');  hold on;
            obj.handles.gr = plot(1:256, grHist,'g');  hold on;
            obj.handles.gb = plot(1:256, gbHist,'g');  hold on;
            obj.handles.blue = plot(1:256, bHist,'b'); hold on;
            set(obj.handles.gr,'Color',[0.6,0.8,0.2],'LineWidth',0.5);
            set(obj.handles.gb,'Color',[0.2,0.8,0.6],'LineWidth',0.5);
            
            obj.handles.axis = gca;
            set(h.figure,'Name','Histogram');
            set(h.figure,'NumberTitle','off');
            xlabel('Pixel Value (Codes)');
            ylabel('Number Of Pixels');
            
            %%
            MAX = max([max(rHist),max(grHist),max(gbHist),max(bHist)]);
            String = obj.CalculateMeansBayer(image);
        end
        function String = CalculateMeansBayer(obj,image)
            rImage = image(1:2:end,1:2:end,1);
            grImage = image(2:2:end,1:2:end,1);
            gbImage = image(1:2:end,2:2:end,1);
            bImage = image(2:2:end,2:2:end,1);
            
            r_mean = mean2(rImage);
            gr_mean = mean2(grImage)
            gb_mean = mean2(gbImage);
            b_mean = mean2(bImage);
            
            r_string = num2str(round(r_mean*1023));
            gr_string = num2str(round(gr_mean*1023));
            gb_string = num2str(round(gb_mean*1023));
            b_string = num2str(round(b_mean*1023));
            String = {    'Mean Val:'; ...
                         ['R: ', r_string]; ...
                         ['GR: ', gr_string]; ...
                         ['GB: ', gb_string]; ...
                         ['B: ', b_string] };            
        end
        function String = CalculateMeansRGB(obj,image)
            r_mean = mean2(image(:,:,1));
            g_mean = mean2(image(:,:,2));
            b_mean = mean2(image(:,:,3));
            
            %% 
            if strcmpi(class(image),'double')
               r_mean = r_mean*255;
               g_mean = g_mean*255;
               b_mean = b_mean*255;
            end
            
            %%
            r_string = num2str(round(r_mean));
            g_string = num2str(round(g_mean));
            b_string = num2str(round(b_mean));
            
            String = {    'Mean Val:'; ...
                         ['R: ', r_string]; ...
                         ['G: ', g_string]; ...
                         ['B: ', b_string] };            
        end
        function [rHist,gHist,bHist,lumaHist] = CalculateHistRGB(obj,image,im_luma)
            rHist = imhist(image(:,:,1), obj.nBins);
            gHist = imhist(image(:,:,2), obj.nBins);
            bHist = imhist(image(:,:,3), obj.nBins);
            lumaHist = imhist(im_luma, obj.nBins);               
        end
        function [rHist,grHist,gbHist,bHist] = CalculateHistBayer(obj,image)
            rImage = image(1:2:end,1:2:end,1);
            grImage = image(2:2:end,1:2:end,1);
            gbImage = image(1:2:end,2:2:end,1);
            bImage = image(2:2:end,2:2:end,1);
            
            rHist = imhist(rImage, 256);
            grHist = imhist(grImage, 256);
            gbHist = imhist(gbImage, 256);
            bHist = imhist(bImage, 256);            
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
end

