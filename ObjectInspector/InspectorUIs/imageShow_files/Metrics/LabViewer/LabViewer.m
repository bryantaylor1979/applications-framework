classdef LabViewer < handle
    properties (Hidden = false, SetObservable = true)
        Visible
        RGB = [100,120,140];
        RGB_Name = 'AL';
        RGB2 = [];
        RGB2_Name = 'BRCM'
        Title = 'Lab Viewer';
        Spec = '6500K';
        ab_Ref = [0,0]
        DeltaC = 5;
        Lab = [NaN,NaN,NaN];
        Clipped = false;
    end
    properties (Hidden = true, SetObservable = true)
        handle
        Spec_LUT = {    '6500K'; ...    
                        '4200K'; ...
                        '2800K'};
        a_Range = [-65:80]
        b_Range = [-65:100]
        DATASET_OUT
        DATASET_OUT2
    end
    methods
        function Example(obj)
            %%
            close all 
            clear classes 
            
            %% single point plot
            obj = LabViewer('RGB',[100,120,140])
            ObjectInspector(obj)  
            
            %% multiple point plot
            close all
            clear classes
            RGB_Values = [100,120,140; ...
                          140, 50, 20];
            filenames = {'image1.bmp'; ...
                         'image2.bmp'};
            DATASET = dataset(  {RGB_Values(:,1),'R'}, ...
                                {RGB_Values(:,2),'G'}, ...
                                {RGB_Values(:,2),'B'}, ...
                                {filenames,'filenames'});
                            
            RGB_Values = [100, 80,150; ...
                          140, 60, 30];         
            DATASET2 = dataset( {RGB_Values(:,1),'R'}, ...
                                {RGB_Values(:,2),'G'}, ...
                                {RGB_Values(:,2),'B'}, ...
                                {filenames,'filenames'});     
                            
            obj = LabViewer('RGB',DATASET,'RGB2',DATASET2);
