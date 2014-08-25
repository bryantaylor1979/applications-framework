classdef HSV_Viewer <    handle & ...
                        FeederObject
    % this is the wrapper for the custom viewer. 
    
    properties (SetObservable = true)
        Visible
        Type
        imageIN
        Energies
        Plot
    end
    properties (Hidden = true, SetObservable = true)
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            im = ReadImage;
            obj = HSV_viewer('InputObject',im);
%             im.RUN();
            ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            Energies(1) = mean2(obj.imageIN.image(:,:,1));
            Energies(2) = mean2(obj.imageIN.image(:,:,2));
            Energies(3) = mean2(obj.imageIN.image(:,:,3));   
            %%
            if strcmpi(class(obj.imageIN.image),'double')
                obj.Plot.Color = Energies;
            else
                obj.Plot.Color = round(Energies)/256;
            end
            
            %% 
            obj.Energies = round(Energies);
            obj.Plot.RUN;
        end
    end
    methods (Hidden = true)
        function obj = HSV_Viewer(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end  
            
            %%
            if obj.Visible == true
                obj.Plot = HuePlot( 'SpecIsVisible',    'off', ...
                                    'Visible',           true);
            else
                obj.Plot = HuePlot( 'SpecIsVisible',    'off', ...
                                    'Visible',           false);               
            end                
            obj.Plot.RUN; 
            obj.ClassType = 'box';  %box - operates from box selection
                                    %image - operates from whole image
                                    %macbeth - operates from macbeth chart
                                    %line - operates from line. 
            obj.LinkObjects;
            obj.handles = obj.Plot.handles;
            obj.addlistener(    'Visible',  'PostSet', @obj.updateVisible);
        end
        function updateVisible(varargin)
            obj = varargin{1};
            if obj.Visible == true
                obj.Plot.Visible = true;
            else
                obj.Plot.Visible = false;
            end
        end
    end
end
    