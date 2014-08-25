function resultBool = ImageCustomViewerMatlab( imagesList, imageData )
%An example matlab 
%
%     imageOUT = imageCLASS;
%     imageOUT.fsd = 255;
%     imageOUT.type = 'rgb';
%     imageOUT.bitdepth = 8;
%     imageOUT.image = imread(imagesList(1).Path);
%%
    x = size(imagesList,2);
    if x == 1
        IMAGES = imagesList.FileNames.Path;
    else
        for i = 1:x
            IMAGES{i,1} = imagesList(i).FileNames.Path;
        end
    end  
    
    %%
    obj = imageShow(    'Save_Visible',     false, ...
                        'Load_Visible',     true, ...
                        'ImageName',        IMAGES, ...
                        'Raw_Support',      false, ...
                        'PipeView_Enable',  false, ...
                        'Debug_Enable',     false, ...
                        'CustomerMetric_Enable', 'off');          
    resultBool = true;
end