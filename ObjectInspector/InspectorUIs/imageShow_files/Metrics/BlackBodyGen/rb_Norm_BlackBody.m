classdef rb_Norm_BlackBody < handle
    properties (SetObservable = true)
        CT_Range = [2000,10000]
        CT_Step = 100;
        DATASET
        bb_OBJ
    end
    methods
        function Example(obj)
            %%
            close all 
            clear classes
            obj = rb_Norm_BlackBody;
            obj.RUN();
            ObjectInspector(obj);
        end
        function RUN(obj)
            CT = [obj.CT_Range(1):obj.CT_Step:obj.CT_Range(2)];
            x = size(CT,2)
            for i = 1:x
                obj.bb_OBJ.CT = CT(i);
                obj.bb_OBJ.RUN;
                RGB = obj.bb_OBJ.RGB;
                CT_val(i,1) = CT(i);
                r_norm(i,1) = RGB(1)/sum(RGB);
                b_norm(i,1) = RGB(3)/sum(RGB);
            end
            obj.DATASET = dataset( {CT_val,'CT'}, {r_norm,'r_norm'}, {b_norm,'b_norm'} )
        end
    end
    methods (Hidden = true)
        function obj = rb_Norm_BlackBody()
            %%

            obj.bb_OBJ = BlackBodyGen()
        end
    end
end