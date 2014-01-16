iptsetpref('UseIPPL',false);

original = imread('xvokra00.bmp');
originalDouble = im2double(original);
dimensions = size(original);
file = fopen('reseni.txt','w+');

% step1.bmp - zaostření obrazu - hotovo
step1matrix = [-0.5 -0.5 -0.5; -0.5 5.0 -0.5; -0.5 -0.5 -0.5];
step1 = imfilter(original, step1matrix);
imwrite(step1, 'step1.bmp');

% step2.bmp - otočení obrazu - hotovo
step2 = fliplr(step1);
imwrite(step2, 'step2.bmp');

% step3.bmp - mediánový filtr - hotovo
step3 = medfilt2(step2, [5 5]);
imwrite(step3, 'step3.bmp');

% step4.bmp - rozmazání obrazu - hotovo
step4matrix = [1 1 1 1 1; 1 3 3 3 1; 1 3 9 3 1; 1 3 3 3 1; 1 1 1 1 1]/49;
step4 = imfilter(step3, step4matrix);
step4double = im2double(step4);
imwrite(step4, 'step4.bmp');

% chyba v obraze
step4flipped = fliplr(step4);
step4flippedDouble = im2double(step4flipped);

noise=0;
for (x=1:dimensions(1, 1))
    for (y=1:dimensions(1, 2))
        noise=noise+abs(originalDouble(x,y)-step4flippedDouble(x,y));
    end;
end;
noise=noise/x/y*255;
fprintf(file, 'chyba=%f\n', noise);

% step5.bmp - roztažení histogramu
minValue = min(step4double(:));
maxValue = max(step4double(:));
step5 = imadjust(step4, [minValue maxValue], [0 1]);
step5double = double(step5);
imwrite(step5, 'step5.bmp');

% spočítání střední hodnoty a směrodatné odchylky - hotovo
res = mean2(step4);
fprintf(file, 'mean_no_hist=%f\n', res);

res = std2(step4);
fprintf(file, 'std_no_hist=%f\n', res);

res = mean2(step5);
fprintf(file, 'mean_hist=%f\n', res);

res = std2(step5);
fprintf(file, 'std_hist=%f\n', res);

% step6.bmp - kvantizace obrazu - hotovo
N = 2;
a = 0;
b = 255;
res = zeros(dimensions(1, 1), dimensions(1, 2));

for(i = 1:dimensions(1, 1))
    for(j = 1:dimensions(1, 2))
        step6(i, j) = round(((2^N)-1)*(step5double(i, j)-a)/(b-a))*(b-a)/((2^N)-1) + a;
    end;
end;

step6 = uint8(step6);
imwrite(step6, 'step6.bmp');

fclose(file);