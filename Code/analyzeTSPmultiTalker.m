%% make Leading digit distributions for the TSP multi-talker experiments
%September 21, 2026 by S. Voran at Institute for Telecommunication Sciences
%in Boulder, Colorado, USA 
nTrials = 10000;
frameDuration = 512;
base = 10;
saveName = '../data/matlab/TSPmultiTalker_10kTrials_512msFrames_base10';
makeTSPmultiTalker(nTrials,frameDuration, base, saveName)
%took about 2.5 hours on one platform

%% Do the one talker vs more-than-one talker task

load ../data/matlab/TSPmultiTalker_10kTrials_512msFrames_base10
%LDD dim 1 is ntrials, one location for each trial
%LDD dim 2 is 20, location matches the number of talkers
%LDD dim 3 is 9, one location for each digit (1 to 9)

%Initialize some variables
K=[]; %will contain KLDs for the examples
N = []; %will contain the number of signals for each example

%Benford Distribution
pB = log10(1+ 1./[1:9]');

%Leading digit distribution for Gaussian data (by simulation)
pG = [0.35950279   0.12898903   0.08652423   0.08096799   0.07741855 ...
      0.07342246 0.06910293   0.06439634   0.05967568]';

%Pack Benford and Gauss LDDs into a single reference matrix
Refs=[pB pG];

%Extract all cases of 1 talker, they are in column 1
temp = squeeze(LDD(:,1,:));  

%Find KLD between the 1 talker cases and the two references
K = multiKLD(temp',Refs);
nOne = size(K,1); %number of examples of 1 talker
N = ones(nOne ,1); %vector of 1's (for 1 talker)

%We have 19 cases of more than one talker.  Figure out how many to take
%from each case so that the number of examples of more-than-one talker
%roughly matches the number of examples of one talker.
nMany = ceil(nOne/19); 

%Loop over all cases of more than one talker
for nTalk = 2:20
    temp = squeeze(LDD(:,nTalk,:)); %extract that case
    klds = multiKLD(temp',Refs);    %find KLDs
    klds = klds(1:nMany,:);         %save appropriate number of examples 
    K = [K;klds];                   %append those examples to K
    N = [N; nTalk*ones(nMany,1)];   %append current number of talkers to N
end

%K now has length nOne + 19*nMany =10,1000 + 19 * ceil(10,000/19) = 20,013
%rows. These rows hold:
%10,000 cases of 1 talker.
%527 cases of 2 talkers
%527 cases of 3 talkers
%...
%527 cases of 20 talkers
%
%From a one vs more-than-one perspective, this is roughly balanced.
%There are 10,000 examples of one talker, and 10,013 examples of
%more-than-one talker.
%
%K has 2 columns.  Column 1 holds KLDs between audio and Pb
%column 2 holds KLDs between audio and Pg
%
%N also has 20,013 rows and tells the number of talkers for each example.

%vector of locations in N and K corresponding to one talker
one = find(N==1); 
%vector of locations in N and K corresponding to more-than-one talker
many = find(N~=1);

%Two colors from the Masataka Okabe and Kei Ito colorblind accessible
% color pallet
color1 =  [86 180 233]/255;
color2 =  [204 121 167]/255;
fsize=8; %font size in plots
msize =4; %marker size in plots 

%plotting step, this is a subsampling factor.  1 causes all examples
%to be plotted, 3 causes every third example to be plotted, etc.
pStep = 1;

figure(1)
%plot examples of one talker in KLD plane using circles and color 1
plot(K(one(1:pStep:end),1),K(one(1:pStep:end),2),'o', ...
    'MarkerEdgeColor',color1,'MarkerSize',msize)
hold on
%plot examples of more-than-one talker in KLD plane 
%using pluses and color 2
plot(K(many(1:pStep:end),1),K(many(1:pStep:end),2),'+',...
    'MarkerEdgeColor',color2,'MarkerSize',msize)
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
theta = [0.0187 -0.4134];

%calculate line representing LDF
xLine = linspace(0,.2,100);
yLine = theta(1) + theta(2)*xLine;

%add that line to the plot
plot(xLine,yLine,'--k','LineWidth',1)
hold off

axis([0 .05 0 .05]) %set axes
title(['Blue circles indicate one talker and purple ' ...
    'pluses indicate more-than-one talker'] )

%apply LDF to the data, moreThanOne is 1 where LDF detects more-than-one
%talker 
moreThanOne = ( K(:,2) <= theta(1) + theta(2)*K(:,1) );

%find rate of correct decsions
correctDecisionRate = ...
    ( sum( moreThanOne & N~=1)  + sum( ~moreThanOne & N==1 ) )/length(N);

disp(['Rate of correct binary decision by LDF is ', ...
    num2str(correctDecisionRate),'.'])

%% Do the one talker vs nTalk talkers task

nTalk = 7; %set nTalk to 2, 3, ... 20

%parameters for linear discriminate functions (LDFs), selected to minimize
%classification error, found using external code
%row n holds parameters for nTalk = n;
allThetas =[...
         0         0
    0.0317   -0.9819
    0.0282   -0.8248
    0.0254   -0.7184
    0.0240   -0.6003
    0.0212   -0.4991
    0.0206   -0.4831
    0.0201   -0.4676
    0.0185   -0.4140
    0.0178   -0.4039
    0.0175   -0.3988
    0.0175   -0.4022
    0.0155   -0.3232
    0.0149   -0.3040
    0.0140   -0.2974
    0.0136   -0.2674
    0.0133   -0.2685
    0.0136   -0.2886
    0.0132   -0.2679
    0.0116   -0.2291];

load ../data/matlab/TSPmultiTalker_10kTrials_512msFrames_base10
%LDD dim 1 is ntrials, one location for each trial
%LDD dim 2 is 20, location matches the number of talkers
%LDD dim 3 is 9, one location for each digit (1 to 9)

%Initialize some variables
K=[]; %will contain KLDs for the examples
N = []; %will contain the number of signals for each example

%Benford Distribution
pB = log10(1+ 1./[1:9]');

%Leading digit distribution for Gaussian data (by simulation)
pG = [0.35950279   0.12898903   0.08652423   0.08096799   0.07741855 ...
      0.07342246 0.06910293   0.06439634   0.05967568]';

%Pack Benford and Gauss LDDs into a single reference matrix
Refs=[pB pG];

%Extract all cases of 1 talker, they are in column 1
temp = squeeze(LDD(:,1,:));  

%Find KLD between the 1 talker cases and the two references
K = multiKLD(temp',Refs);
nOne = size(K,1); %number of examples of 1 talker
N = ones(nOne ,1); %vector of 1's (for 1 talker)

%Extract all cases of nTalk talkers
temp = squeeze(LDD(:,nTalk,:)); 

%Find KLD between the nTalk talker cases and the two references
klds = multiKLD(temp',Refs); 
K = [K;klds]; %append those KLDS to K
%append nTalk to N appropriate number of times
N = [N; nTalk*ones(size(klds,1),1)];

%K has length 10,000 + 10,000 = 20,000
%rows. These rows hold:
%10,000 cases of 1 talker.
%10,000 cases of nTalk talkers
%
%From a one vs nTalk perspective, this is balanced.
%K has 2 columns.  Column 1 holds KLDs between audio and Pb
%column 2 holds KLDs between audio and Pg
%
%N also has 20,000 rows and tells the number of talkers for each example.

%vector of locations in N and K corresponding to one talker
one = find(N==1); 
%vector of locations in N and K corresponding to ntalk talkers
many = find(N~=1);

%Two colors from the Masataka Okabe and Kei Ito colorblind accessible
% color pallet
color1 =  [86 180 233]/255;
color2 =  [204 121 167]/255;
fsize=8; %font size in plots
msize =4; %marker size in plots 

%plotting step, this is a subsampling factor.  1 causes all examples
%to be plotted, 3 causes every third example to be plotted, etc.
pStep = 1;

figure(2)
%plot examples of one talker in KLD plane using circles and color 1
plot(K(one(1:pStep:end),1),K(one(1:pStep:end),2),'o', ...
    'MarkerEdgeColor',color1,'MarkerSize',msize)
hold on
%plot examples of nTalk talkers in KLD plane 
%using pluses and color 2
plot(K(many(1:pStep:end),1),K(many(1:pStep:end),2),'+',...
    'MarkerEdgeColor',color2,'MarkerSize',msize)
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
theta = allThetas(nTalk,:);

%calculate line representing LDF
xLine = linspace(0,.2,100);
yLine = theta(1) + theta(2)*xLine;

%add that line to the plot
plot(xLine,yLine,'--k','LineWidth',1)
hold off

axis([0 .05 0 .05]) %set axes
title(['Blue circles indicate one talker and purple pluses indicate ',...
    num2str(nTalk),' talkers'] )

%apply LDF to the data, moreThanOne is 1 where LDF detects more-than-one
%talker 
moreThanOne = ( K(:,2) <= theta(1) + theta(2)*K(:,1) );

%find rate of correct decsions
correctDecisionRate = ...
    ( sum( moreThanOne & N~=1)  + sum( ~moreThanOne & N==1 ) )/length(N);

disp(['Rate of correct binary decision by LDF is ', ...
    num2str(correctDecisionRate),'.'])