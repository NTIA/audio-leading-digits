%This code does an experiment that is not in the paper.
%Many pairs of talkers in the TSP database cannot be distinguished using
%just KLDs to Benford and Gauss, but talkers 21 (aka FK) and 22 (aka FL)
%can be distinguished to some extent. The exact mechanism is presently
%unclear and is a topic for future study.  The two talkers have different
%spectral balance, so the first thing to investigate is if this plays into
%the leading digit distributions by some means.
%
%September 21, 2026 by S. Voran at Institute for Telecommunication Sciences
%in Boulder, Colorado, USA 

%It takes about 22 seconds for one platform to complete calculating
%the LDDD arrays Dtalker21 and Dtalker22

frameDur = 512; %frame duration in ms
maxSmp = 512*48; %convert to number of samples per frame
rng(0) %seed pseudo-random number generator for reproducibility

nTrials = 100; %extract nTrials frames from each of 60 files per talker

%base to use in numerical representation, if bases other than 10 are used,
%the reference distributions pB and pG below must be changed to match
base = 10; 

%Benford Distribution
pB = log10(1+ 1./[1:9]');

%Leading digit distribution for Gaussian data (by simulation)
pG = [0.35950279   0.12898903   0.08652423   0.08096799   0.07741855 ...
      0.07342246 0.06910293   0.06439634   0.05967568]';

%Pack Benford and Gauss LDDs into a single reference matrix
Refs=[pB pG];

Dtalker21=[]; %initialize some variables 
Dtalker22=[];

talker = 21; %gather LDDDs for talker 21 
for j=1:60 %loop over all 60 files
    [speech, fs] = getTSPSpeechByTalker(talker,j); %get file
    [~,~,active]=svp56appx(speech*(2^15),fs);%find activity mask
    %use mask to find longest active intefal in the file
    [first, last] = longestActiveInterval(active); 
    L = last-first+1; %length of that interval
    for k = 1:nTrials
        %select appropriate random starting place for each frame
        start = first + randi(L - maxSmp+1)-1;
        temp =  speech(start:start + maxSmp-1); %extract that frame
        Ps(k,:) = LDhist( temp/std(temp) ,base ); %find LDD and store it
    end
    Dtalker21(j,:,:) = multiKLD(Ps',Refs); %find LDDD and store it
end
%place all trials for all files in dim 1, dim 2 is for the two references
%(Benford and Gauss) 
Dtalker21 = reshape(Dtalker21,60*nTrials,2);

talker = 22;
for j=1:60 %loop over all 60 files
    [speech, fs] = getTSPSpeechByTalker(talker,j); %get file
    [~,~,active]=svp56appx(speech*(2^15),fs);%find activity mask
    %use mask to find longest active intefal in the file
    [first, last] = longestActiveInterval(active); 
    L = last-first+1; %length of that interval
    for k = 1:nTrials
        %select appropriate random starting place for each frame
        start = first + randi(L - maxSmp+1)-1;
        temp =  speech(start:start + maxSmp-1); %extract that frame
        Ps(k,:) = LDhist( temp/std(temp) ,base ); %find LDD and store it
    end
    Dtalker22(j,:,:) = multiKLD(Ps',Refs); %find LDDD and store it
end
%place all trials for all files in dim 1, dim 2 is for the two references
%(Benford and Gauss) 
Dtalker22 = reshape(Dtalker22,60*nTrials,2);


%Two colors from the Masataka Okabe and Kei Ito colorblind accessible
% color pallet
color1 =  [86 180 233]/255;
color2 =  [204 121 167]/255;
fsize=8; %font size in plots
msize =4; %marker size in plots 

figure(3)
%plot examples of talker 21
plot(Dtalker21(:,1),Dtalker21(:,2),'o','MarkerEdgeColor',color1,'MarkerSize',msize)
hold on
%plot examples of talker 22
plot(Dtalker21(:,2),Dtalker22(:,2),'o','MarkerEdgeColor',color2,'MarkerSize',msize)
grid

%label the axes
set(groot, 'defaultTextInterpreter', 'latex');
xlabel('$D(P_A,P_B)$','FontName', 'Times New Roman', 'FontSize', fsize)
ylabel('$D(P_A,P_G)$','FontName', 'Times New Roman', 'FontSize', fsize)

%set tick label font size
ax = gca;
ax.XAxis.FontSize = fsize;
ax.YAxis.FontSize = fsize;

%parameters for linear discriminate function (LDF), selected to minimize
%classification error, found using external code
theta = [-0.0436 6.9531];

%calculate line representing LDF
xLine = linspace(0,.2,100);
yLine = theta(1) + theta(2)*xLine;

%add that line to the plot
plot(xLine,yLine,'--k','LineWidth',1)
hold off

axis([0 .08 0 .1])
title('Blue circles indicate Talker 21 (aka FK) and purple pluses indicate Talker 22 (aka FL)' )
set(gcf,'Position',[50 50 1200 600])

%concatenate data for both talkers
K = [Dtalker21;Dtalker22];

%create corresponding talker number key vector
talkerNumber = [21*ones(6000,1);22*ones(6000,1)];

%taklkerIs21 is a vector taking the value 1 where LDF indicates talker 21 
talkerIs21 = ( K(:,2) <= theta(1) + theta(2)*K(:,1) );

%find rate of correct decisions
correctDecisionRate = ...
    ( sum(talkerIs21 & talkerNumber==21) + ...
      sum( ~talkerIs21 & talkerNumber==22 ) ) / length(talkerNumber);

%report that result
disp(['Rate of correct binary decision by LDF is ', ...
    num2str(correctDecisionRate),'.'])
