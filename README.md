EEGprocess
==========

series of code used to analyze EEG data. mostly using Fiedtrip on Matlab.

written by: Akiko Ikkai


### Data Directory Structure
AES_EEG_06072012  
	preprocessed  
		subxx  
		   TFR  
		     highFreq  
		     lowFreq  
	
	rawdata  
	
	TFR  
	  highFreq  
	  lowFreq  

### Analysis Steps
1. preprocess_EEG_v2: reads in EDF and lay files from the recording session to organize into analyzable format. see notes below    
2. artifactRemovalStep: runs eye-movement/blink removal, jump and muscle artifact removal. requires manual inputs, checking and adjustment for each subject    
3. splitCleanFile: epochs artifact-free data into segments of uniform duration  
4. TFR_hanning: performs time-frequency analysis  
5. makeGA: creates grand-average of power across subjects  
6. compare_tasks: runs permutation t-test to compare tasks. creates stat maps  
7. ft_classify_EEG_allchan: runs classification between trial types at each electrode. run this function at individual level, and perform permutation t-test  

### Notes
* raw data (in raw data folder) should be named: "EEG011.edf" and "EEG011.lay". first 2 digits are sub number, and the last digit is the session number.

* before the analysis, you need to specify path to fieldtrip and EEGprocess (this) folder. so, do something like:      
```{r}
cd /Users/akiko/Experiments/WendyEEG/AES_EEG_06072012/
addpath(genpath('~/Experiments/MatlabToolBox/fieldtrip-20140424'))
addpath(genpath('~/Experiments/MatlabToolBox/EEGprocess'))
```
* preprocess_EEG_v2 relies on the quality of .lay file. unfortunately, .lay files are not very consistent. it's strongly recommended to check masterTime file to make sure events and time stamps are captured correctly.

	
				
			
