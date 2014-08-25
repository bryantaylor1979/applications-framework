classdef ReadLog_LensShadingTables <  handle 
    properties (SetObservable = true)
        Path = 'P:\imx175\sessions\imx175\Labels\Sim - Automatic\';
        filename = 'imx175_Baffin-Photoshoot1_2_LABEL_Sim - Automatic.sim_log.txt';
        r_gain_DATASET = dataset();
        gr_gain_DATASET = dataset();
        gb_gain_DATASET = dataset();
        b_gain_DATASET = dataset();
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           obj = ReadLog_LensShadingTables;
           ObjectInspector(obj);

           %%
           path1 = 'P:\imx175\output\VersionsOnDatabase\TOT_BRCM_Sim_v1\';
           names = obj.GetImageNamesFromDir(path1,'_log.txt')          
           x = size(names,1);
           for i = 1:x
               filename = [path1,names{i}];
               raw = obj.ReadRawData(filename);
               tables = obj.ReadTables(raw);
               obj.writeTables(tables,strrep(filename,'_log.txt','_extracted_log.txt'));
           end
        end
        function RUN(obj)
           %%
           raw = obj.ReadRawData(fullfile(obj.Path,obj.filename));
           obj.ReadTables(raw);         
        end
    end
    methods (Hidden = true)
        function obj = ReadLog_LensShadingTables()
        end
        function writeTables(obj,tables,filename)
            %%
            fid = fopen(filename,'w')
            obj.writeTable(fid,tables.r_gain,'cv_r0')
            obj.writeTable(fid,tables.gr_gain,'cv_gr0')
            obj.writeTable(fid,tables.gb_gain,'cv_gb0')
            obj.writeTable(fid,tables.b_gain,'cv_b0')
            fclose(fid)            
        end
        function tables = ReadTables(obj,raw,SIZE)
           x = find(strcmpi(raw,'LS ls_header: #r_gain'));
           c = find(strcmpi(raw,'LS ls_header: #gr_gain'));
           SIZE = c(1) - x(1) - 1;
           obj.r_gain_DATASET = obj.ReadTable(raw,'r_gain',SIZE);
           obj.gr_gain_DATASET = obj.ReadTable(raw,'gr_gain',SIZE);
           obj.gb_gain_DATASET = obj.ReadTable(raw,'gb_gain',SIZE);
           obj.b_gain_DATASET = obj.ReadTable(raw,'b_gain',SIZE);            
        end
        function DATASET = ReadTable(obj,raw,name,SIZE)
            %%
            prefix_string = ['LS ls_header: #',name];
            n = find(strcmpi(raw,prefix_string));
            n = n(1);
            for i = 1:SIZE
                string = ['[',strrep(raw{n+i},'LS ls_header:',''),']'];
                row = eval(string);
                if i == 1
                    ls_table = row;
                else
                    ls_table = [ls_table;row];
                end
            end 
            x = size(ls_table,2);
            for i = 1:x
                if i == 1
                    DATASET = dataset({ls_table(:,i),['c',num2str(i)]});
                else
                    DATASET = [DATASET,dataset({ls_table(:,i),['c',num2str(i)]})];
                end
            end
        end
        function raw = ReadRawData(obj,filename)
            try
            [raw] = textread( filename, '%s', ...
                                'delimiter','\n', ...
                                'whitespace',''); % read map   
            catch
                error(['file not found: ',filename])
            end
        end  
    end
end