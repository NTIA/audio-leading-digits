function makeTSPmultiTalker(nTrials,frameDuration, base, saveName)
%Function that precomputes large sets of leading digit distributions
%for mixtures of 1 to 20 talkers. 
%
%nTrials is the number of trials to do
%frameDuration is duration of each frame in ms (this drives the number
%of samples in each histogram)
%base is the number system base used for the leading digit distributions
%
%saveName is a .mat file that holds the variable LDD.
%LDD is nTrials by 20 by base-1
%first dim is trials
%second dim corresponds to the sum of 1, 2, ... 20 random TSP speech
%frames
%third dim holds the bins of the leading digit distribution
%
%September 19, 2026 by S. Voran at Institute for Telecommunication Sciences
%in Boulder, Colorado, USA 

%List of the different numbers of signals (talkers) to combine
nSigList = [1:20]; 
maxSig = nSigList(end); %largest number of signals
fs = 48000; %sample rate for TSP speech that will be used

%convert frame duration to number of samples per frame
maxSmp = frameDuration*fs/1000;
rng(1) %seed pseudo-random number generator for reproducibility

for i = 1:nTrials %loop over trials
    if ~rem(i,10) %show progress periodically
        disp(['Working on trial ',num2str(i),' out of ',num2str(nTrials),' trials.'])
    end
    S = []; %initialize speech matrix

    %loop over number of signals to build signal matrix S, nsmp by nsigs
    for j = 1:maxSig 
        f = randi(1444); %pick one of the TSP speech files at random

        speech = getTSPSpeech(f); %load that speech file
        %find speech activity mask
        [~,~,active]=svp56appx(speech*(2^15),fs); 
        %use that mask to find longest active interval in the file
        [first, last] = longestActiveInterval(active);
        L = last-first+1; %length of that interval
        %select an appropriate random starting point for a frame
        start = first + randi(L - maxSmp+1)-1;
        %extract the frame and store in S
        S(:,j) = speech(start:start + maxSmp-1);
    end

    %form sums of 1, 2, ... 20 signals (talkers), normalize for unit
    %standard deviation, and find LDDs
    for j = 1:length(nSigList) 
        temp = sum( S(:,1:nSigList(j)),2); %form the sum
        tempN = temp/std(temp); %normalize to unit std
        LDD(i,j,:) = LDhist( tempN ,base ); %find LDD and store
    end
end

save(saveName,'LDD') %save LDDs to requested file