classdef plotDATASET < handle
    properties (SetObservable = true)
        newFig = true;
        X_Var
        Y_Var
        DATASET
    end
    properties (Hidden = true, SetObservable = true)
        Colours = 'kgbrm'
        X_Var_LUT
        Y_Var_LUT
        figHandle = [];
        lineHandle = [];
        legendHandle = [];
        Vars = [];
    end
    methods
        function Example()
            %%
            close all
            clear classes
            DATA = dataset( {rot90([1:5]),'Var1'}, ...
                            {rot90([1:5])*0.25,'Var2'}, ...
                            {rot90([1:5])*0.5,'Var3'});
            obj = plotDATASET('DATASET',DATA);
            ObjectInspector(obj)
        end
        function RUN(obj)
            if obj.newFig == true
                obj.figHandle = figure;
                obj.lineHandle = [];
                obj.legendHandle = [];
                obj.Vars = [];
            end
            if isempty(obj.figHandle)
                obj.figHandle = figure;
            end
            figure(obj.figHandle);
            hold on; 
            x = max(size(obj.Vars));
            h = plot(obj.DATASET.(obj.X_Var),obj.DATASET.(obj.Y_Var),[obj.Colours(x+1),'-'])
            if obj.newFig == true
                xlabel(obj.X_Var)
                ylabel(obj.Y_Var)
                obj.lineHandle = [];
                obj.lineHandle(1) = h;
                obj.Vars = [];
                obj.Vars{1} = obj.Y_Var;
            else
                ylabel('Param')
                x = max(size(obj.Vars));
                obj.Vars{x+1} = obj.Y_Var;
                if x > 1
                   obj.legendHandle = legend(obj.Vars);
                end
                if isempty(obj.legendHandle)
                    obj.legendHandle = legend(obj.Vars);
                else
                    set(obj.legendHandle,'String',obj.Vars);
                end
            end
        end
    end
    methods (Hidden = true)
        function obj = plotDATASET(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.X_Var_LUT = get(obj.DATASET,'VarNames')';
            obj.Y_Var_LUT = get(obj.DATASET,'VarNames')';
            obj.X_Var = obj.X_Var_LUT{1};
            obj.Y_Var = obj.Y_Var_LUT{2};
            obj.RUN();            
        end
    end
end