classdef CropSelection < handle
    properties (SetObservable = true)
        Enable = true;
        imageIN
        imageOUT_cropped
        box_OBJ
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            im_OBJ = imageShow()
            
            %%
            try
            delete(box_OBJ)
            delete(cpm_OBJ)
            delete(obj)
            end
            cpm_OBJ = CurrentPostionMonitor(gcf);
            box_OBJ = imRect(gcf,cpm_OBJ);
            obj = CropSelection(box_OBJ, im_OBJ.imageOUT);
            
            %%
            ObjectInspector(obj)
        end
    end
    methods (Hidden = true)
        function obj = CropSelection(box_OBJ,imageIN)
            %%
            obj.box_OBJ = box_OBJ;
            obj.imageIN = imageIN;
            obj.box_OBJ.addlistener('State','PostSet',@obj.Update);
            obj.addlistener('imageIN','PostSet',@obj.Update);
        end
        function Update(varargin)
            obj = varargin{1};
            obj.box_OBJ.Enable = obj.Enable;
            if obj.Enable == true
                if strcmpi(obj.box_OBJ.State,'Ready')
                    if isempty(obj.box_OBJ.BoxDim)

                    else
                        drawnow;
                        pause(0.1);
                        XDIM = round([obj.box_OBJ.StartPos(1),obj.box_OBJ.EndPos(1)]);
                        YDIM = round([obj.box_OBJ.StartPos(2),obj.box_OBJ.EndPos(2)]);
                        image = obj.imageIN.image( min(YDIM):max(YDIM),min(XDIM):max(XDIM), :);
                        imageOUT_cropped.image = image;
                        try, imageOUT_cropped.fsd = obj.imageIN.fsd; end
                        try, imageOUT_cropped.type = obj.imageIN.type; end
                        try, imageOUT_cropped.bitdepth = obj.imageIN.bitdepth; end

                        obj.imageOUT_cropped = imageOUT_cropped;
                    end
                end
            end
        end
    end
end