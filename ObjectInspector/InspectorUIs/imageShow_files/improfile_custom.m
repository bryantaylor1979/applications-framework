classdef improfile_custom < handle
    properties (SetObservable = true)
        Enable = true;
        imageIN
        imageOUT_line
        line_OBJ
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
            line_OBJ = imLine(gcf,cpm_OBJ);
            
            %%
            obj = improfile_custom(line_OBJ, im_OBJ.imageOUT);
            
            %%
            ObjectInspector(obj)
        end
    end
    methods (Hidden = true)
        function obj = improfile_custom(line_OBJ,imageIN)
            %%
            obj.line_OBJ = line_OBJ;
            obj.imageIN = imageIN;
            obj.line_OBJ.addlistener('State','PostSet',@obj.Update);
        end
        function Update(varargin)
            obj = varargin{1};
            obj.line_OBJ.Enable = obj.Enable;
            if obj.Enable == true
                if strcmpi(obj.line_OBJ.State,'Ready')
                    if isempty(obj.line_OBJ.BoxDim)

                    else
                        drawnow
                        pause(0.1)
                        XDIM = round([obj.line_OBJ.StartPos(1),obj.line_OBJ.EndPos(1)]);
                        YDIM = round([obj.line_OBJ.StartPos(2),obj.line_OBJ.EndPos(2)]);
                        
                        image = improfile(obj.imageIN.image, [min(XDIM),max(XDIM)], [min(YDIM),max(YDIM)] );

                        imageOUT_line.image = image;
                        switch class(image)
                            case 'uint8'
                                imageOUT_line.fsd = 255;
                                imageOUT_line.type = 'rgb';
                            otherwise  
                        end
                        obj.imageOUT_line = imageOUT_line;
                    end
                end
            end
        end
    end
end