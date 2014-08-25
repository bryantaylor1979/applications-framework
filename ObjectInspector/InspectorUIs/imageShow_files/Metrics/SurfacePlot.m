classdef SurfacePlot < handle & ...
                       FeederObject
    %Example 1: 
    %   [image] = readimage('868VCM_Part_D5_AGain_0x00.pgm');
    %   objMesh = SurfacePlot(image);
    %
    %Example 2:
    %   objMesh = SurfacePlot('868VCM_Part_D5_AGain_0x00.pgm');
    properties (SetObservable = true)
        Visible
        Type
        Global_Enable = true;
        R_Enable = true;
        GR_Enable = true;
        GB_Enable = true;
        B_Enable = true;
        
        Max = 64; %Input image max pixel value
        Min = 64; %Input image min pixel value
        Mean = 64; %Input image mean pixel value
        BitDepth = 10
        log = true;
        Ydim = 40;
        InputImageRange = [0,1024];
    end
    properties (Hidden = true)
        imageIN = [];
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            %%
            raw = rawReader();
            %%
            ObjectInspector(raw);
            %%
            objMesh = SurfacePlot( 'imageIN',  raw.imageOUT);
%             objMesh.RUN
            ObjectInspector(objMesh)
            
            %%
            [image] = readimage('868VCM_Part_D5_AGain_0x00.pgm');
            objMesh = SurfacePlot(image);
        end
        function RUN(obj)
            %%
            imageIN  = obj.imageIN.image;
            InputImageRange = obj.ImageRange(imageIN);
%             imageIN = obj.ForceBitDepth(imageIN);
            [x,y,z] = size(imageIN); 
            switch lower(obj.imageIN.type)
                case 'bayer'
                    error('not currently supported')   
                case 'rgb'
                    newimage1 = obj.Denoise(imageIN);    
                    
                    %%
                    set(obj.handles.r,'ZData',newimage1(:,:,1));
                    set(obj.handles.g,'ZData',newimage1(:,:,2));
                    set(obj.handles.b,'ZData',newimage1(:,:,3));
                    
                    %%
                    set(obj.handles.r,'Visible','on')
                    set(obj.handles.g,'Visible','on')
                    %%
