classdef Lab_viewer <   handle & ...
                        FeederObject
    properties (SetObservable = true)
        Visible
        Type = 'image';
        imageIN
        Energies
        Plot_OBJ
        Spec = '6500K';
        Lab = [NaN, NaN, NaN];
    end
    properties (Hidden = true, SetObservable = true)
        handles
        Spec_LUT = {    '6500K'; ...    
                        '4200K'; ...
                        '2800K'};
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            im = ReadImage( 'FileName', 'Z:\projects\IQ_tuning_data\bgentles\run\2014_Apr_01_07_52_28_e70ca2b\001-Baffin-BRCM_20120203_040821.bmp');
            im.RUN();
            ObjectInspector(im)
            obj = Lab_viewer('InputObject',im);
            obj.imageIN = im.imageOUT;
            obj.RUN();
            ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            Energies(1) = mean2(obj.imageIN.image(:,:,1));
            Energies(2) = mean2(obj.imageIN.image(:,:,2));
            Energies(3) = mean2(obj.imageIN.image(:,:,3));   
            
            %%
            if strcmpi(class(obj.imageIN.image),'double')
                obj.Plot_OBJ.RGB = Energies*255;
                obj.Energies = round(Energies*255);
            else
                obj.Plot_OBJ.RGB = round(Energies);
                obj.Energies = round(Energies);
            end
            
            %%
            obj.Plot_OBJ.Spec = obj.Spec;
            obj.Plot_OBJ.RUN();
            obj.Lab = obj.Plot_OBJ.Lab();
        end
    end
    methods (Hidden = true)
        function obj = Lab_viewer(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) =  varargin{i+1};
            end
            
            obj.Plot_OBJ = LabViewer('Visible',obj.Visible);
            obj.Plot_OBJ.RUN; 
            obj.ClassType = obj.Type;  %box - operates from box selection
                                       %image - operates from whole image
                                       %macbeth - operates from macbeth chart
                                       %line - operates from line. 
            obj.LinkObjects;
            obj.handles = obj.Plot_OBJ.handle;
            obj.addlistener(    'Visible',  'PostSet', @obj.updateVisible);
        end
        function updateVisible(varargin)
            obj = varargin{1};
            if obj.Visible == true
                obj.Plot_OBJ.Visible = true;
            else
                obj.Plot_OBJ.Visible = false;
            end
        end
    end
end