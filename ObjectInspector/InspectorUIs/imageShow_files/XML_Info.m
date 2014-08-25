classdef XML_Info < handle
    properties (SetObservable = true)
        xml_file_found = 'TRUE';
        greycords_x = 58;
        greycords_y = 59;
        greycords_width = 60;
        greycords_height = 61;
        Width = 150;
        Height = 110;
        PositionFromBottom = 37;
        Visible = true;
    end
    properties (Hidden = true)
        handles
    end
    methods (Hidden = true)
        function Example(obj)
           %%
           close all
           clear classes
           
           %% Use Samsung Metric - Unix
           files = {   '//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Macbeth_Shadow_IMG_20140513_153612.jpg'; ...
                        '//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Macbeth_Cloudy_IMG_20140513_170407.jpg'; ...
                        '//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Cloudy_IMG_20140513_170349.jpg'};
                    
           xml_file = {'//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Macbeth_Shadow_IMG_20140513_153612.xml'; ...
                       '//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Macbeth_Cloudy_IMG_20140513_170407.xml'; ...
                       '//projects/IQ_tuning_data/sensors/Sony/imx175/Grass_Images/imx175_Cloudy_IMG_20140513_170349.xml'};
                    
           obj = imageShow(   'ImageName',     files, ...
                               'XmlName',      xml_file, ...
                               'CustomerMetric_Enable', 'on'); 
                           
                           %%
            delete(XML_OBJ)               
           %%
           delete(XML_OBJ)
           
           %%
           XML_OBJ = XML_Info(  'Width',150, ...
                                'Height',110, ...
                                'PositionFromBottom',37)  
           
           %%
           XML_OBJ.xml_file_found = 'FALSE';
           
           %%
           XML_OBJ.greycords_height = 34;
           
           %%
           XML_OBJ.Visible = true
        end
        function obj = XML_Info(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            obj.handles.jLabel = javax.swing.JLabel('Java Label')
            [jhlabel,jContainer]=javacomponent(obj.handles.jLabel, [0,obj.PositionFromBottom,obj.Width,obj.Height], gcf);
            obj.handles.jContainer = jContainer;
            BG = 0.7;
            set(jhlabel,'Background',javax.swing.plaf.ColorUIResource(BG,BG,BG))
            set(jhlabel,'Foreground',javax.swing.plaf.ColorUIResource(0.0,0.0,1))
            set(jhlabel,'Text', [   '<html>XML Info: ', ...
                                    '<br>xml_file_found: ',     obj.xml_file_found, ...
                                    '<br>greycords.x: ',        num2str(obj.greycords_x), ...
                                    '<br>greycords.y: ',        num2str(obj.greycords_y), ...
                                    '<br>greycords.width: ',    num2str(obj.greycords_width), ...
                                    '<br>greycords.height: ',   num2str(obj.greycords_height), ...
                                    '</html>'] )
            stringNames = { 'xml_file_found', ...
                            'greycords_x', ...
                            'greycords_y', ...
                            'greycords_width', ...
                            'greycords_height'};
            obj.addlistener(  stringNames,       'PostSet',  @obj.UpdateString);
            obj.addlistener(  'Visible',       'PostSet',  @obj.UpdateVisible);
        end
        function delete(obj)
            delete(obj.handles.jContainer)
        end
        function UpdateVisible(varargin)
            obj = varargin{1};
            if obj.Visible == true
            set(obj.handles.jContainer,'Visible','on');
            else
            set(obj.handles.jContainer,'Visible','off');  
            end
        end
        function UpdateString(varargin)
            obj = varargin{1};
            set(obj.handles.jLabel,'Text', [   '<html>XML Info: ', ...
                                    '<br>xml_file_found: ',     obj.xml_file_found, ...
                                    '<br>greycords.x: ',        num2str(obj.greycords_x), ...
                                    '<br>greycords.y: ',        num2str(obj.greycords_y), ...
                                    '<br>greycords.width: ',    num2str(obj.greycords_width), ...
                                    '<br>greycords.height: ',   num2str(obj.greycords_height), ...
                                    '</html>'] )
        end
    end
end