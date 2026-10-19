function [first, last] = longestActiveInterval(active)
%Finds the longest active interval in an activity mask.
% 
%active is a column vector of 0's and 1's where 1 indicates that the
%corresponding speech sample is active
%first and last are integers that give the first and last entry in 
%active that correspond to the longest continuous active interval
%
%September 19, 2026 by S. Voran at Institute for Telecommunication Sciences
%in Boulder, Colorado, USA 

if active(1) == 1 %case 1, starts with active sample
    firsts = [1; find( 1 == diff(active) ) + 1]; %locations of all starts
    lasts = find( -1 == diff(active)) ; %locations of all ends
    if active(end) == 1 %deal with the final active interval
        lasts = [lasts; length(active)];
    end
else %case 2 starts with inactive sample
    firsts = [find( 1 == diff(active) ) + 1]; %locations of all starts
    lasts = find( -1 == diff(active)); %locations of all ends
    if active(end) == 1 %deal with the final active interval
        lasts = [lasts; length(active)];
    end
end
lens = lasts-firsts; %find lengths of all active intervals
[~,loc] = max(lens); %find location of the longest one
first = firsts(loc); %extract start 
last = lasts(loc);  %extract end