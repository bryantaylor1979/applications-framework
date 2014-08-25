classdef array2rle <  handle
    properties (SetObservable = true)
        imageIN
    end
    properties (Hidden = true)
    	RLE
    end
    methods
        function HTC_Mod(obj)
            %%
            close all
            clear classes
            obj = array2rle
            obj.imageIN = [   ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ... 
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ... 
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,13,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,109,170,136,66,18,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,54,217,253,248,227,167,68,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,98,243,254,254,254,251,201,45,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,119,248,255,255,255,254,240,87,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,126,250,255,255,255,255,248,121,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,127,250,255,255,255,255,252,161,11,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,125,250,255,255,255,255,253,190,23,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,103,244,254,255,255,255,254,220,49,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,47,206,252,254,255,255,254,239,90,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,77,195,250,254,255,255,251,160,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,59,201,251,254,255,253,190,23,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,67,176,245,254,245,139,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,37,170,240,176,36,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,37,101,45,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
            obj.RUN()
            ObjectInspector(obj)            
        end
        function Example(obj)
            %%
            close all
            clear classes
            obj = array2rle
            obj.RUN()
            obj.Log
            
        end
        function RUN(obj)
            [raster,indexs] = obj.raster_and_tile(obj.imageIN.image(:,:,1));
            [out1, out2, out3] = obj.RunLength_M(raster);
            x = size(out1,2)
            array(1:2:x*2) = out1;
            array(2:2:x*2) = out2;
            obj.RLE = array;
        end
        function Log(obj)
           %%
           x = size(obj.RLE,2);
           p = floor(x/32);
           s_str= ['   '];
           disp('tex_embedded_rle:')
           for i = 1:p
               start = (i-1)*32+1;
               end_ = i*32;
               ARRAY = obj.RLE(start:end_);
               n_str = sprintf('%d ',ARRAY(:));
               disp([s_str,n_str]);
           end
           ARRAY = obj.RLE(p*32+1:end);
           n_str = sprintf('%d ',ARRAY(:));
           disp([s_str,n_str]);
           disp(' ')
           disp(' ')
        end
    end
    methods (Hidden =  true)
        function [tformat,indexs] = raster_and_tile(obj, pixel)
            %%
             for b = 0:63
                for r = 0:63
                    index = obj.calc_index(r,b);
                    tformat(index+1) = pixel(end-b,r+1);
                    indexs(b+1,r+1) = index;
                end
            end
        end
        function index = calc_index(obj, r, b)
            tile_col = 0;
            tile_row = floor(b / 64);
            tile_n = tile_row * 4 + tile_col;

            %%
            if r >= 32
                subtile_col = 1;
            else
                subtile_col = 0;
            end
            if xor(b >= 32, r >= 32)
                subtile_row = 1;
            else
                subtile_row = 0;
            end
            subtile_n = subtile_row + subtile_col * 2;

            %% Look at the bottom 32 bit only
            microtile_col = floor(rem(r,32)/8);
            microtile_row = floor(rem(b,32)/8);

            %%
            microtile_n = microtile_row * 4 + microtile_col;

            %%
            pixel_col = rem(r,8);
            pixel_row = rem(b,8);
            %%
            pixel_n = pixel_row * 8 + pixel_col;
            index = tile_n * hex2dec('1000') + subtile_n * hex2dec('400') + microtile_n * hex2dec('40') + pixel_n;
        end
        function obj = array2rle(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
        end
        function [out1, out2, out3] = RunLength_M(obj, in1)
            % RUNLENGTH_M - RLE coding as M-function for education
            % Run-length encoding splits a vector into one vector, which contains the
            % elements without neighboring repetitions, and a seconds vector, which
            % contains the number of repetitions.
            % This can reduce the memory for storing the data or allow to analyse sequences.
            %
            % This M-version is thought for educational purposes.
            % The vectorized methods are fairly efficient and they can be inserted in a
            % productive code, when the MEX cannot be used for any reasons.
            % The MEX function is 4 to 5 times faster and can create N as UINT8.
            %
            % Encoding: [B, N, IB] = RunLength(X)
            % Decoding: X          = RunLength(B, N)
            % INPUT / OUTPUT:
            %   X:  Full input signal, row or column vector.
            %       Types: (U)INT8/16/32/64, SINGLE, DOUBLE, LOGICAL, CHAR.
            %   B:  Compressed data, neighboring elements with the same value are removed.
            %       B and X have the same types.
            %   N:  Number of repetitions of the elements of B in X as DOUBLE or UINT8 row
            %       vector.
            %   IB: Indices of elements in B in X as DOUBLE row vector.
            %
            % NOTE: For more information and examples see RunLength.m.
            %
            % Tested: Matlab 6.5, 7.7, 7.8, 7.13, WinXP/32, Win7/64
            % Author: Jan Simon, Heidelberg, (C) 2013 matlab.THISYEAR(a)nMINUSsimon.de

            % $JRev: R-b V:001 Sum:+1m6/IytUqnr Date:12-Aug-2013 22:55:47 $
            % $License: NOT_RELEASED $
            % $File: Tools\GLMath\RunLength_M.m $
            % History:
            % 001: 15-Mar-2013 09:30, First version.

            % Initialize: ==================================================================
            % Global Interface: ------------------------------------------------------------
            % Initial values: --------------------------------------------------------------
            % Set to TRUE or FALSE manually to compare the speed:
            vectorized = true;
            %#ok<*UNRCH>  % Suppress MLint warnings about unreachable code

            % Program Interface: -----------------------------------------------------------
            % Check inputs:
            doEncode = true;

            % No cells, structs or objects:
            if ~(isnumeric(in1) || islogical(in1) || ischar(in1))
               error('JSimon:RunLength_M:BadTypeInput1', ...
                     '*** RunLength[m]: 1st input must be numeric, logical or char.');
            end

            % Fast return for empty inputs:
            if isempty(in1)
               out1 = in1([]);
               if nargout == 2
                  out2 = [];
               end
               return;
            end

            % Input must be a vector:
            [s1, s2] = size(in1);
            if ndims(in1) > 2 || (s1 ~= 1 && s2 ~= 1)
               error('JSimon:RunLength_M:BadShapeInput1', ...
                     '*** RunLength[m]: 1st input must be a row or column vector.');
            end

            % User Interface: --------------------------------------------------------------
            % Do the work: =================================================================
            if doEncode                       % Encoding: [x] -> [b, n] --------------------
               x = in1(:);

               if vectorized                  % Vectorized: --------------------------------
                  d = [true; diff(x) ~= 0];   % TRUE if values change
                  b = x(d);                   % Elements without repetitions
                  k = find([d', true]);       % Indices of changes
                  n = diff(k);                % Number of repetitions

                  if nargout == 3             % Reply indices of changes
                     out3 = k(1:length(k) - 1);
                  end

               else                           % Loop: --------------------------------------
                  len = length(x);            % Output must have <= len elements
                  b(len, 1) = x(1);           % Pre-allocate, dummy value to copy the class
                  n   = zeros(1, len);        % Pre-allocate
                  ib  = 1;                    % Cursor for output b
                  xi  = x(1);                 % Remember first value
                  ix  = 1;                    % Cursor for input x
                  for k = 2:len               % Compare from 2nd to last element
                     if x(k) ~= xi            % If value has changed
                        b(ib) = xi;           % Store value in output
                        n(ib) = k - ix;       % Store number of repetitions in output
                        ib    = ib + 1;       % Increase the output cursor
                        ix    = k;            % Initial index of the next run
                        xi    = x(k);         % Value of the next run
                     end
                  end
                  b(ib) = xi;                 % Flush last element
                  n(ib) = len - ix + 1;

                  b(ib + 1:len) = [];         % Crop unused elements in the output
                  n(ib + 1:len) = [];

                  if nargout == 3             % Reply indices of changes
                     out3 = cumsum([1, n(1:len - s1)]);
                  end
               end

               if s2 > 1                      % Output gets same orientation as input
                  b = b.';
               end
               out1 = b;
               out2 = n;

            else                              % Decoding: [b, n] -> [x] ====================
               b = in1(:);                    % More convenient names for inputs
               n = in2;

               if vectorized                  % Vectorized: --------------------------------
                  len   = length(n);          % Number of bins
                  d     = cumsum(n);          % Cummulated run lengths
                  index = zeros(1, d(len));   % Pre-allocate
                  index(d(1:len-1)+1) = 1;    % Get the indices where the value changes
                  index(1)            = 1;    % First element is treated as "changed" also
                  index = cumsum(index);      % Cummulated indices
                  x     = b(index);

               else                           % Loop: --------------------------------------
                  len      = sum(n);          % Length of the output
                  x(len,1) = b(1);            % Pre-allocate, dummy value to copy the class
                  i1       = 1;               % Start at first element
                  for k = 1:length(n)         % Loop over all elements of the input
                     i2         = i1 + n(k);  % Start of next run
                     x(i1:i2-1) = b(k);       % Repeated values
                     i1         = i2;         % Set current start to start of next run
                  end
               end

               if s2 > 1                      % Output gets same orientation as input
                  x = x.';
               end
               out1 = x;
            end
        end
    end
end