clc
close all
clear variables

%path
addpath(genpath('./util/'));

%gen params
showS = 1;

%-------------------------------------------------
%video file
videoFile = './vids_base/video.mp4';
videoFileCheck = [videoFile(1:end-3) 'mat'];
frameStart = 1;
frameEnd = 100;

%-------------------------------------------------
%params
resizeV = 1;
thD = 0.1;
nSource = 5;
position1 = [200 120];
positionExt = 2;
sourceValue = 20;
imageRange = [0 ];
diffCoeff = [0.04 0.16 0.04; 0.16 0.32 0.16; 0.02 0.08 0.02]; %3x3 matrix
segmProb = [1 1 1; 1 1 1; 0 0 0]; %direzioni da considerare
p = rand(3,3) .* segmProb;
transProb = p ./ sum(p(:)); %3x3 matrix
%n of time steps after which transition probabilities are changed
timeStepChange = 5;
%number of frame after which drift is applied
nShiftE = 1;
%number of frame after which drift direction is changed
nShift = 1;
%total time steps
nTimeSteps = frameEnd-frameStart+1;
%drift multiply factor
driftMult = 1;
%SMOKE FUSION PARAMETERS
method = 1;
%method = 1 -> paper
smokeAddF = 5;
resizeSmoke = 0;
resF = 3;
thS = 0;

%-------------------------------------------------
%calcola la roba
obj = VideoReader(videoFile);
nFrames = obj.NumberOfFrames;
frameRate = obj.FrameRate;
frameRead = nFrames;
height = obj.Height;
width = obj.Width;

p = 1;
fprintf(1,'Number of Frames: %d\n\n',frameRead);

%for k = 1 : frameRead,
for k = frameStart : frameEnd
    if (resizeV)
        Ic(:,:,:,p) = imresize(read(obj, k),[240 320]);
    else
        Ic(:,:,:,p) = read(obj, k);
    end %end resizeV
    I(:,:,p) = rgb2gray(Ic(:,:,:,p));
    if (mod(k,10) == 0)
        fprintf(1,'%d... ',k);
    end
    if (mod(k,100) == 0)
        fprintf(1,'\n');
    end
    p = p + 1;
end


%aggiorniamo i frames
%frameRead = size(f,2);


fprintf(1,'\n');

savefile = videoFileCheck;
%salvala
%save(savefile, 'I','Ic', 'frameRead', 'height', 'width');


if(0)
    %limitazione I e Ic
    t = I(:,:,frameStart:frameEnd);
    I = t;
    t = Ic(:,:,:,frameStart:frameEnd);
    Ic = t;
end

clear obj


%-------------------------------------------------
dim1 = size(Ic,1) * 1;
dim2 = size(Ic,2) * 1;


%background creation
S = zeros(dim1,dim2,nTimeSteps);

%source assignment (basso)
%S(end-position(1)-nSource+1:end-position(1), end-position(2)-nSource+1:end-position(2),1) = sourceValue;

[res,cas] = prob(transProb);

for TS=1:nTimeSteps-1
    
    %-------------------------------------------------DRIFT
    
    
    %random change probabilities
    if (mod(TS,timeStepChange) == 0)
        p = rand(3,3).* segmProb;
        transProb = p ./ sum(p(:));
    end
    
    %cambiamo shift ogni n frame
    if (mod(TS,nShift) == 0)
        %scelta del random drift
        [res,cas] = prob(transProb);
    end
    
    %otteniamo i valori direttamente per la funzione circshift
    shiftV = res - 2;
    
    
    %effettuiamo lo shift ogni tot (gestione della velocità)
    if (mod(TS,nShiftE) == 0)
        %nuova immagine dopo drifting (shift LR)
        S(:,:,TS) = circshift(S(:,:,TS),[shiftV(1) shiftV(2)]);
        %I = circshift(I,[0 -1]);
        
        %non vogliamo le robe circolari
        %shift verso basso (primo elemento shiftV = 1) -> prima riga mettiamo a 0
        if (shiftV(1) > 0)
            S(1:driftMult,:,TS) = 0;
        end
        
        %shift verso alto (primo elemento shiftV = -1) -> ultima riga mettiamo a 0
        if (shiftV(1) < 0)
            S(end-driftMult:end,:,TS) = 0;
        end
        
        %shift verso destra (secondo elemento shiftV = 1) -> prima colonna mettiamo a 0
        if (shiftV(2) > 0)
            S(:,1:driftMult,TS) = 0;
        end
        
        %shift verso sinistra (secondo elemento shiftV = -1) -> ultima colonna mettiamo a 0
        if (shiftV(2) < 0)
            S(:,end-driftMult:end,TS) = 0;
        end
        
        
    end %end if shift ogni tot
    
    
    
    
    
    %-------------------------------------------------SOURCE ASSIGNMENT
    S(position1(1), position1(2):position1(2)+positionExt,TS) = sourceValue;
    %S(position(1), position(2)+positionExt+10:position(2)+positionExt+15,TS) = sourceValue;
    %S(position(1), position(2)+positionExt+25:position(2)+positionExt+30,TS) = sourceValue;
    
    
    %SMOOTHING?
    %h = fspecial('gauss',5,5);
    %S(:,:,TS) = imfilter(S(:,:,TS),h);
    
    
    
    %-------------------------------------------------DIFFUSION
    
    
    %Diffusion N.1
    for i=2:size(S,1)-1
        for j=2:size(S,2)-1
            if (S(i,j,TS) > thD)
                t = S(i,j,TS); %passo1
                S(i-1:i+1,j-1:j+1,TS) = S(i-1:i+1,j-1:j+1,TS) +    (  S(i,j,TS) .* diffCoeff(:,:)  );
                S(i,j,TS) = S(i,j,TS) - t; %passo2
                
                %Passo1 e Passo2 sono necessari per non aumentare la quantità esistente
                
            end %end if
        end %end for j
    end %end for i
    
    
    %Diffusion N.2
    for i=2:size(S,1)-1
        for j=2:size(S,2)-1
            if (S(i,j,TS) > thD)
                t = S(i,j,TS); %passo1
                S(i-1:i+1,j-1:j+1,TS) = S(i-1:i+1,j-1:j+1,TS) +    (  S(i,j,TS) .* diffCoeff(:,:)  );
                S(i,j,TS) = S(i,j,TS) - t; %passo2
                
                %Passo1 e Passo2 sono necessari per non aumentare la quantità esistente
                
            end %end if
        end %end for j
    end %end for i
    
    %Diffusion N.3
    for i=2:size(S,1)-1
        for j=2:size(S,2)-1
            if (S(i,j,TS) > thD)
                t = S(i,j,TS); %passo1
                S(i-1:i+1,j-1:j+1,TS) = S(i-1:i+1,j-1:j+1,TS) +    (  S(i,j,TS) .* diffCoeff(:,:)  );
                S(i,j,TS) = S(i,j,TS) - t; %passo2
                
                %Passo1 e Passo2 sono necessari per non aumentare la quantità esistente
                
            end %end if
        end %end for j
    end %end for i
    
    
    
    
    
    
    if (showS)
        fsfigure(1,0);
        imshow(S(:,:,TS),[0 max(S(:))])
        title(['N. Frame: ' num2str(TS)]);
        pause(0.02)
    end
    
    
    
    %salvo le modifiche nel frame successivo
    S(:,:,TS+1) = S(:,:,TS);
    
    
    
    if (mod(TS,10) == 0)
        fprintf(1,'%d... ',TS);
    end
    if (mod(TS,100) == 0)
        fprintf(1,'\n');
    end
    
    
