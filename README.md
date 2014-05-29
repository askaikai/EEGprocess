EEGprocess
==========

series of code used to analyze EEG data. mostly using Fiedtrip on Matlab.


### Directory Structure
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
1. preprocess_EEG_v2: reads in EDF and lay files from the recording session to organize into analyzable format  
2. artifactRemovalStep: runs eye-movement/blink removal, jump and muscle artifact removal  
3. splitCleanFile: epochs artifact-free data into segments of uniform duration  
4. TFR_hanning: performs time-frequency analysis  
5. makeGA: creates grand-average of power across subjects  
6. compare_tasks: runs permutation t-test to compare tasks. creates stat maps  
	
				
			
