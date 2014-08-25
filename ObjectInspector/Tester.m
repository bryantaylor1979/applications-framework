%%
close all
clear classes
imagesList(1).Path = 'C:\tuning\imx175\output\AL_HW_GED\001-Baffin-BRCM_20120203_040821.jpg';
imageData = [];
resultBool = ImageCustomViewerMatlab( imagesList, imageData )