function SLURM_robust_detrend(filename, indir, outdir)
EEG = pop_loadset([indir filesep filename]);
EEG = robust_locdetrend(EEG,'yes');
pop_saveset(EEG, 'filepath', outdir, 'filename', [filename(1:end-7) 'det.set']);
end