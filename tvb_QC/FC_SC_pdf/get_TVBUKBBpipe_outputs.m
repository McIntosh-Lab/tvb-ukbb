function get_TVBUKBBpipe_outputs(subj_list, out_dir)

% get_TVBUKBBpipe_outputs saves a set of SC, FC and timeseries plots for
% each subject in subj_list
%
% USAGE:
%   get_TVBUKBBpipe_outputs(subj_list, out_dir)
%
% where subj_list is a .txt file of subject directories with the full path
% specified, and out_dir is where each subject's plots will be saved


subjDirs=textread(subj_list,'%s');

for i=1:size(subjDirs,1)
    subj=subjDirs{i};
    subjName=subj(strfind(subj,'sub'):end)
    
    SC_abs=dlmread([subj '/dMRI/probtrackx/fdt_network_matrix']);
    waytotal=dlmread([subj '/dMRI/probtrackx/waytotal']);
    SC=bsxfun(@rdivide,SC_abs,waytotal);
    tract_lengths=dlmread([subj '/dMRI/probtrackx/fdt_network_matrix_lengths']);
    FC=dlmread([subj '/fMRI/rfMRI.ica/fc.txt']);
    norm_ts=zscore(dlmread([subj '/fMRI/rfMRI.ica/ts.txt']));
    
    figure;
    subplot(2,2,1)
    imagesc(log10(SC)); axis square; colorbar; title('SC')
    
    subplot(2,2,2)
    imagesc(tract_lengths); axis square; colorbar; title('tract lengths')
    
    subplot(2,2,3)
    imagesc(FC); axis square; colorbar; title('FC')
    
    ax(4)=subplot(2,2,4);
    imagesc(norm_ts'); colormap(ax(4),gray); xlabel('volume'); ylabel('ROI'); title('ROI timeseries carpet plot')
    
    saveNm=[out_dir '/' subjName '_SCFC.pdf'];
    saveas(gcf,saveNm)
    
end
    
    