classdef LensShadingViewer <  handle
    properties (SetObservable = true)
        Path = 'P:\imx175\sessions\imx175\Labels\Sim - Automatic\';
        filename = 'imx175_Baffin-Photoshoot1_2_LABEL_Sim - Automatic.sim_log.txt';
        r_gain_DATASET = dataset();
        gr_gain_DATASET = dataset();
        gb_gain_DATASET = dataset();
        b_gain_DATASET = dataset();
        OBJ_Read
        OBJ_Plotter
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = LensShadingViewer;
            ObjectInspector(obj)
        end
        function RUN(obj)
            obj.OBJ_Read.Path = obj.Path;
            obj.OBJ_Read.filename = obj.filename;
            obj.OBJ_Read.RUN();
            obj.r_gain_DATASET = obj.OBJ_Read.r_gain_DATASET;
            obj.gr_gain_DATASET = obj.OBJ_Read.gr_gain_DATASET;
            obj.gb_gain_DATASET = obj.OBJ_Read.gb_gain_DATASET;
            obj.b_gain_DATASET = obj.OBJ_Read.b_gain_DATASET;
            
            obj.OBJ_Plotter = LensShadingViewer_Plotter(    'r_gain_DATASET', obj.r_gain_DATASET, ...
                                                            'gr_gain_DATASET',obj.gr_gain_DATASET, ...
                                                            'gb_gain_DATASET',obj.gb_gain_DATASET, ...
                                                            'b_gain_DATASET', obj.b_gain_DATASET);
        end
    end
    methods (Hidden = true)
        function obj = LensShadingViewer(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.OBJ_Read = ReadLog_LensShadingTables;
        end
    end
end