end %end for timesteps
fprintf(1,'\n');



%-------------------------------------------------
if(0)
    S2 = uint8(zeros(size(Ic,1),size(Ic,2),nTimeSteps));
    %conversion
    for h=1:nTimeSteps
        maxS = max(max(S(:,:,h)));
        minS = min(min(S(:,:,h)));
        S2(:,:,h) = brackets(S(:,:,h),minS,maxS);
    end
end %end if(0)

%S2 = uint8(S);

if(1)
    S2 = uint8(zeros(size(Ic,1),size(Ic,2),nTimeSteps));
    %conversion
    maxS = max(S(:));
    minS = min(S(:));
    S2 = brackets(S,minS,maxS);
end %end if(0)


if(resizeSmoke)
    %resizing
    t = imresize(S2,[round(size(S2,1) / resF) round(size(S2,2) / resF)]);
    
    %positioning (indici di partenza riga e colonna)
    c1r = 120;
    c1c = 160;
    
    S2 = uint8(zeros(size(Ic,1),size(Ic,2),nTimeSteps));
    %boundary adjustment
    c2c = size(t,2)+c1c;
    c2r = size(t,1)+c1r;
    
    S2(c1r:c2r-1,c1c:c2c-1,:) = t(:,:,:);
end





%istanzio il video fuso
M = uint8(zeros(size(Ic,1),size(Ic,2),size(Ic,3),nTimeSteps));


for TS=1:nTimeSteps
    
    %1
    if(method == 1)
        for i=1:size(Ic,1)
            for j=1:size(Ic,2)
                
                if (S2(i,j,TS) > thD*255)
                    valRGB = (Ic(i,j,1,TS) + Ic(i,j,2,TS) + Ic(i,j,3,TS))   /  3;
                    %valS = S(i,j,TS)
                    if (S2(i,j,TS) > valRGB)
                        M(i,j,1,TS) = S2(i,j,TS);
                        M(i,j,2,TS) = S2(i,j,TS);
                        M(i,j,3,TS) = S2(i,j,TS);
                    else
                        M(i,j,:,TS) = Ic(i,j,:,TS);
                    end
                    
                else
                    M(i,j,:,TS) = Ic(i,j,:,TS);
                    
                    
                end
                
            end %end for j
        end %end for i
        
    end %end if(method == 1),
    
    %2
    if(method == 2)
        for i=1:size(Ic,1)
            for j=1:size(Ic,2)
                
                valRGB = (Ic(i,j,1,TS) + Ic(i,j,2,TS) + Ic(i,j,3,TS))   /  3;
                %valS = S(i,j,TS)
                M(i,j,1,TS) = Ic(i,j,1,TS) + round(S2(i,j,TS) / smokeAddF);
                M(i,j,2,TS) = Ic(i,j,2,TS) + round(S2(i,j,TS) / smokeAddF);
                M(i,j,3,TS) = Ic(i,j,3,TS) + round(S2(i,j,TS) / smokeAddF);
                
            end %end for j
        end %end for i
        
    end %end if(method == 2),
    
    
    
    
    
    
    if (mod(TS,10) == 0)
        fprintf(1,'%d... ',TS);
    end
    if (mod(TS,100) == 0)
        fprintf(1,'\n');
    end
    
    
    
    if (showS)
        fsfigure(1,0);
        imshow(M(:,:,:,TS))
        title(['N. Frame: ' num2str(TS)]);
        pause(0.02)
    end
    

end %end for TS


%-------------------------------------------------
v = VideoWriter('result.avi');
open(v);
writeVideo(v, M);
close(v);









