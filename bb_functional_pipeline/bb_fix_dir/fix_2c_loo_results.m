
function fix_2c_loo_results(LOODIR)

[~, bLOODIR] = system(sprintf('basename %s',LOODIR));
bLOODIR=sscanf(bLOODIR,'%s');
if exist(sprintf('%s/.train',LOODIR)) == 2
 pt=fopen(sprintf('%s/.train',LOODIR),'r');
 bLOODIR=textscan(pt,'%s'); bLOODIR=char(bLOODIR{1}(1));
end
grot=tempname;

pp=fopen(sprintf('%s/.fixlist',LOODIR),'r');
thelist=textscan(pp,'%s');

thresh = [1 2 5 10 20 30 40 50];
for ithresh=1:length(thresh)
  for i = 1:size(thelist{1},1)

    f=char(thelist{1}(i));

    call_fsl(sprintf('fslnvols %s/filtered_func_data.ica/melodic_IC > %s',f,grot));
    Nics=load(sprintf('%s',grot));

    system(sprintf('tail -n 1 %s/hand_labels_noise.txt | sed ''s/\\[//g'' | sed ''s/\\]//g'' | sed ''s/,//g'' > %s',f,grot));
    hand=load(sprintf('%s',grot));

    system(sprintf('tail -n 1 %s/fix4melview_%s_thr%d.txt | sed ''s/\\[//g'' | sed ''s/\\]//g'' | sed ''s/,//g'' > %s',f,bLOODIR,thresh(ithresh),grot));
    try
        fix=load(sprintf('%s',grot));
    catch
        fix=[];
    end
    Signal_good = 100 * (1 - ( length(setdiff(fix,hand)) / (Nics-length(hand)) ) );
    Noise_good  = 100 * (1 - ( length(setdiff(hand,fix)) / length(hand) ) );
    Ngood(i,(ithresh-1)*2+1:ithresh*2)=[ Signal_good Noise_good ];

  end
end

disp(['set of thresholds is: ' num2str(thresh)])
disp('[TPR,TNR] pairs of results (one row per dataset, one pair per threshold):')
disp(Ngood)
disp('[TPR,TNR] pairs of results (averaged over datasets, one pair per threshold):')
disp(mean(Ngood))

po=fopen(sprintf('%s_results',LOODIR),'w');
for i=1:size(Ngood,1)
  fprintf(po,[num2str(Ngood(i,:),'%.1f ') '\n']);
end
fprintf(po,'\n\n\n');
fprintf(po,['set of thresholds is: ' num2str(thresh) '\n']);
fprintf(po,'[TPR,TNR,(3*TPR+TNR)/4] pairs of results (averaged over datasets, one pair per threshold):\n');
fprintf(po,'\nmean\n');
fprintf(po,[num2str(mean(Ngood(:,1:2:end)),'%.1f ') '\n']);
fprintf(po,[num2str(mean(Ngood(:,2:2:end)),'%.1f ') '\n']);
fprintf(po,[num2str((3*mean(Ngood(:,1:2:end))+mean(Ngood(:,2:2:end)))/4,'%.1f ') '\n']);
fprintf(po,'\nmedian\n');
fprintf(po,[num2str(median(Ngood(:,1:2:end)),'%.1f ') '\n']);
fprintf(po,[num2str(median(Ngood(:,2:2:end)),'%.1f ') '\n']);
fprintf(po,[num2str(median((3*Ngood(:,1:2:end)+Ngood(:,2:2:end))/4),'%.1f ') '\n']);
%[~,bestTHR]=sort((3*mean(Ngood(:,1:2:end))+mean(Ngood(:,2:2:end)))/4); bestTHR=bestTHR(end);
%fprintf(po,'\nat an optimal threshold of %d, TPR=%.1f TNR=%.1f\n',thresh(bestTHR),,);
