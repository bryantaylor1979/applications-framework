classdef ParseHeader < handle
    properties (SetObservable = true)
        Path = 'C:\Users\bryant\Desktop\Purple Cast Luffy\';
        FileName = 'IMAG0133.raw';
        Suffix = '_out2';
        Header
        version
        verison_used
        offset
        exposure
        analogue_gain
        aperture
        stride
        width
        height
        bayer_order
        camera_cal_valid
        sensor_valid
        gain_r
        gain_b
        sens_r
        sens_g
        sens_b
        canon_r
        canon_g
        canon_b
    end
    properties (Hidden = true)
        Ver={
            {'Header'}        {'UInt'}       {32}
            {'version'}       {'UInt'}       {32}
            {'offset'}        {'UInt'}       {32}
            };

        Ver104={
            {'string_id'}     {'Char'}       {128}
            {'exposure'}      {'Uint'}       {32}
            {'analogue_gain'} {'UInt'}       {16}
            {'aperture'}      {'UInt'}       {16}
            {'temp1'}         {'Byte'}       {8}
            {'stride'}        {'UInt'}       {16}
            {'temp2'}         {'Byte'}       {34}
            {'width'}         {'UInt'}       {16}
            {'height'}        {'UInt'}       {16}
            {'temp3'}         {'Byte'}       {32}
            {'bayer_order'}   {'Byte'}       {1}
            };

        Ver105={
            {'temp1'}         {'UInt'}       {32}
            {'string_id'}     {'Char'}       {128}
            {'exposure'}      {'UInt'}       {32}
            {'analogue_gain'} {'UInt'}       {16}
            {'aperture'}      {'UInt'}       {16}
            {'temp2'}         {'Byte'}       {8}
            {'stride'}        {'UInt'}       {16}
            {'temp3'}         {'Byte'}       {14}
            {'name'}          {'Char'}       {32}
            {'width'}         {'UInt'}       {16}
            {'height'}        {'UInt'}       {16}
            {'temp4'}         {'Byte'}       {32}
            {'bayer_order'}   {'Byte'}       {1}
            {'temp5'}         {'Byte'}       {142}
            {'temp6'}         {'Byte'}       {13}
            {'camera_cal_valid'} {'UInt'}    {32}
            {'temp_capture'}  {'Byte'}       {24}
            {'sensor_valid'}  {'UInt'}       {32}
            {'gain_r'}        {'UInt'}       {32}
            {'gain_b'}        {'UInt'}       {32}
            {'temp7'}         {'Byte'}       {24}
            {'temp_ls'}       {'Byte'}       {606}
            {'bl_red'}        {'UInt'}       {32}
            {'bl_gr'}         {'UInt'}       {32}
            {'bl_gb'}         {'UInt'}       {32}
            {'bl_blue'}       {'UInt'}       {32}
            }; 
        Ver111={
            {'temp1'}         {'UInt'}       {32}
            {'string_id'}     {'Char'}       {128}
            {'exposure'}      {'UInt'}       {32}
            {'analogue_gain'} {'UInt'}       {16}
            {'aperture'}      {'UInt'}       {16}
            {'temp2'}         {'Byte'}       {8}
            {'stride'}        {'UInt'}       {16}
            {'temp3'}         {'Byte'}       {14}
            {'name'}          {'Char'}       {32}
            {'width'}         {'UInt'}       {16}
            {'height'}        {'UInt'}       {16}
            {'temp4'}         {'Byte'}       {32}
            {'bayer_order'}   {'Byte'}       {1}
            {'temp5'}         {'Byte'}       {142}
            {'temp6'}         {'Byte'}       {13}
            {'camera_cal_valid'} {'UInt'}    {32}
            {'temp_capture'}  {'Byte'}       {24}
            {'sensor_valid'}  {'UInt'}       {32}
            {'temp7'}         {'UInt'}       {32}
            {'gain_r'}        {'UInt'}       {32}
            {'gain_b'}        {'UInt'}       {32}
            {'sens_r'}        {'UInt'}       {32}
            {'sens_g'}        {'UInt'}       {32}
            {'sens_b'}        {'UInt'}       {32}
            {'canon_r'}        {'UInt'}       {32}
            {'canon_g'}        {'UInt'}       {32}
            {'canon_b'}        {'UInt'}       {32}
            };
        P
        V
        Rest
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = ParseHeader;
%             obj.Path = 'C:\sourcecode\matlab\Programs\HeaderChanger';
%             obj.FileName = 'bring_up.raw';
            ObjectInspector(obj)
            
            %% example to run on unix
            close all
            clear classes
            %%
            Path = '/projects/IQ_tuning_data/sensors/Sony/imx175/2013-05-14_S4_Indoor_with_Baffin_Bayer/';
            FileName = '01_Baffin_MC4_bayer.raw';
            obj = ParseHeader(  'Path',     Path, ...
                                'FileName', FileName);
%             obj.Path = 'C:\sourcecode\matlab\Programs\HeaderChanger';
%             obj.FileName = 'bring_up.raw';
            ObjectInspector(obj)
            
            %% parse conical values
            close all
            clear classes
            Path = '/projects/IQ_tuning_data/sensors/Sony/imx175/2013-05-14_S4_Indoor_with_Baffin_Bayer/';
            FileName = '10_Baffin_MC4_bayer.raw';
            obj = ParseHeader(  'Path',     Path, ...
                                'FileName', FileName);
