function [asl, saf, active]=svp56appx(speech, fs)
%This code implements an approximation of the "Speech Voltmeter" given
%in ITU-T Rec. P.56, https://www.itu.int/rec/T-REC-P.56-201112-S
%This code often aligns variable names with the names used in P.56.
%These names are often not very descriptive, but alining with P.56
%was deemed more important than creating new variable names and thus 
%losing the alignment.
%
%speech is a column vector of speech samples with values in the +/- 2^15 range
%fs is the sample rate in smp/sec
%
%als is active speech level
%saf is speech activity factor
%active is a column vector of zeros and ones, size matches speech,
%   one indicates that a sample is active.
%
%September 10, 2026 by S. Voran at Institute for Telecommunication Sciences
%in Boulder, Colorado, USA 

speech = speech - mean(speech); %remove mean of speech signal
sq=sum(speech.^2); %find total power

if sq==0 %If speech signal is empty, force results to set values and return
   warning('No signal into svp56_fast')
   asl = nan;
   saf = 0;
   active = zeros(size(speech));
   return
end

%Useful constants
n=length(speech); %number of samples in speech signal
r=2^15;             %max value of 16 bit speech signal
g=exp(-1/(fs*.03)); %constant for smoothing envelopes
c=2.^[0:15]'; %vector of powers of two
a=zeros(16,1); %vector of zeros
hs=round(.2*fs); %integer near 20% of sample rate

speech=abs(speech); %rectify speech 
%apply smoothing filter to rectified speech to create speech envelope
speechEnv=filter( (1-g)^2, [1 -2*g g*g], speech); 

%sv add notes as possible from here on down
good=find(0<speechEnv);
lq=-100*ones(size(speechEnv));
%these 3 lines protect against log2(0), defining it to be log2(0)=-100;
lq(good)=floor(log2(speechEnv(good)));  
%lq is a log version of the envelope, and has only integer values
for i=1:16
    %this is a mask and it is created at each level 1 to 16
    active=( (i-1) <=lq); 
     %trans tells mask changes state off-to-on or on-to-off
    trans=find(abs(diff(active)));
	for j=1:length(trans) %this loop extends activity (hangover time)
        active(trans(j):min(trans(j)+hs-1,n))=1;
	end
    a(i)=sum(active);
end
%now a holds the number of active samples at each of the 16 levels

%and this variable gives the speech activity factor that each of the 16 
%masks produces
activityFactorsFromMasks = a./n;

L=10*log10(sq/n)-20*log10(r); %calculate required constants
c=20*log10(c)-20*log10(r);
A=zeros(size(c));

%Step through thresholds to find Afinal (which becomes ASL) and also
%determines SAF.
%Algorithm follows the steps given in Process 2 of Section 
%8.2 "Details of realization" in ITU-T Rec. P.56
for i=1:16
   if a(i)>0
      A(i)=10*log10(sq./a(i))-20*log10(r);
   else
      A(i)=200;
   end
end

d=A-c;
for i=1:15
   if d(i)>=15.9 & d(i+1)<=15.9
      if d(i)-d(i+1)==0
         Afinal=A(i);
      else
         s=(d(i)-15.9)/(d(i)-d(i+1));
         Afinal=(1-s)*A(i)+s*A(i+1);
      end 
   end
   if exist('Afinal')~=1
      Afinal=0;
   end
end

%find saf and asl from Afinal and L
saf=10^((L-Afinal)/10);
asl=Afinal;

%This code block picks the mask that gives an SAF closest to the 
%SAF calculated above (There are 16 possible masks, corresponding to 
%16 different threshold levels)
[dud,loc]=min(abs(activityFactorsFromMasks-saf)); %find location of best mask

%regenerate that mask
active=( loc-1 <=lq); %loc-1 is the threshold for generating the activity mask
trans=find(abs(diff(active)));
for j=1:length(trans)
     active(trans(j):min(trans(j)+hs-1,n))=1;
end