%                     h1 = obj.intPlot(newimage1(:,:,1),[1,0,0]);
%                     h3 = obj.add2Plot(newimage1(:,:,2), [0,1,0]);
%                     h4 = obj.add2Plot(newimage1(:,:,3), [0,0,1]);
                case 'rgbg'
                    error('not currently supported')                   
                otherwise
                    error('dark mesh does not support this image type')
            end
        end
    end
    methods (Hidden = true)
        function obj = SurfacePlot(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end  
            obj.ClassType = obj.Type;
            obj.LinkObjects; 
            obj.imageIN = obj.InputObject.imageOUT;
            
            addlistener(obj,'Global_Enable','PostSet',  @obj.updateGlobal);
            addlistener(obj,'R_Enable','PostSet',       @obj.updateRed);
            addlistener(obj,'GR_Enable','PostSet',      @obj.updateGR);
            addlistener(obj,'GB_Enable','PostSet',      @obj.updateGB);
            addlistener(obj,'B_Enable','PostSet',       @obj.updateBlue);
            addlistener(obj,'Visible','PostSet',        @obj.updateVisible);
            
            obj.plotMesh(obj.imageIN);
        end
        function updateVisible(varargin)
            obj = varargin{1};
            if obj.Visible == true
                set(obj.handles.figure,'Visible','on');
            else
                set(obj.handles.figure,'Visible','off');
            end
        end
        function updateRed(varargin)
            obj = varargin{1};
            if obj.R_Enable == true
                set(obj.handles.r, 'Visible','on');
            else
                set(obj.handles.r, 'Visible','off');
            end
        end
        function updateGR(varargin)
            obj = varargin{1};
            if obj.GR_Enable == true
                set(obj.handles.gr,'Visible','on');
            else
                set(obj.handles.gr,'Visible','off');
            end
        end
        function updateGB(varargin)
            obj = varargin{1};
            if obj.GB_Enable == true
                set(obj.handles.gb,'Visible','on');
            else
                set(obj.handles.gb,'Visible','off');
            end
        end
        function updateBlue(varargin)
            obj = varargin{1};
            if obj.B_Enable == true
                set(obj.handles.b,'Visible','on');
            else
                set(obj.handles.b,'Visible','off');
            end
        end
        function updateGlobal(varargin)
            obj = varargin{1};
            if obj.Global_Enable == true
                set(obj.handles.gobal,'Visible','on');
            else
                set(obj.handles.gobal,'Visible','off');
            end
        end
        function obj = plotMesh(obj,imageIN)
            %%
            InputImageRange = obj.ImageRange(imageIN.image);
            
%             imageIN = obj.ForceBitDepth(imageIN);
            image = imageIN.image;
            [x,y,z] = size(image); 
            switch lower(imageIN.type)
                case 'bayer'
                    BS = BayerSplit;
                    [newimage] = BS.RUN(image,1);
                    newimage1(:,:,1) = obj.Denoise(newimage(:,:,1));
                    newimage1(:,:,2) = obj.Denoise(newimage(:,:,2));
                    newimage1(:,:,3) = obj.Denoise(newimage(:,:,3));
                    newimage1(:,:,4) = obj.Denoise(newimage(:,:,4));   
                    h1 = obj.intPlot(newimage1(:,:,1),[0.5,0.5,0.5]);
                    h2 = obj.add2Plot(newimage1(:,:,1), [1,0,0]);
                    h3 = obj.add2Plot(newimage1(:,:,2), [0,1,0.5]);
                    h4 = obj.add2Plot(newimage1(:,:,3), [0.5,1,0]);
                    h5 = obj.add2Plot(newimage1(:,:,4), [0,0,1]);
                case 'rgb'
                    newimage1 = image;
                    newimage1 = obj.Denoise(newimage1);    
                    h1 = obj.intPlot(newimage1(:,:,1),[1,0,0]);
                    h3 = obj.add2Plot(newimage1(:,:,2), [0,1,0]);
                    h4 = obj.add2Plot(newimage1(:,:,3), [0,0,1]);
                    obj.handles.r = h1;
                    obj.handles.g = h3;
                    obj.handles.b = h4;
                case 'rgbg'
                    newimage1 = image;
                    h1 = obj.intPlot(newimage1(:,:,1),[1,0,0]);
                    h3 = obj.add2Plot(newimage1(:,:,2), [0,0,1]);                    
                otherwise
                    error('dark mesh does not support this image type')
            end
            
% %             if y > 64
% %                 image = obj.Denoise(image);
% %             end
%             obj.GetImageStats(image);
%             
%             InputImageRange = obj.ImageRange(image);
%             
%             switch imageIN.fsd
%                 case 1023
%                     InputImageRange = round(InputImageRange);
%                 otherwise
%             end
%                


            if obj.Global_Enable == false
                set(h1,'Visible','off');
            end
            if obj.R_Enable == false
                set(h2,'Visible','off');
            end
            if obj.GR_Enable == false
                set(h3,'Visible','off');
            end
            if obj.GB_Enable == false
                set(h4,'Visible','off');
            end
            if obj.B_Enable == false
                set(h5,'Visible','off');
            end
            
            %%
            obj.InputImageRange = InputImageRange;
            obj.handles.gobal = h1;
        end
        function Range = ImageRange(obj,image)
            Min = min(min(image));
            Max = max(max(image));
            Range = [Min,Max];            
        end
        function GetImageStats(obj,image)
            obj.Max = round(max(max(image)));
            obj.Min = round(min(min(image)));
            obj.Mean = round(mean(mean(image))); 
            if obj.log == true
                disp(['Max: ',num2str(obj.Max),' Min: ',num2str(obj.Min ),' Mean: ',num2str(obj.Mean)])  
            end
        end
        function imageout = Denoise(obj,imagein)
            [x,y] = size(imagein);
            Ratio = y/x;
            Ydim = obj.Ydim;
            imageout = imresize(imagein, [Ydim Ydim*Ratio]);
        end
        function h = intPlot(obj,image,colour)
            if obj.Visible == false
            obj.handles.figure = figure(    'NumberTitle',  'off', ...
                                            'Name',         'Surface Plot', ...
                                            'Visible',      'off');
            else
            obj.handles.figure = figure(    'NumberTitle',  'off', ...
                                            'Name',         'Surface Plot', ...
                                            'Visible',      'on');                
            end
            mesh(image);
            h = surf(image,'FaceColor',colour,'EdgeColor','none');   
            camlight left; lighting phong;
            xlabel('X DIM');
            ylabel('Y DIM');
            zlabel('Offset');
        end
        function h = add2Plot(obj,image,colour)
            hold on;
            h = surf(image,'FaceColor',colour,'EdgeColor','none');
        end
        function imageOUT = ForceBitDepth(obj,imageIN)
            imageOUT = imageIN;
%             imageOUT.image = double(imageIN.image);
%             imageOUT.image = imageOUT.image./imageIN.fsd;   
            imageOUT.class = 'double';
            imageOUT.fsd = 1;
        end
    end
end