%             obj.Path = 'C:\sourcecode\matlab\Programs\HeaderChanger';
%             obj.FileName = 'bring_up.raw';
            obj.RUN_READ;
            ObjectInspector(obj)
        end
        function RUN_READ(obj)
            %%
            [SizeY, SizeX, Stride, Header] = obj.ReadProcess();
            
            %%
            obj.Header = Header.Ver.Header;
            obj.version = Header.Ver.version;
            obj.offset = Header.Ver.offset;
            obj.exposure = Header.Param.exposure;
            obj.analogue_gain = Header.Param.analogue_gain;
            obj.aperture = Header.Param.aperture;
         	obj.stride = Header.Param.stride;
            obj.width = Header.Param.width;
          	obj.height = Header.Param.height;
            obj.bayer_order = Header.Param.bayer_order;
            obj.camera_cal_valid = Header.Param.camera_cal_valid;
            obj.sensor_valid = Header.Param.sensor_valid;
            try
          	obj.gain_r = Header.Param.gain_r;
           	obj.gain_b = Header.Param.gain_b;
            end
            try
          	obj.bl_red = Header.Param.bl_red;
          	obj.bl_gr = Header.Param.bl_gr;
           	obj.bl_gb = Header.Param.bl_gb;
           	obj.bl_blue = Header.Param.bl_blue;
            end
            try
            obj.sens_r = Header.Param.sens_r;
            obj.sens_g = Header.Param.sens_g;
            obj.sens_b = Header.Param.sens_b;
            end
            try
            obj.canon_r = Header.Param.canon_r;
            obj.canon_g = Header.Param.canon_g;
            obj.canon_b = Header.Param.canon_b;
            end
        end
        function RUN_WRITE(obj)
           %%
           
           %V=obj.Parse(fid,obj.Ver);
           %P=obj.Parse(fid,obj.Ver111);
           
           %%
           obj.OverWriteP();
           [path,file,type] = fileparts(obj.FileName);
           filename = fullfile(obj.Path,[file,obj.Suffix,type]);
           fid = fopen( filename, 'wb' );
           obj.Write(fid,obj.Ver,obj.V);
           obj.Write(fid,obj.Ver111,obj.P);
           fwrite( fid, obj.Rest );
           fclose( fid );
        end
    end
    methods (Hidden = true)
        function obj = ParseHeader(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end    
%             obj.RUN_READ();
        end
        function A= Fread(obj,fid,Type,Size)
            switch char(Type)
                case 'Byte'
                    A = fread( fid, cell2mat(Size), 'uint8' );
                case {'UInt' 'Uint'}
                    A = fread( fid, 1, ['uint',num2str(cell2mat(Size))]);
                case 'Char'
                    A = fread( fid, cell2mat(Size), 'uint8' );
            end
        end
        function Fwrite(obj,fid,Type,A,Size)
            switch char(Type)
                case 'Byte'
                    fwrite( fid, A,'uint8'); 
                case {'UInt' 'Uint'}
                    fwrite( fid, A,['uint',num2str(cell2mat(Size))]); 
                case 'Char'
                    fwrite( fid, A,'uint8'); 
            end
        end
        function [SizeY, SizeX, Stride, Header] = ReadProcess(obj)
            File = [obj.Path,obj.FileName];
            SizeY=[];
            SizeX=[];
            Stride=[];
            Header=[];

            BRCM_ID = hex2dec('4D435242'); %/* 'BRCM' */

            %
            fid = fopen( File, 'rb' );
            V=obj.Parse(fid,obj.Ver);
            P=[];
            if V.Header==BRCM_ID
                if V.version ==104
                    obj.verison_used = 104;
                    P=obj.Parse(fid,obj.Ver104);
                elseif V.version == 105
                    obj.verison_used = 105;
                    P=obj.Parse(fid,obj.Ver105);
                else % verison 111
                    obj.verison_used = 111;
                    P=obj.Parse(fid,obj.Ver111);    
                end
                if ~isempty(P)
                    Header.Ver=V;
                    Header.Param=P;
                    SizeX=P.width;
                    SizeY=P.height;
                    Stride=P.stride;
                end
            end
            obj.P = P;
            obj.V = V;
            obj.Rest = fread(fid); %until the end
            fclose( fid );
        end
        function OverWriteP(obj)
           %%
           [x,y] = size(obj.Ver111)
           for i = 1:x
               Name = obj.Ver111{i,1}{1};
               try
               Val = obj.(Name);
               obj.P.(Name) = Val;
               end
           end
        end
    end
    methods (Hidden = true) %Multi write
        function A=Parse(obj,fid,S)
            for i=1:size(S,1)
                % S{i,1} name of the parameter
                % S{i,2} class e.g UInt
                % S{i,3}) number of bits
                A.(char(S{i,1}))=obj.Fread(fid,S{i,2},S{i,3});
            end
        end
        function Write(obj,fid,S,Vals)
            for i=1:size(S,1)
                Val = Vals.(char(S{i,1}))
                obj.Fwrite(fid,S{i,2},Val,S{i,3})
            end
        end
    end
end






