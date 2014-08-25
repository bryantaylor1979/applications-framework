classdef HuePlot < handle
    properties  (SetObservable = true)
        Visible
        SpecIsVisible = 'on';
        FigureName = 'HSV plotter';
        Color = [0.7,0,1]
        Spec_S = [15,20]
        Spec_H = [15,35]
        Spec = 'Daylight'
        Spec_DATASET
    end
    properties (Hidden = true, SetObservable = true)
        handles
        Spec_LUT = {    'Daylight'; ...
                        'CoolWhite'; ...
                        'IncA_1'; ...
                        'IncA_2';
                        'Horizon'};
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            %%
            obj = HuePlot;
            
            
            %%
            get(ot.handle.control,'Position')
        end
        function RUN(obj)
            %% Spec
            Spec = obj.Spec;
            DS = DataSetFiltering();
            Lums = DS.GetColumn(obj.Spec_DATASET,'Lum');
            n = find(strcmpi(Lums,Spec));
            SET = obj.Spec_DATASET(n,:);
            
            %%
            Spec_S(1) = DS.GetColumn(SET,'S_min');
            Spec_S(2) = DS.GetColumn(SET,'S_max');
            Spec_H(1) = DS.GetColumn(SET,'H_min');
            Spec_H(2) = DS.GetColumn(SET,'H_max');
            obj.Spec_S = Spec_S;
            obj.Spec_H = Spec_H;
            
            obj.SetInputColour(obj.Color);
            obj.SetLocation(obj.Color);
            obj.updateLine();
        end
    end
    methods (Hidden = true)
        function obj = HuePlot(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            %%
            Z = zeros(7);
            if obj.Visible == true
                obj.handles.figure = figure('Visible','on');
            else
                obj.handles.figure = figure('Visible','off');
            end
            
            obj.handles.cursor = datacursormode(obj.handles.figure);
            set(obj.handles.cursor,'UpdateFcn',@obj.datatip_text)
            
            h = compass(Z);
            % Z(2) = (2/(3^0.5))*1 + (2/(3^0.5))*1i %60 degrees
            % Z(2) = -1+ 0i
            factor = 1/2; %Sin60
            factor2 = 3^0.5/2; %Cos60
            
            Loc = [ 1,  0; ...
                    1*factor,  1*factor2; ...
                   -1*factor,  1*factor2; ...
                   -1, 0; ...
                   -1*factor, -1*factor2; ...
                    1*factor, -1*factor2; ...
                    0.35,       0.35];
                
            Color = [1,0,0; ...
                     1,1,0; ...
                     0,1,0; ...
                     0,1,1; ...
                     0,0,1; ...
                     1,0,1; ...
                     1,1,1];
                 
            for i = 1:size(Loc,1)
                %
                handle = (i-1)*6 + 1;
                set(h(handle),'XDATA',Loc(i,1));
                set(h(handle),'YDATA',Loc(i,2));
                set(h(handle),'Marker','o','LineWidth',7,'Color',Color(i,:));  
            end
            obj.handles.compass = h;
            title('HUE Colour Space Plot')
            xlabel('Angle Degrees (HUE)')
            
            set(obj.handles.figure, 'Name',         obj.FigureName, ...
                                    'NumberTitle',  'off');
                                
            obj.DefineSpec();
            obj.PlotSpec;
            obj.addlistener(    'Spec',     'PostSet', @obj.updateSpec);
            obj.addlistener(    'Visible',  'PostSet', @obj.updateVisible);
        end
        function SetInputColour(obj,Color)
            %%
            handle = (7-1)*6 + 1;
            set(obj.handles.compass(handle),'Color',Color);  
        end
        function SetLocation(obj,Color)
            %%
            Loc = rgb2hsv(Color) ;
            Hue = Loc(1);
            Sat = Loc(2);
%             Sat = Sat*max(Color);
            HueDegrees = 360*Hue*-1+90;
            [x,y] = obj.HS2cords(HueDegrees,Sat);

            handle = (7-1)*6 + 1;
            set(obj.handles.compass(handle),'XDATA',x);
            set(obj.handles.compass(handle),'YDATA',y);
        end        
        function txt = datatip_text(varargin)
            disp('hello')
            obj = varargin{1};
            empt = varargin{2};
            event_obj = varargin{3};
            pos = get(event_obj,'Position');
            
            S = 100*(max(obj.Color) - min(obj.Color))/max(obj.Color);
            H = 60*(obj.Color(2)-obj.Color(3))/(max(obj.Color) - min(obj.Color));
            obj.Color
            txt = { ['RGB: [',num2str(obj.Color(1)), ' ,', num2str(obj.Color(2)),' ,',num2str(obj.Color(3)),']'],...
                    ['S: ',num2str(S)], ...
                    ['H: ',num2str(H)]};
        end
        function [x,y] = HS2cords(obj,Hue,Sat)
            %%
%             
            HueDegrees = Hue;
            x = Sat*sind(HueDegrees);
            y = Sat*cosd(HueDegrees);            
        end
    end
    methods (Hidden = true) %Spec plot
        function DefineSpec(obj)
            %%               Lum        S_min   S_max   H_min   H_max
            Spec_LUT = {    'Daylight', 10,     10,     0,      0; ...
                            'CoolWhite',10,     10,     0,      0; ...
                            'IncA_1',   5,      15,     10,     40; ...
                            'IncA_2',   15,     20,     15,     35; ...
                            'Horizon'   20,     30,     15,     35};   
                        
            obj.Spec_DATASET = dataset( {Spec_LUT(:,1),'Lum'}, ...
                                        {cell2mat(Spec_LUT(:,2)),'S_min'}, ...
                                        {cell2mat(Spec_LUT(:,3)),'S_max'}, ...
                                        {cell2mat(Spec_LUT(:,4)),'H_min'}, ...
                                        {cell2mat(Spec_LUT(:,5)),'H_max'})         
        end
        function PlotSpec(obj)
            %%
            set(0,'CurrentFigure',obj.handles.figure);
         
            %%
            if obj.Spec_H(1) == 0
            [x,y] = obj.CalculateCords_Circle(obj.Spec_H,obj.Spec_S); 
            else
            [x,y] = obj.CalculateCords_Box(obj.Spec_H,obj.Spec_S);
            end
            obj.plotLine(x,y)
        end   
        function plotLine(obj,x,y)
           hold on
           obj.handles.spec_line = line(y,x);
           set(obj.handles.spec_line,'Color',[0.2,0.2,0.2],'LineWidth',3);            
        end
        function updateLine(obj)
            %%
            if obj.Spec_H(1) == 0
            [x,y] = obj.CalculateCords_Circle(obj.Spec_H,obj.Spec_S); 
            else
            [x,y] = obj.CalculateCords_Box(obj.Spec_H,obj.Spec_S);
            end
            set(obj.handles.spec_line,'XDATA',y,'Visible',obj.SpecIsVisible);
            set(obj.handles.spec_line,'YDATA',x);
        end
        function [x,y] = CalculateCords_Box(obj,Spec_H,Spec_S)
           [x(1),y(1)] = obj.HS2cords(Spec_H(1),Spec_S(1)/100);
           [x(2),y(2)] = obj.HS2cords(Spec_H(2),Spec_S(1)/100);
           [x(3),y(3)] = obj.HS2cords(Spec_H(2),Spec_S(2)/100);
           [x(4),y(4)] = obj.HS2cords(Spec_H(1),Spec_S(2)/100);
           [x(5),y(5)] = obj.HS2cords(Spec_H(1),Spec_S(1)/100);  
        end
        function [x,y] = CalculateCords_Circle(obj,Spec_H,Spec_S)
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
        function updateSpec(varargin)
            %%
            obj = varargin{1};
            obj.RUN();
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
end%% HUE plot


