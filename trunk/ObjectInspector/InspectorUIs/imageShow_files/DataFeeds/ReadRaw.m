classdef ReadRaw < handle
    properties (SetObservable = true)
        FileName = 'R:\AWB_variation\JAVA_AWB_Raw.raw'
        SizeY = 1944  %imx105-2464  imx175-2448
        SizeX = 3264  %imx105-3280  imx175-3264
        Stride = 4096 %imx105-4128  imx175-4096
        Stretch2_16Bit = true; %10bits stretch into 16 bit space. 
        HeaderPresent = true
        imageOUT = imageCLASS;
        Mode = 'BRCM10';
    end
    properties (Hidden = true, SetObservable = true)  
        Header
        Mode_LUT = {'BRCM10'; ...
                    'BRCM16'; ...
                    'OV'};
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            %%
            obj = ReadRaw;
            obj.RUN;
            ObjectInspector(obj)
            
            %%
            obj.SizeX = 2624;
            obj.RUN
            imshow(obj.imageOUT)
            
            %%
            imageShow('imageIN',obj.BayerImage)
        end
        function RUN(obj)
            disp(['FileName: ',obj.FileName]);
            obj.imageOUT = []; %Save memory
            if strcmpi(obj.Mode,'BRCM10')
                [Img, obj.Header] = ReadRaw10Bit(obj.FileName, obj.SizeY, obj.SizeX, obj.Stride, obj.HeaderPresent);
            elseif strcmpi(obj.Mode,'BRCM16')
                [Img, obj.Header] = ReadRaw16Bit(obj.FileName, obj.SizeY, obj.SizeX, obj.Stride, obj.HeaderPresent);
                Img = obj.ReadRawOV(obj.FileName,obj.SizeY,obj.SizeX, obj.HeaderPresent);
            end
            if obj.Stretch2_16Bit == true
            obj.imageOUT = Img.*2^6;
            else
            obj.imageOUT = Img;    
            end
        end
    end
    methods (Hidden = true)
        function obj = ReadRaw(varargin)
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end     
        end
        function out = ReadRawOV(obj,FileName,SizeY,SizeX,HeaderPresent)
            fid = fopen( obj.FileName, 'rb' );
            [Header] = obj.RemoveHeader(fid,HeaderPresent);
            Img1 = fread( fid, 'uint8' )'; 
            LSB_img = Img1(1:2:end);
            MSB_img = Img1(2:2:end);
            image = MSB_img.*256 + LSB_img;
            
            %%
            [x,y] = size(image);
            X = SizeX;
            Y = floor(y/X);
            total = X*Y;
            out = reshape(image(1:total),X,Y)';          
        end
        function [Header] = RemoveHeader(obj,fid,HeaderPresent)
            if(HeaderPresent == 1 )
                fseek( fid, 8, 'bof' );
                HeaderSize = fread( fid, 1, 'uint16' )+4;
                fseek( fid, 0, 'bof' );
                Header = fread( fid, HeaderSize, 'uint8' );
            else
                Header = 0;
            end            
        end
    end
end