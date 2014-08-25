classdef LabImageGen < handle
    properties (SetObservable = true)
        a_Range = [-65:80]
        b_Range = [-65:100]
        L = 100;
        ValueSacrifice = true;
        IMAGE_OUT
    end
    methods
        function Example(obj)
             %%
             close all
             clear classes
             obj = LabImageGen();
             obj.RUN();
             ObjectInspector(obj)
        end
        function RUN(obj)
             %%
             clear image
             a = rot90(obj.a_Range,1);
             b = rot90(obj.b_Range,1);
             x = max(size(a));
             y = max(size(b));
             LUM = 9;
             for i = 1:x
                for j = 1:y
                    [R, G, B] = obj.lab2rgb( obj.L, a(i), b(j) );
                    MAX = max([R,G,B]);
                    if obj.ValueSacrifice == true
                        if MAX > 1
                            R_image(i,j) = R/MAX;
                            G_image(i,j) = G/MAX;
                            B_image(i,j) = B/MAX; 
                        else
                            R_image(i,j) = R;
                            G_image(i,j) = G;
                            B_image(i,j) = B;                            
                        end
                    else
                            R_image(i,j) = R;
                            G_image(i,j) = G;
                            B_image(i,j) = B;                           
                    end
                end
             end
             rot = 3;
             image(:,:,1) = rot90(R_image,rot);
             image(:,:,2) = rot90(G_image,rot);
             image(:,:,3) = rot90(B_image,rot);
             obj.IMAGE_OUT.image = image;
             obj.IMAGE_OUT.fsd = 1;
        end
    end
    methods (Hidden = true)
        function [R, G, B] = lab2rgb(obj, L, a, b)
            % function [R, G, B] = Lab2RGB(L, a, b)
            % Lab2RGB takes matrices corresponding to L, a, and b in CIELab space
            % and transforms them into RGB.  This transform is based on ITU-R 
            % Recommendation  BT.709 using the D65 white point reference.
            % and the error in transforming RGB -> Lab -> RGB is approximately
            % 10^-5.  By Mark Ruzon from C code by Yossi Rubner, 23 September 1997.
            % Updated for MATLAB 5 28 January 1998.
            % Fixed a bug in conversion back to uint8 9 September 1999.

            if (nargin == 1)
              b = L(:,:,3);
              a = L(:,:,2);
              L = L(:,:,1);
            end

            % Thresholds
            T1 = 0.008856;
            T2 = 0.206893;

            [M, N] = size(L);
            s = M * N;
            L = reshape(L, 1, s);
            a = reshape(a, 1, s);
            b = reshape(b, 1, s);

            % Compute Y
            fY = ((L + 16) / 116) .^ 3;
            YT = fY > T1;
            fY = (~YT) .* (L / 903.3) + YT .* fY;
            Y = fY;

            % Alter fY slightly for further calculations
            fY = YT .* (fY .^ (1/3)) + (~YT) .* (7.787 .* fY + 16/116);

            % Compute X
            fX = a / 500 + fY;
            XT = fX > T2;
            X = (XT .* (fX .^ 3) + (~XT) .* ((fX - 16/116) / 7.787));

            % Compute Z
            fZ = fY - b / 200;
            ZT = fZ > T2;
            Z = (ZT .* (fZ .^ 3) + (~ZT) .* ((fZ - 16/116) / 7.787));

            X = X * 0.950456;
            Z = Z * 1.088754;

            MAT = [ 3.240479 -1.537150 -0.498535;
                   -0.969256  1.875992  0.041556;
                    0.055648 -0.204043  1.057311];

            RGB = max(min(MAT * [X; Y; Z], 1), 0);

            R = reshape(RGB(1,:), M, N) * 255;
            G = reshape(RGB(2,:), M, N) * 255;
            B = reshape(RGB(3,:), M, N) * 255; 

            if ((nargout == 1) | (nargout == 0))
              R = uint8(round(cat(3,R,G,B)));
            end
        end
        function obj = LabImageGen()
            
        end
    end
end