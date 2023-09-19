
function fix_1a_extract_features(icaFolder)
try
    global icThreshold;
    icThreshold = 2.5;
    globalIcCounter = 0;
    if(icaFolder(length(icaFolder))~='/')
        icaFolder = [icaFolder '/'];
    end
    % % get the time series and the number of ICs
    melodicMixFile = [icaFolder 'filtered_func_data.ica/melodic_mix'];
    mixingMatrix = load(melodicMixFile);
    numberOfIcs = size(mixingMatrix,2);
    
    % % Image acquisition parameters
    call_fsl(sprintf('fslinfo %s > %sfix/dummyinfo.txt', [icaFolder 'filtered_func_data.nii.gz'], icaFolder));
    fileID = fopen(sprintf('%sfix/dummyinfo.txt', icaFolder), 'r');
    
    fslinfo = textscan(fileID,'%s %s\n');
    fslinfo = cell2struct(fslinfo{2},fslinfo{1});
    xLen = str2double(fslinfo.dim1);
    yLen = str2double(fslinfo.dim2);
    zLen = str2double(fslinfo.dim3);
    tLen = str2double(fslinfo.dim4);
    xRes = str2double(fslinfo.pixdim1);
    yRes = str2double(fslinfo.pixdim2);
    zRes = str2double(fslinfo.pixdim3);
    tRes = str2double(fslinfo.pixdim4);
    
    % 	    [~] = fgetl(fileID);
    % 	    oneLine = fgetl(fileID); xLen = str2double(oneLine(6:end));
    % 	    oneLine = fgetl(fileID); yLen = str2double(oneLine(6:end));
    % 	    oneLine = fgetl(fileID); zLen = str2double(oneLine(6:end));
    % 	    oneLine = fgetl(fileID); tLen = str2double(oneLine(6:end));
    % 	    [~] = fgetl(fileID);
    % 	    oneLine = fgetl(fileID); xRes = str2double(oneLine(9:end));
    % 	    oneLine = fgetl(fileID); yRes = str2double(oneLine(9:end));
    % 	    oneLine = fgetl(fileID); zRes = str2double(oneLine(9:end));
    % 	    oneLine = fgetl(fileID); tRes = str2double(oneLine(9:end));
    
    fclose(fileID);
    
    % % Start extracting the features for each and every component ...
    imagePveSeg = read_avw([icaFolder 'fix/hr2exf']);
    call_fsl(sprintf('fslmaths %sfix/hr2exf -thr 1 -uthr 1 -bin %sfix/hr2exfTMP; fslmeants -i %sfiltered_func_data -m %sfix/hr2exfTMP -o %sfix/hr2exfTMP.txt',icaFolder,icaFolder,icaFolder,icaFolder,icaFolder));
    meanCsfTimeSeries= load(sprintf('%sfix/hr2exfTMP.txt',icaFolder))';
    call_fsl(sprintf('fslmaths %sfix/hr2exf -thr 2 -uthr 2 -bin %sfix/hr2exfTMP; fslmeants -i %sfiltered_func_data -m %sfix/hr2exfTMP -o %sfix/hr2exfTMP.txt',icaFolder,icaFolder,icaFolder,icaFolder,icaFolder));
    meanGmTimeSeries= load(sprintf('%sfix/hr2exfTMP.txt',icaFolder))';
    call_fsl(sprintf('fslmaths %sfix/hr2exf -thr 3 -uthr 3 -bin %sfix/hr2exfTMP; fslmeants -i %sfiltered_func_data -m %sfix/hr2exfTMP -o %sfix/hr2exfTMP.txt',icaFolder,icaFolder,icaFolder,icaFolder,icaFolder));
    meanWmTimeSeries= load(sprintf('%sfix/hr2exfTMP.txt',icaFolder))';
    % it used to read
    %imagePveCsf= read_avw([icaFolder 'fix/hr2exf_csf.nii.gz']);
    %imagePveGm = read_avw([icaFolder 'fix/hr2exf_gm.nii.gz']);
    %imagePveWm = read_avw([icaFolder 'fix/hr2exf_wm.nii.gz']);
    
    
    % Per component do as follows
    featureMatrix   = zeros(numberOfIcs, 186); % CHANGE IF FEATURES ARE ADDED/DELETED
    featureMetaInfo = cell(numberOfIcs, 3);
    
    % % Display the folder name
    disp(icaFolder)
    
    for iIc = 1:numberOfIcs
        
        % % Display which IC is being processed
        disp([numberOfIcs iIc])
        globalIcCounter = globalIcCounter+1;
        
        % % Prepare the spatial map
        delete(sprintf('%sfix/dummy*', icaFolder));
        icMaps = [icaFolder 'filtered_func_data.ica/melodic_IC'];
        call_fsl(sprintf('fslroi %s %sfix/dummy %d %d',icMaps, icaFolder, iIc-1, 1));
        call_fsl(sprintf('fslmaths %sfix/dummy -abs %sfix/dummyabs', icaFolder, icaFolder));
        
        % % Prepare the time series
        icWiseTimeSeries = mixingMatrix(:,iIc);
        
        % % Get the IC-wise meta info
        featureMetaInfo{globalIcCounter,2} = icaFolder;
        featureMetaInfo{globalIcCounter,3} = iIc;
        
        % % Spatio-temporal feature(s)
        featureMatrix(globalIcCounter, 001:001)  = numberOfIcs;
        
        % % Temporal Features
        featureMatrix(globalIcCounter, 002:003) = featurearvswgn(icWiseTimeSeries, tRes);
        featureMatrix(globalIcCounter, 004:005) = featurearfull(icWiseTimeSeries, tRes, 1);
        featureMatrix(globalIcCounter, 006:008) = featurearfull(icWiseTimeSeries, tRes, 2);
        featureMatrix(globalIcCounter, 009:009) = skewness(icWiseTimeSeries);
        featureMatrix(globalIcCounter, 010:010) = kurtosis(icWiseTimeSeries);
        featureMatrix(globalIcCounter, 011:011) = mean(icWiseTimeSeries)-median(icWiseTimeSeries);
        featureMatrix(globalIcCounter, 012:013) = featureentropy(icWiseTimeSeries);
        featureMatrix(globalIcCounter, 014:019) = featuretsjump(icWiseTimeSeries);
        featureMatrix(globalIcCounter, 020:020) = featurefftcoarse(icWiseTimeSeries, tRes, .1);
        featureMatrix(globalIcCounter, 021:021) = featurefftcoarse(icWiseTimeSeries, tRes, .15);
        featureMatrix(globalIcCounter, 022:022) = featurefftcoarse(icWiseTimeSeries, tRes, .2);
        featureMatrix(globalIcCounter, 023:023) = featurefftcoarse(icWiseTimeSeries, tRes, .25);
        featureMatrix(globalIcCounter, 024:030) = featurefftfiner(icWiseTimeSeries, tRes, [.01 .025 .05 .1 .15 .2 .25]);
        featureMatrix(globalIcCounter, 031:038) = featurefftfinerwrtnull(icWiseTimeSeries, tRes, [.01 .025 .05 .1 .15 .2 .25]);
        featureMatrix(globalIcCounter, 039:044) = featuremotioncorrelation(icWiseTimeSeries, icaFolder);
        featureMatrix(globalIcCounter, 045:046) = abs(featureoupjk(icWiseTimeSeries, tRes));
        
        % % Spatial features
        featureMatrix(globalIcCounter, 047:055) = featureclusterdist(icaFolder, [xRes yRes zRes]);
        featureMatrix(globalIcCounter, 056:061) = featurenegativevspositive(icaFolder);
        featureMatrix(globalIcCounter, 062:065) = featurezstattofuncratio(icaFolder);
        featureMatrix(globalIcCounter, 066:069) = featureslicewisestats(icaFolder);
        featureMatrix(globalIcCounter, 070:073) = featureeverynthvarianve(icaFolder);
        featureMatrix(globalIcCounter, 074:085) = featuremasktscorrandoverlap(icaFolder, icWiseTimeSeries, imagePveSeg, meanCsfTimeSeries', meanGmTimeSeries', meanWmTimeSeries');
        featureMatrix(globalIcCounter, 086:086) = featuresmoothest(icaFolder);
        featureMatrix(globalIcCounter, 087:087) = featureMatrix(globalIcCounter,79)*xRes*yRes*zRes;
        featureMatrix(globalIcCounter, 088:090) = featuremaxtfce(icaFolder);
        featureMatrix(globalIcCounter, 091:105) = featureedgemasks(icaFolder);
        featureMatrix(globalIcCounter, 106:177) = featuresagmasks(icaFolder);
        featureMatrix(globalIcCounter, 178:178) = featurestripe(icaFolder);
        
        % % Image acquisition parameters
        featureMatrix(globalIcCounter, 179:186) = [xLen yLen zLen tLen xRes yRes zRes tRes];
        
        % % New features are to be added here
        % % FIRST, the number of features in the initialization line, i.e.,
        % % featureMatrix = zeros(numberOfIcs, 142)
        % % must change
        % % an example new feature can be added like:
        % % featureMatrix(globalIcCounter, 142:???) = ???
        
    end
    
    save(sprintf('%sfix/features.mat', icaFolder),'featureMatrix', 'featureMetaInfo');
    csvwrite(sprintf('%sfix/features.csv', icaFolder), featureMatrix);
    functioncell2csv(sprintf('%sfix/features_info.csv', icaFolder), featureMetaInfo);
    delete(sprintf('%sfix/dummy*', icaFolder));
catch
    diary('errorLog.txt');
    disp(['Error Time: ' datestr(now,'mm/dd/yyyy HH:MM:SS')]);
    % MATLAB has deprecated lasterror, but Octave doesn't support exception objects!
    s = lasterror;
    disp(s.message);
    disp(' ');
    diary off;
    exit(1);
end
disp('End of Matlab Script')
exit
