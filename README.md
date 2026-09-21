# Leading Digit Distribution Divergence tools in MATLAB® 
Code provided here demonstrates the tools and results described in:
Stephen D. Voran and Jaden Pieper, "Divergences of Audio Signal Leading Digit Distributions are 
Useful Lightweight Features,"
Institute for Telecommunication Sciences, Boulder, Colorado, USA,
{svoran, jpieper}@ntia.gov.

If this code is useful for your research, we would appreciate it if any
resulting publications would cite the paper mentioned above.


# How to run
* Clone to local repository  
* Start MATLAB or Octave  
* Three top-level programs are showTSPspeechLDD.m, analyzeTSPmultiTalker.m, and TSPtalkerStudy.m
* Run any of these to see results in numeric and/or graphical form
* Modify these to experiment with other audio signals, bases, frame durations, etc.

# Some Details
* showTSPspeechLDD.m shows the leading digit distribution for TSP speech (included here) as per figure 1 in the paper.
If one has licensed TIMIT speech, then one could extend to get results for that, or for any other dataset.
* analyzeTSPmultiTalker.m reproduces the multi-talker TSP speech results found in figure 3 in the paper.
This is organized into 3 cells.  The first creates and stores data. (The precomputed file is available, so running the first cell is not required.)
The second cell runs the one talker vs more-than-one talker task.  The third cell runs the one talker vs N talkers task.
* TSPtalkerStudy.m shows how this approach can separate two talkers (not included in paper).