classdef BlackBodyGen < handle
    properties (SetObservable = true)
        CT = 2500;
        WavelengthRange = [380,650];
        WavelengthStep = 10;
        lam=380:10:700; 
        RGB
        PlotSpectrum = false;
        ImageOUT
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes

            %%
            obj = BlackBodyGen();
            obj.RUN();
            ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            lam = [obj.WavelengthRange(1):obj.WavelengthStep:obj.WavelengthRange(2)]; 
            spectrum = blackbody(obj.CT,lam);
            
            if obj.PlotSpectrum == true
                figure, plot(lam,spectrum); 
                xlabel('Wavelength(nm)'); 
                ylabel('Emittance'); 
            end

            rgb = roo2disp(spectrum , lam);
            obj.RGB = rgb;
            image(1:100,1:100,1) = rgb(1);
            image(1:100,1:100,2) = rgb(2);
            image(1:100,1:100,3) = rgb(3);
            obj.ImageOUT.image = image;
            obj.ImageOUT.fsd = 1;
            obj.ImageOUT.type = 'rgb';        
        end
    end
    methods (Hidden = true)
        function obj = BlackBodyGen()
            %%
        end
    end
end