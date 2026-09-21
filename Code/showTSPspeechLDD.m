%This code calculates the leading digit distribution (histogram) for 
%TSP speech.  Thus it allows replication of the TSP Speech portion of
%Figure 1 in the paper.
%It also allows experimentation with other frame durations, bases, 
%and numbers of histograms. It can be adapted to process other databases.
%
%September 21, 2026 by S. Voran at Institute for Telecommunication Sciences
%in Boulder, Colorado, USA 

frameDur = 512; %frame duration in ms, maximum is 1024 ms
%base to use for leading digit histogram, must be an integer 3 or greater
base = 10; 
nHist = 5000; %number of histograms to create

%Timing note: nHist = 5000, frameDur = 512, base = 10  takes about 62 sec
%on one platform 

fs = 48000; %sample rate for TSP speech 
frameDur = frameDur*fs/1000; %convert frame duration from time to samples

%find number of frames to extract from each file in order to meet or
%exceed the total number of histograms requested
nTrials = ceil(nHist/1444); 

%set the maximum frame size (in samples) that code will accommodate.
%1024 ms * 48 kS/s = 49152 
maxN = 49152;

H = zeros(1444*nTrials,base-1); %Initialize histogram storage
rng(0); %seed the PR number generator for repeatability in extracting frames
ptr = 1; %initialize pointer
for fn = 1:1444 %loop over all files in TSP database
    speech = getTSPSpeech(fn); %get the file
    %periodically show progress
    if ~rem(fn,100)
        disp(['Working on file ',num2str(fn),' of 1444.'])
    end
    %find last sample that is a legit place a frame to start
    last = length(speech)-maxN+1;
    for i=1:nTrials %loop over trials
        first = randi(last); %draw a random starting location for the frame
        temp = speech(first:first+frameDur-1); %extract the frame
        %find and store leading digit histogram of frame 
        H(ptr,:) = LDhist(temp,base); 
        ptr = ptr+1; %advance pointer
    end
end

%Create Benford distribution for reference purposes
pB = log10(1+ 1./[1:base-1]')/log10(base); 

cf = .5; %central fraction of distribution to show using whiskers on the
% plot.  1.0 shows entire distribution

rng(0) %seed the PR number generator for repeatability in extracting results

%We have 1444*nTrials histograms but are only considering nHist.
%Truncation could eliminate all information from some files, so instead
%we randomly select nHist results
ntrialsAvail = size(H,1); %number of trials available
temp = randperm(ntrialsAvail); %list all available trials in random order
temp = temp(1:nHist); %save the desired number of trials
H=H(temp,:); %extract those trials

%Sort the probabilities for each digit separately
H=sort(H,1);

%Find limits of the central fraction (cf) for the distribution that 
%the whiskers will show.
first = round((1-cf)*nHist/2)+1;
last = nHist-first+1;

mH = mean(H); %Find mean
dWhisk = mH-H(first,:); %Find length of down whisker
uWhisk = H(last,:)-mH; %Find length of up whisker

figure(1)
bw = .9; %bar width for Benford distribution
%draw Benford distribution bars
bar(1:base-1,pB,bw,'FaceColor',[255 255 128]/255)
hold on

bw = .2; %bar width for TSP speech distribution
%draw TSP speech distribution bars
barHandle = bar(1:base-1, mH,bw,'FaceColor',[213 94 0]/255);
xList = barHandle.XEndPoints; %get locations of bars

%draw the whiskers at the bar locations
errorbar(xList,mH,dWhisk,uWhisk,'k', 'LineStyle', 'none')
hold off
grid

% Set the interpreter for titles, x/y/z labels, and text objects
%set(groot, 'defaultTextInterpreter', 'latex');
% Set the interpreter for axis tick labels (numbers on the axes)
%set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
%Set the interpreter for legends
set(groot, 'defaultLegendInterpreter', 'latex');
fsize = 14; %fontsize 
xlabel('Leading Digit','FontName', 'Times New Roman', 'FontSize', fsize)
ylabel('Relative Frequency','FontName', 'Times New Roman', 'FontSize', fsize)
legend('  $P_B$ (Benford Distribution)','  48.0 kS/s TSP Speech','FontName', 'Times New Roman', 'FontSize', fsize)

%These two graph display settings work well for the case of
%nHist = 5000, frameDur = 512, base = 10,
%and were used for fig. 1 in the paper 
%
%axis([.4 9.6 0 .36])
%set(gcf,'Position',[50 50 1200 300])