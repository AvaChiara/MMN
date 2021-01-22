# MMN

(c) Chiara Avancini 2019

This file contains a description of the data analysis pipeline for the MMN project and instructions on how to use the scripts.

## Chiara's details
Cam email: ca410@cam.ac.uk \
Alternative email: chiaraava@gmail.com \
Mobile: 07582128623

## Pipeline

Updated 30/01/2020.

1) Import data with dataimport_MMN()
2) Epoch and filter with epoch_MMN()
3) Detect bad electrodes without rejecting them with detectBadElectrodes_MMN()
4) ICA decomposition with computeica_MMN_Chi()
5) Eye blinks and horizontal eye movements removal with ICA
6) Robust detrending
5) Interpolate bad electrodes and reject bad trials with interpBadChanAndRejectBadTrials_MMN(). Removed epochs in which more than 5 channels contribute to the rejection
6) Rereference with rereference_MMN()
