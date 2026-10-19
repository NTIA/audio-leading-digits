function speech = getTSPSpeech(ptr)
%Returns one of the 1444 speech files in the 48k portion of the TSP Speech
%Database
%
%ptr = 1 to 1444 points to the file
%
%The 1444 files have a total of 3426 seconds of speech (57.1 minutes)
%Lengths of the 1444 files range from 1.3 to 4.8 sec.
%
%September 10, 2026 by S. Voran at Institute for Telecommunication Sciences
%in Boulder, Colorado, USA 

%create list of .wav files
D = dir('..\data\48k\*\*.wav');

%number of .wav files found
nFiles = length(D); 

%Test for ptr out of bounds
if nFiles < ptr
    error('ptr exceeds number of files found')
end

%construct full name of file that ptr points to
fname = fullfile( D(ptr).folder, D(ptr).name ); 

%read that file
[speech,fs] = audioread(fname); 

%test sample rate to make sure it 48k
if fs ~= 48000
    error('Expected this file to have fs=48k')
end
