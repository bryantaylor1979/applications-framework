function result = plotSFR ( id, path, image_base )

%imx105_v2_3280x2464_413_std_sh_v6_resp1_only_0.bmp
    filename = strcat(path, '\', image_base, '_', id, '_0.bmp');
    A = exist(filename,'file');
    if (A == 0)
        filename = strcat('e:\DCIM\brcm2763\imx105_v2_3280x2464_', id, '.jpg');
        A = exist(filename,'file');
        if (A==0)
            errormsg = strcat('File ', filename, ' does not exist')
        else
            result = MicaUI( filename, 'Sharpen');
        end
    else
        result = MicaUI( filename, 'Sharpen');
    end
end
