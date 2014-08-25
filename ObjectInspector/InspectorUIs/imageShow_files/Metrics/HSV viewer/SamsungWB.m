classdef SamsungWB <    handle & ...
                        FeederObject
    % this is the wrapper for the custom viewer. 
    
    properties (SetObservable = true)
        Visible
        Type
        imageIN
        Energies
        Spec
        Plot
    end
    properties (Hidden = true, SetObservable = true)
        Spec_LUT
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            files = '//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Cloudy_IMG_20140513_170349.jpg';
            im = imageShow(     'ImageName',    files);
            
            %%
            obj = SamsungWB(    'InputObject',  im);
%             im.RUN();
            ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            Energies(1) = mean2(obj.imageIN.image(:,:,1));
            Energies(2) = mean2(obj.imageIN.image(:,:,2));
            Energies(3) = mean2(obj.imageIN.image(:,:,3));   
            obj.Plot.Color = round(Energies)/256;
            obj.Energies = round(Energies);
            obj.Plot.Spec = obj.Spec;
            obj.Plot.RUN;
            ObjectToolbar(obj);
            
            obj.addlistener(    'Spec', 'PostSet', @obj.UpdateSpec)
        end
    end
    methods (Hidden = true)
        function UpdateSpec(varargin)
            %%
            obj = varargin{1};
            obj.Plot.Spec = obj.Spec;
        end
        function obj = SamsungWB(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end  
            
            %%
            obj.Plot = HuePlot( 'FigureName',   'Samsung White Balance');
            obj.Spec_LUT = obj.Plot.Spec_LUT;
            obj.Spec = obj.Plot.Spec;
            obj.Plot.RUN; 
            obj.ClassType = obj.Type;  %box - operates from box selection
                                       %image - operates from whole image
                                       %macbeth - operates from macbeth chart
                                       %line - operates from line. 
            obj.LinkObjects;
            obj.handles = obj.Plot.handles;
            
            obj.addlistener(    'Visible', 'PostSet', @obj.MakeVisible)
        end
        function obj = MakeVisible(varargin)
            %%
            obj = varargin{1};
            obj.Plot.Visible = obj.Visible;
        end
    end
end
    