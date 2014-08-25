classdef imrect_custom < handle
    properties (SetObservable = true)
        Enable = true
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
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes         
            
            %%
            cpm_OBJ = CurrentPostionMonitor(gcf)
            obj = imrect_custom(gcf,cpm_OBJ)
            
            %%
            delete(obj)
            
            %%
            delete(cpm_OBJ)
            
            %%
            ObjectInspector(obj)
        end
    end
    methods (Hidden = true)
        function delete(varargin)
            %%
            obj = varargin{1};
            if not(isempty(obj.hbox))
                delete(obj.hbox.one);
                delete(obj.hbox.two);
            end
            obj.hfigure = [];
            obj.cpm_OBJ = [];
            delete(obj.handles.listener.CurrentPos);
            delete(obj.handles.listener.MouseButtonState);
        end
        function obj =  imrect_custom(figHandle,cpm_OBJ)     
            obj.cpm_OBJ = cpm_OBJ;
            if isempty(cpm_OBJ)
               error('current monitor is empty. Not valid. Please give active handle.')
            end
            obj.hfigure = figHandle;
            obj.handles.listener.CurrentPos =       obj.cpm_OBJ.addlistener('CurrentPos','PostSet',@obj.Moving);     
            obj.handles.listener.MouseButtonState = obj.cpm_OBJ.addlistener('MouseButtonState','PostSet',@obj.UpDown);
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
                   StartPos = round(obj.StartPos);
                   EndPos = round(obj.CurrentPos);
                   height = abs(StartPos(2)-EndPos(2));
                   width = abs(StartPos(1)-EndPos(1));
                   
                   SignVertical = sign(StartPos(2)-EndPos(2));
                   SignHorizontal = sign(StartPos(1)-EndPos(1));
                   
                   if SignVertical == 1
                        if SignHorizontal == 1
                            % working
                            Quad = 1;
                            cord_end  = StartPos;
                            cord_start =  EndPos;
                        else
                            Quad = 2;
                            % hor
                            cord_start(1)  = StartPos(1);
                            cord_start(2)  = EndPos(2);
                            
                            cord_end(1) =  EndPos(1);
                            cord_end(2) =  StartPos(2);
                        end
                   else
                        if SignHorizontal == 1
                            Quad = 3;
                            cord_start(1)  = EndPos(1);
                            cord_start(2)  = StartPos(2);
                            
                            cord_end(1) =  StartPos(1);
                            cord_end(2) =  EndPos(2);
                        else
                            % working
                            Quad = 4;
                            cord_end  = EndPos ;
                            cord_start =  StartPos;
                        end
                   end
                   
                   if obj.Log == true
                       disp('SUMMARY')
                       disp('=======')
                       disp(['Start position: [',num2str(StartPos(1)),' , ',num2str(StartPos(2)),']']);
                       disp(['End position: [',num2str(EndPos(1)),' , ',num2str(EndPos(2)),']']); 
                       disp(['Quad: ',num2str(Quad)])
                       disp(['Height: ',num2str(height)])
                       disp(['Width: ',num2str(width)])
                       disp(' ')
                       disp(' ')
                   end
                   
%                    cord_end  = [min(topleft(1),bottomright(1)), max(topleft(1),bottomright(1))]
%                    cord_start = [min(topleft(2),bottomright(2)), max(topleft(2),bottomright(2))]

                   %%
                    x = cord_start(1);
                    y = cord_start(2);
                    w = cord_end(1)-cord_start(1);
                    h = cord_end(2)-cord_start(2);
                    if obj.SubState == 1
                        if and(w > 0, h > 0)
                        obj.hbox.one = rectangle(   'EdgeColor', [0,0,1], ...
                                                    'FaceColor', 'none', ...
                                                    'LineStyle', '-', ...
                                                    'LineWidth', 2, ...
                                                    'Position',    ...
                                                            [   x, ...
                                                                y, ...
                                                                w, ...
                                                                h]);
                        obj.hbox.two = rectangle(   'EdgeColor', [1,1,1], ...
                                                    'FaceColor', 'none', ...
                                                    'LineStyle', '-', ...
                                                    'LineWidth', 1, ...
                                                    'Position',    ...
                                                            [   x, ...
                                                                y, ...
                                                                w, ...
                                                                h]);
                        obj.SubState = 2;
                        end
                    else
                        if and(w > 0, h > 0)
                        set(obj.hbox.one ,'Position', ...
                                                            [   x, ...
                                                                y, ...
                                                                w, ...
                                                                h]);
                        set(obj.hbox.two ,'Position', ...
                                                            [   x, ...
                                                                y, ...
                                                                w, ...
                                                                h]);
                        end
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