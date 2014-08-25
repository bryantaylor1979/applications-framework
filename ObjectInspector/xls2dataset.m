        function DATASET = xls2dataset(filename)
            [num,text,raw] = xlsread(filename);
            ColumnNames = raw(1,:);
            x = size(ColumnNames,2);
            raw = raw(2:end,:);
            DATASET = dataset();
            for i = 1:x
                name = ColumnNames{i};
                col1 = raw(:,i);
                try
                NumData = cell2mat(col1);
                DATASET = [DATASET,dataset({NumData,name})];
                catch
                DATASET = [DATASET,dataset({col1,name})];
                end
            end            
        end
