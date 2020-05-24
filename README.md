# Automatic Human Sleep Stage Scoring Using Deep Neural Networks

This code is implementing the future based algorithm used in our paper "Automatic Human Sleep Stage Scoring Using Deep Neural Networks".

Please cite our paper:

"Automatic Human Sleep Stage Scoring Using Deep Neural Networks"
Alexander Malafeev, Dmitry Laptev, Stefan Bauer, Ximena Omlin, Aleksandra Wierzbicka, Adam Wichniak, Wojciech Jernajczyk, Robert Riener, Joachim Buhmann and Peter Achermann
Front. Neurosci., 06 November 2018, https://doi.org/10.3389/fnins.2018.00781

## Getting Started

 The code is not exactly the same, but with slight changes.
Since we can not publish the training data due to privacy reasons we provide only the needed code to train your own model using your data. We also provide trained model and the code needed to apply it for edf files.
In this version of code we did not use HMM thus there is no time dependency between epochs taken into account.
You can use median filter. We noticed that the median filter with the window size equal 3 gives very similar results to HMM. The issue with HMM is that it would learn transition probabilities and for example it would learn in the dataset of healthy subjects that wake is never followed by REM sleep but it can happen in patients. Thus it is better not to use HMM. 

In the paper we used slow wave detection algorithm by Alessia Bersagliere. In the current code we use simplified version of the algorithm (detects only positive half waves) implemented by Alexander Malafeev.

We also provide model trained only using the data of healthy subjects.  

### Prerequisites

You will need Matlab 2018a or later.



### Installing

After you have downloaded the folder with files you would need to download the external files needed to read edf. We used the library blockEdfLoad written by Dennis Dean, it is available at https://github.com/DennisDean/BlockEdfLoad/blob/master/blockEdfLoad.m. Put the mat file you get by following the link into the folder with edf2mat file (root folder).

We also used function confusionmatStats (https://ch.mathworks.com/matlabcentral/fileexchange/46035-confusionmatstats-group-grouphat). Put it into the same folder.

We also use moving correlation for detection of eye blinks and rapid eye movements. We used the function MovCorr1 from StackOverflow (https://stackoverflow.com/a/28671175) put the code of the function into the file 
MovCorr1.m in the root folder.

## Scoring your data


### Data conversion

At the moment you can work only with edf files. First you should convert them to .mat files which can be used by our network. You can use Matlab script edf2mat.m which is located in the root folder.

Before you can convert your data you should open the raw2mat.m  script and set
following variables:
1) readPath = './../EEG_data/' % it is the path to the folder with edf files
2) writePath = '../mat/' % directory with the output data
3) labels for the EEG, EOG and EMG channels
4) If you have scoring for your data you need to set scoringFolder variable and
insert the function which reads scoring into the corresponding part of edf2mat (line 174). We don't provide the function for reading scoring files because scoring format is usually specific for the dataset and the lab. 

In case you are using the script for scoring just leave the scoringFolder variable undefined (commented out).

Then you can run the script.

### Scoring

After you have converted your data you can either train your own model using script runForest.m
or use the model we trained.

To use pretrained model you can run the script predict.m. You should set the path to the folder with converted data
for scoring and the path to the folder where mat files with the results and plots will be saved.

### Training 

If you want to train your own network you should use the script runForest.m. 
In the script you should set variables dataFolder and file_sets.mat.
dataFolder is the directory with the data for training. 
file_sets.mat contains lists of files for the training, validation and test sets. Generation of these lists is dependent on the dataset. For example we had several recordings of the same subject and it was important to make sure that all recordings of the same subject belong to the same subset.

You can generate file_sets.mat using one of the scripts in the tools folder of the deep learning code : create_file_sets1.m or create_file_sets2.m. The difference between them is that the first one just splits the files randomly. The second one takes into account that different recordings can be recorded from the same person.

There is a script predict_cv_tst.m which use the trained model to predict recordings from validation and test subset of the training dataset. The results will be stored in two mat files: predictions_RF_300.mat and predictions_RF_300_MF.mat
They contain the same result but in the second file it is smoothed by a median filter. Use the script plot_cv_tst.m to plot these  results.


## Author

* **Alexander Malafeev** 

## License

This project is licensed under the MIT license - see the [LICENSE](LICENSE) file for details


