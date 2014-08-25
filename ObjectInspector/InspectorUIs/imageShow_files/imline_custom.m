classdef imline_custom < handle
    properties (SetObservable = true)
        Enable = true
        Colour = [1,0,0];
        State = 'Ready';
        SubState = 0;
        StartPos = [NaN, NaN];
        EndPos = [NaN, NaN];
        CurrentPos = [NaN, NaN];
        BoxDim
        cpm_OBJ
        Log = false;
    end
    properties (Hidden = true)
        hfigure
        hbox
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes         
            
            %%
            cpm_OBJ = CurrentPostionMonitor(gcf)
            obj = imline_custom(gcf,cpm_OBJ)
            
            %%
            delete(obj)
            
            %%
            ObjectInspector(obj)
        end
    end
    methods (Hidden = true)
        function delete(varargin)
            %%
            obj = varargin{1};
            try
                delete(obj.hbox.one);
                delete(obj.hbox.two);
            end
        end
        function obj =  imline_custom(figHandle,cpm_OBJ)
            obj.cpm_OBJ = cpm_OBJ;
            obj.hfigure = figHandle;
            obj.cpm_OBJ.addlistener('CurrentPos','PostSet',@obj.Moving);     
            obj.cpm_OBJ.addlistener('MouseButtonState','PostSet',@obj.UpDown);
        end
        function UpDown(varargin)
            obj = varargin{1};
            if strcmpi(obj.cpm_OBJ.MouseButtonState,'Up')
                obj.ButtonUp();
            else
                obj.ButtonDown();
            end
        end
        function ButtonDown(varargin)
            obj = varargin{1};
            if obj.Enable == true
                obj.State = 'Drawing';
                obj.SubState = 1;
                try
                delete(obj.hbox.one);
                delete(obj.hbox.two);
                end
                obj.StartPos = obj.cpm_OBJ.CurrentPos;
            else
                obj.State = 'Ready';
            end
        end
        function Moving(varargin)
            obj = varargin{1};
            if obj.Enable == true
                obj.CurrentPos = obj.cpm_OBJ.CurrentPos;
                if strcmpi(obj.State,'Drawing');
                    
                   %%
                   drawnow
                   cord_start = round(obj.StartPos);
                   cord_end = round(obj.CurrentPos);

                   %%
                    if obj.SubState == 1
    %                     try

                        
%                         obj.hbox.one = line(        'EdgeColor', [0,0,1], ...
%                                                     'FaceColor', 'none', ...
%                                                     'LineStyle', '-', ...
%                                                     'LineWidth', 2, ...
%                                                     'Position',    ...
%                                                             [   cord_start(1), ...
%                                                                 cord_start(2), ...
%                                                                 cord_end(1)-cord_start(1), ...
%                                                                 cord_end(2)-cord_start(2)]);
                        obj.hbox.one = line([   cord_start(1),              cord_end(1)], ...
                                            [   cord_start(2),              cord_end(2)] );
                        set(obj.hbox.one,'Color',obj.Colour,'LineWidth',2);
                        
                        obj.hbox.two = line([   cord_start(1),              cord_end(1)], ...
                                            [   cord_start(2),              cord_end(2)] );
                        set(obj.hbox.two,'Color',[1,1,1],'LineWidth',1);
                        
%                         obj.hbox.two = line(   'EdgeColor', [1,1,1], ...
%                                                     'FaceColor', 'none', ...
%                                                     'LineStyle', '-', ...
%                                                     'LineWidth', 1, ...
%                                                     'Position',    ...
%                                                             [   cord_start(1), ...
%                                                                 cord_start(2), ...
%                                                                 cord_end(1)-cord_start(1), ...
%                                                                 cord_end(2)-cord_start(2)]);
                        obj.SubState = 2;
    %                     end
                    else
                        set(obj.hbox.one,'XData', [   cord_start(1),              cord_end(1)])
                        set(obj.hbox.one,'YData', [   cord_start(2),              cord_end(2)])
                        set(obj.hbox.two,'XData', [   cord_start(1),              cord_end(1)])
                        set(obj.hbox.two,'YData', [   cord_start(2),              cord_end(2)])
%                         set(obj.hbox.one ,'Position', ...
%                                                             [   cord_start(1), ...
%                                                                 cord_start(2), ...
%                                                                 cord_end(1)-cord_start(1), ...
%                                                                 cord_end(2)-cord_start(2)]);
%                         set(obj.hbox.two ,'Position', ...
%                                                             [   cord_start(1), ...
%                                                                 cord_start(2), ...
%                                                                 cord_end(1)-cord_start(1), ...
%                                                                 cord_end(2)-cord_start(2)]);
                    end
                end    
            end
        end
        function ButtonUp(varargin)
            obj = varargin{1};
            if obj.Enable == true
                obj.EndPos = obj.cpm_OBJ.CurrentPos;

                    if not(obj.StartPos(1) > obj.EndPos(1));
                        topleft = obj.StartPos;
                        bottomright = obj.EndPos;
                    else
                        topleft = obj.EndPos;
                        bottomright =  obj.StartPos;                    
                    end            
                obj.BoxDim = [topleft,bottomright];
                obj.SubState = 0;
    %             pause(0.1)
                obj.State = 'Ready';
            else
                obj.State = 'Ready'; 
            end
        end
    end
end