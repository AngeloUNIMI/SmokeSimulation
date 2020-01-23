function [res,cas] = prob(p)
%riceve in ingresso la matrice di probabilità e restituisce la casella scelta
%in base alla probabilità


%round probabilities 2 decimal place
p = floor(p*100)/100;
%p = p ./ sum(p(:));
%p = floor(p*100)/100;
%sum(p(:))
%pause
%create 100 element vector
vecP = zeros(100,1);


%indici bidimensionali convertiti in indici lineari
% 1,1 1,2 1,3
% 2,1 2,2 2,3
% 3,1 3,2 3,3
% ->
% 1  4  7
% 2  5  8
% 3  6  9

l=1; %indice vettore 100
il = 1; %indice lineare

for j=1:3,
	for i=1:3,
	%l:l+round(p(i,j)*100)-1
		vecP(l:l+round(p(i,j)*100)-1) = il;
		l = l+round(p(i,j)*100);
		il = il + 1;
	end,
end,


%la scelta della casella è fatta scegliendo un numero casuale da 1 a 100
randC = round(rand*100);
if (randC == 0),
randC = 1;
end,
cas = vecP(randC);
if (cas == 0),
cas = 1;
end,
%conversione indici lineari in subscript
[ic, jc] = ind2sub([3 3],(1:9)');
res = [ic(cas) jc(cas)];




