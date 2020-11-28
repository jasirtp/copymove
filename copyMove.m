clear; clc;
tic
%%The path with the images must be updated before it can be run.
img = imread('PATH\forged1.png');
imgMask = imread('PATH\forged1_maske.png');
gray = rgb2gray(img);
gray2 = zeros(size(gray,1), size(gray,2));
grayMask = rgb2gray(imgMask);
EN = size(gray,1);
BOY = size(gray,2);
matris = zeros((EN-7)*(BOY-7),18);  %%Matrix holding quantified values and coordinates
mBenzerlik = [];            %%Matrix holding the starting addresses of similar blocks and their shift vectors

f = 1;
for i = 1:EN-7                       %%line  y
    for j = 1:BOY-7                   %%column  x
            block = gray(i:(i+7), j:(j+7));
            dctImg = dct2(block);           %%Discrete cosine transform (conversion to frequency domanine)
            tarama = zigzag(dctImg);
            tarama = tarama(1:16);          %%16 element vector obtained

            quantalama = floor(tarama/88);  %%The quantization value of 88 for compressed images needs to be changed.
.
            
            for k = 1:16
                matris(f,k)= quantalama(k);
            end
            matris(f,17) = i;
            matris(f,18) = j;
            f = f + 1;     
    end
    
end

sonuc = sortrows(matris);


for i = 1: (EN-7)*(BOY-7)-10
    for j = 1:10
        %% Compared to 10 vectors after it
        if oklid(sonuc(i,1:16),sonuc(i+j,1:16)) ==0 %%If the blocks are similar
 
             
            if oklid(sonuc(i,17:18),sonuc(i+j,17:18))> 91 %%minimum distance of pixels
                
                 mBenzerlik =[mBenzerlik; [ sonuc(i,17:18) sonuc(i+j,17:18) sonuc(i+j,17)-sonuc(i,17) sonuc(i+j,18)-sonuc(i,18)]];
           
            end
            
        end
        
    end
    
end

%% Lexicographic ordering of shift vectors

 shiftVector = sortedShiftVector(mBenzerlik);
 
for i = 1:(size(shiftVector,1)-1)
    j = 1;
    
    %%Determining the number of similar shift vectors

    while(shiftVector(i,5)==shiftVector(i+j,5) && shiftVector(i,6)==shiftVector(i+j,6))
        
        j = j + 1;
        
    end
    %% The number of vectors with more than the threshold value
    %% painting block by block from the starting coordinates

    if j >100
        for k = 0:j-1
        gray2(shiftVector(i+k,1):shiftVector(i+k,1)+8,shiftVector(i+k,2):shiftVector(i+k,2)+8)=255;
        gray2(shiftVector(i+k,3):shiftVector(i+k,3)+8,shiftVector(i+k,4):shiftVector(i+k,4)+8)=255;
        end
    end
     i = i + j;

end
%% Displaying printouts on the screen

toc
[FM,recall,precision] = (getFmeasure(grayMask,gray2(1:EN,1:BOY)));
subplot(2,2,1), imshow(img);
title('Orjinal Resim');
subplot(2,2,2), imshow(gray2);
title('Tespit Edilen Sahte Pikseller');
subplot(2,2,3), imshow(grayMask);
title(FM);
