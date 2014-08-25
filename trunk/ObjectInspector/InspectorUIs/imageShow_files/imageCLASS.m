classdef imageCLASS < handle
    % This should save memory requirements.
    properties (SetObservable = true)
        image
        type = 'rgb';
        fsd = 255;
        bitdepth = 8;
        class = 'uint8';
    end
    properties (Hidden = true, SetObservable = true)
       type_LUT = { 'rgb'; ...
                    'raw'};
    end
    methods
        function Example(obj)
            %%
        end
        function RUN(obj)
            %%
        end
    end
end