function [x, fs] = getTSPSpeechByTalker(talker,file)
%Returns one of the 1444 speech files in the 48k portion of the TSP Speech
%Database
%
%talker is 1 to 25 
%   1 to 11 are males, 60 files per talker
%   12 to 22 are females, 60 files per talker
%   23 is female with 58 files
%   24 is child with 60 files
%   25 is child with 6 files
%
%September 10, 2026 by S. Voran at Institute for Telecommunication Sciences
%in Boulder, Colorado, USA 

%talkers are organized by these directory names
talkers = {'MA','MB','MC','MD','MF','MG','MH','MI','MJ','MK','ML', ...}
'FA','FB','FC','FD','FF','FG','FH','FI','FJ','FK','FL',...
'FE', 'CA', 'CB'};

%find all wav files
D = dir('..\data\48k\*\*.wav');

if 25 < talker %test talker for correct range
    error('talker must be 1 to 25')
end

%find locations of the files for the requested talker
locs = find(startsWith({D.name},talkers{talker}));

if file<=length(locs)
    ptr = locs(file); %find location of requested file
    fname = fullfile(D(ptr).folder,D(ptr).name); %create filename
    [x,fs] = audioread(fname); %load the file
else
    error('file number to large for this talker')
end