%             ObjectInspector(obj)
            
            %%

        end
        function RUN(obj)
            switch obj.Spec
                case '6500K'
                    obj.ab_Ref = [0,0];
                    obj.DeltaC = 5;
                case '4200K'
                    obj.ab_Ref = [2,3];
                    obj.DeltaC = 5;
                case '2800K'
                    obj.ab_Ref = [7,10];
                    obj.DeltaC = 5;
                otherwise
            end
            obj.UpdateVert_CrossHair(obj.ab_Ref(1));
            obj.UpdateHor_CrossHair(obj.ab_Ref(2));      
            obj.UpdateCircle(obj.ab_Ref(1),obj.ab_Ref(2));
            if max(obj.RGB) > 255
                obj.Clipped = true;
            end
            [L,a,b] = RGB2Lab(obj.RGB(1),obj.RGB(2),obj.RGB(3));
            obj.UpdateImagePoint(a,b);
            obj.Lab = [L,a,b];
        end
    end
    methods (Hidden = true)
        function obj = LabViewer(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.GenerateFigure();
            obj.AddVert_CrossHair(obj.ab_Ref(1));
            obj.AddHor_CrossHair(obj.ab_Ref(2));
            obj.AddCircle(obj.ab_Ref(1),obj.ab_Ref(2));
            
            CLASS = class(obj.RGB);
            if strcmpi(CLASS,'dataset')
                %%
                DATASET_OUT = obj.CalcAllCords(obj.RGB); 
                obj.AddImagePoints(DATASET_OUT.x,DATASET_OUT.y,'k.');
                set(get(get(obj.handle.crosshair.h, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                set(get(get(obj.handle.crosshair.v, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                set(get(get(obj.handle.crosshair.c, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                
                if not(isempty(obj.RGB2))
                    DATASET_OUT2 = obj.CalcAllCords(obj.RGB2); 
                    obj.AddImagePoints(DATASET_OUT2.x,DATASET_OUT2.y,'r.');
                end
                %%
                figure(obj.handle.figure);
                h = legend(obj.RGB_Name,obj.RGB2_Name,  'Location','North', ...
                                                        'Orientation', 'vertical');
                set(h,'Interpreter','none');
                %%
                obj.DATASET_OUT = DATASET_OUT;
                obj.DATASET_OUT2 = DATASET_OUT2;
            else
                if max(obj.RGB) > 255
                    obj.Clipped = true;
                end
                [L,a,b] = RGB2Lab(obj.RGB(1),obj.RGB(2),obj.RGB(3));
                [x,y] = obj.Lab2Axis(a,b);
                obj.AddImagePoint(x,y);
                obj.Lab = [L,a,b];               
            end
            %%
            drawnow;
            obj.handle.datatip = datacursormode(obj.handle.figure);
            set(obj.handle.datatip,'UpdateFcn',@obj.UpdateFcn);
            obj.addlistener(    'Visible',  'PostSet', @obj.updateVisible);
        end
        function DATASET_OUT = CalcAllCords(obj,DATASET_RGB)
                %%
                R = DATASET_RGB.R;
                G = DATASET_RGB.G;
                B = DATASET_RGB.B;
                x = size(R,1);
                for i = 1:x
                    [L(i,1),a(i,1),b(i,1)] = RGB2Lab(R(i),G(i),B(i));
                    [x(i,1),y(i,1)] = obj.Lab2Axis(a(i,1),b(i,1));
                end
                DATASET_OUT = [obj.RGB,dataset( {L,'L'},...
                                                {a,'a'}, ...
                                                {b,'b'}, ...
                                                {x,'x'}, ...
                                                {y,'y'})];         
        end
        function AddImagePoint(obj,x,y)
            hold on, h = plot(x,y,'ko');
            obj.handle.imagepoint = h;
            set(obj.handle.imagepoint,'MarkerSize',10);
            set(obj.handle.imagepoint,'MarkerFaceColor',obj.RGB./255);                
        end
        function AddImagePoints(obj,x,y,lineSpec)
            figure(obj.handle.figure);
            hold on, h = plot(x,y,lineSpec);
            obj.handle.imagepoint = h;
%             set(obj.handle.imagepoint,'MarkerSize',1);
%             set(obj.handle.imagepoint,'MarkerFaceColor',[1,0,0]);            
        end
        function UpdateImagePoint(obj,a,b)
            [x,y] = Lab2Axis(obj,a,b);
            set(obj.handle.imagepoint,'XDATA',x)
            set(obj.handle.imagepoint,'YDATA',y)   
            if max(obj.RGB) > 255
                RGB = obj.RGB./max(obj.RGB);
            else
                RGB = obj.RGB./255;
            end
            set(obj.handle.imagepoint,'MarkerFaceColor',RGB);
        end
        function [x,y] = Lab2Axis(obj,a,b)
            x = 65+a;
            y = 100-b;
        end
        function [a,b] = Axis2Lab(obj,x,y)
            a = x-65;
            b = 100-y;            
        end
        function AddCircle(obj,a,b)
            [x,y] = obj.CalculateCords_Circle(obj.DeltaC*100);
            hold on
            h = plot(x+65+a,y+100-b,'k-');
            colour = 0.5;
            set(h,'LineWidth',  2.5                         );
            set(h,'Color',      [colour,colour,colour]      ); 
            obj.handle.crosshair.c = h;
        end
        function UpdateCircle(obj,a,b)
            [x,y] = obj.CalculateCords_Circle(obj.DeltaC*100);
            set(obj.handle.crosshair.c,'XDATA',x+65+a); 
            set(obj.handle.crosshair.c,'YDATA',y+100-b);           
        end
        function GenerateFigure(obj)
            %%
            IMAGE = imread('Lab.bmp');
            obj.handle.figure = figure;
            obj.handle.axes = image(IMAGE);
            Position = get(obj.handle.figure,'Position');
            Position(3) = 420;
            Position(4) = 455;
            if obj.Visible == true
                set(obj.handle.figure,  'Position',     Position, ...
                                        'Name',         obj.Title, ...
                                        'Visible',      'on', ...
                                        'NumberTitle',  'off');
            else
                set(obj.handle.figure,  'Position',     Position, ...
                                        'Name',         obj.Title, ...
                                        'Visible',      'off', ...
                                        'NumberTitle',  'off');
            end
            xlabel('a*')
            ylabel('b*')
            XLabel = str2num(get(gca,'XTickLabel'));
            YLabel = str2num(get(gca,'YTickLabel'));
            set(gca,'XTickLabel',num2str(XLabel + min(obj.a_Range)));
            set(gca,'YTickLabel',num2str(max(obj.b_Range) - YLabel)); 
        end
        function output_txt = UpdateFcn(varargin)
            obj = varargin{1};
            event_obj = varargin{3};
            pos = get(event_obj,'Position');
            
            if strcmpi(class(obj.RGB),'dataset')
                n = find(pos(1)==obj.DATASET_OUT.x);
                output_txt = obj.MultipleInputsUpdateFcn(n,pos);
            else
                [L,a,b] = RGB2Lab(obj.RGB(1),obj.RGB(2),obj.RGB(3));
                [a1,b1]= obj.Axis2Lab(pos(1),pos(2));
                if and( round(a*100) == round(a1*100), round(b*100) == round(b1*100) )
                output_txt = {  ['L: ',         num2str(L)]; ...
                                ['a: ',         num2str(a)]; ...
                                ['b: ',         num2str(b)]; ...
                                ['R: ',         num2str(obj.RGB(1))]; ...
                                ['G: ',         num2str(obj.RGB(2))]; ...
                                ['B: ',         num2str(obj.RGB(3))] ...
                                };  
                else
                   [a,b] = obj.Axis2Lab(pos(1),pos(2));
                   output_txt = {  'Lab Cord:'; ...
                                  ['[a,b]: [', num2str(a),', ',num2str(b),']'] ...
                                    };
                end
            end
        end
        function output_txt = MultipleInputsUpdateFcn(obj,n,pos)
            if isempty(n)
               n = find(pos(1)==obj.DATASET_OUT2.x);
               if isempty(n)
                   [a,b] = obj.Axis2Lab(pos(1),pos(2));
                   output_txt = {  'Lab Cord:'; ...
                                  ['[a,b]: [', num2str(a),', ',num2str(b),']'] ...
                                    };
               else
                   filename =  obj.DATASET_OUT2.filenames{n};
                   L =  obj.DATASET_OUT2.L(n);
                   a =  obj.DATASET_OUT2.a(n);
                   b =  obj.DATASET_OUT2.b(n);
                   R =  obj.DATASET_OUT2.R(n);
                   G =  obj.DATASET_OUT2.G(n);
                   B =  obj.DATASET_OUT2.B(n);
                   Label = obj.RGB2_Name;
                   output_txt = {  ['Filename: ',  filename]; ...
                            ['Label: ',     Label]; ...
                            ['L: ',         num2str(L)]; ...
                            ['a: ',         num2str(a)]; ...
                            ['b: ',         num2str(b)]; ...
                            ['[R, G, B]: [',num2str(R),' ,',num2str(G),' ,',num2str(B),']'] ...
                            };  
               end
            else
               filename =  obj.DATASET_OUT.filenames{n};
               L =  obj.DATASET_OUT.L(n);
               a =  obj.DATASET_OUT.a(n);
               b =  obj.DATASET_OUT.b(n);
               R =  obj.DATASET_OUT.R(n);
               G =  obj.DATASET_OUT.G(n);
               B =  obj.DATASET_OUT.B(n);
               Label = obj.RGB_Name;
               output_txt = {  ['Filename: ',  filename]; ...
                            ['Label: ',     Label]; ...
                            ['L: ',         num2str(L)]; ...
                            ['a: ',         num2str(a)]; ...
                            ['b: ',         num2str(b)]; ...
                            ['[R, G, B]: [',num2str(R),' ,',num2str(G),' ,',num2str(B),']'] ...
                            };  
            end
          
        end
        function UpdateVert_CrossHair(obj,Loc)
            MinVal = abs(min(obj.b_Range)); 
            set(obj.handle.crosshair.v,'XDATA',[MinVal+Loc MinVal+Loc])      
        end
        function UpdateHor_CrossHair(obj,Loc)
            MaxVal = max(obj.b_Range); 
            set(obj.handle.crosshair.h,'YDATA',[MaxVal-Loc MaxVal-Loc])            
        end
        function AddVert_CrossHair(obj,Loc)
            %%
            Val = abs(obj.b_Range(1))+obj.b_Range(end);
            hold on;
            MinVal = abs(min(obj.b_Range));
            h = plot([MinVal+Loc MinVal+Loc], [1 Val+1], 'k:');
            colour = 0.7;
            set(h,'LineWidth',  1.5             )
            set(h,'Color',      [colour,colour,colour]   ) 
            obj.handle.crosshair.v = h;
        end
        function AddHor_CrossHair(obj,Loc)
            %% plot
            Val = abs(obj.a_Range(1))+obj.a_Range(end);
            hold on; 
            MaxVal = max(obj.b_Range);
            h = plot([1 Val+1], [MaxVal-Loc MaxVal-Loc],'k:');
            colour = 0.7;
            set(h,'LineWidth',  1.5                         );
            set(h,'Color',      [colour,colour,colour]      );     
            obj.handle.crosshair.h = h;
        end
        function [L,a,b] = RGB2Lab(R,G,B)
            % function [L, a, b] = RGB2Lab(R, G, B)
            % RGB2Lab takes matrices corresponding to Red, Green, and Blue, and 
            % transforms them into CIELab.  This transform is based on ITU-R 
            % Recommendation  BT.709 using the D65 white point reference.
            % The error in transforming RGB -> Lab -> RGB is approximately
            % 10^-5.  RGB values can be either between 0 and 1 or between 0 and 255.  
            % By Mark Ruzon from C code by Yossi Rubner, 23 September 1997.
            % Updated for MATLAB 5 28 January 1998.

            if (nargin == 1)
              B = double(R(:,:,3));
              G = double(R(:,:,2));
              R = double(R(:,:,1));
            end

            if ((max(max(R)) > 1.0) | (max(max(G)) > 1.0) | (max(max(B)) > 1.0))
              R = R/255;
              G = G/255;
              B = B/255;
            end

            [M, N] = size(R);
            s = M*N;

            % Set a threshold
            T = 0.008856;

            RGB = [reshape(R,1,s); reshape(G,1,s); reshape(B,1,s)];

            % RGB to XYZ
            MAT = [0.412453 0.357580 0.180423;
                   0.212671 0.715160 0.072169;
                   0.019334 0.119193 0.950227];
            XYZ = MAT * RGB;

            X = XYZ(1,:) / 0.950456;
            Y = XYZ(2,:);
            Z = XYZ(3,:) / 1.088754;

            XT = X > T;
            YT = Y > T;
            ZT = Z > T;

            fX = XT .* X.^(1/3) + (~XT) .* (7.787 .* X + 16/116);

            % Compute L
            Y3 = Y.^(1/3); 
            fY = YT .* Y3 + (~YT) .* (7.787 .* Y + 16/116);
            L  = YT .* (116 * Y3 - 16.0) + (~YT) .* (903.3 * Y);

            fZ = ZT .* Z.^(1/3) + (~ZT) .* (7.787 .* Z + 16/116);

            % Compute a and b
            a = 500 * (fX - fY);
            b = 200 * (fY - fZ);

            L = reshape(L, M, N);
            a = reshape(a, M, N);
            b = reshape(b, M, N);

            if ((nargout == 1) | (nargout == 0))
              L = cat(3,L,a,b);
            end
        end
        function updateVisible(varargin)
            obj = varargin{1};
            if obj.Visible == true
                set(obj.handle.figure,'Visible','on');
            else
                set(obj.handle.figure,'Visible','off');
            end
        end
    end
    methods (Hidden = true) %circle plot
        function [x,y] = CalculateCords_Circle(obj,Spec_S)
            %%
            [x(1),y(1)]     = obj.HS2cords(0,   Spec_S(1)/100);
            [x(2),y(2)]     = obj.HS2cords(30,  Spec_S(1)/100);
            [x(3),y(3)]     = obj.HS2cords(60,  Spec_S(1)/100);
            [x(4),y(4)]     = obj.HS2cords(90,  Spec_S(1)/100);
            [x(5),y(5)]     = obj.HS2cords(120, Spec_S(1)/100);
            [x(6),y(6)]     = obj.HS2cords(150, Spec_S(1)/100);
            [x(7),y(7)]     = obj.HS2cords(180, Spec_S(1)/100);
            [x(8),y(8)]     = obj.HS2cords(210, Spec_S(1)/100);
            [x(9),y(9)]     = obj.HS2cords(240, Spec_S(1)/100);
            [x(10),y(10)]   = obj.HS2cords(270, Spec_S(1)/100);
            [x(11),y(11)]   = obj.HS2cords(300, Spec_S(1)/100);
            [x(12),y(12)]   = obj.HS2cords(330, Spec_S(1)/100);
            [x(13),y(13)]   = obj.HS2cords(0,   Spec_S(1)/100);

        end
        function [x,y] = HS2cords(obj,Hue,Sat)
            %%
%             
            HueDegrees = Hue;
            x = Sat*sind(HueDegrees);
            y = Sat*cosd(HueDegrees);            
        end
    end
end