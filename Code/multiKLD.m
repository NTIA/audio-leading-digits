function K =  multiKLD(X,Refs)
%Finds Kullback-Leibler Divergence (KLD)[1] between one or more pairs of
%probability mass functions (pmfs).
%
%X is n by m and each column contains a length n pmf. X holds m pmfs.
%Refs is n by r and each column contains a length n pmf. R holds r pmfs.
%K is m by r and holds the KLDs between each pmf in X and each pmf in R.
% 
%The pmfs in Ref appear in the denominator of the KLD, so Ref cannot
%contain any zeros. i.e., k = sum( x(i) * log2(x(i)/r(i) )
%
%[1] Kullback and R. A. Leibler, “On Information and Sufficiency,” 
%The Annals of Mathematical Statistics, vol. 22, no. 1,
%pp. 79 – 86, 1951, https://doi.org/10.1214/aoms/1177729694.
%
%September 19, 2026 by S. Voran at Institute for Telecommunication Sciences
%in Boulder, Colorado, USA 

%check for matching pmf sizes in X and Refs, o.w. KLD is not defined
if size(X,1) ~= size(Refs,1)
    error('X and Refs must have the same number of rows.')
end

%check for zeros in Refs, o.w. KLD is not defined
if any(Refs==0,'all')
    error('Refs cannot contain any zeros')
end

for i=1:size(Refs,2) %loop over each pmf in Refs
    for j = 1:size(X,2) %loop over each pmf in X
        good = 0<X(:,j); %remove any zeros in the X pmf
        K(j,i) = X(:,j)'*log2(X(:,j)./Refs(:,i)); %calculate KLD
    end
end