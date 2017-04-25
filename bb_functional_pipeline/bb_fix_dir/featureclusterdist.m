function feat = featureclusterdist(strFold, xSiz)
% this feature tries to quantify the number of clusters in a component
global icThreshold;
call_fsl(sprintf('cluster --in=%sfix/dummyabs --thresh=%f > %sfix/dummy1', strFold, icThreshold, strFold));
counter = 0;
fid = fopen(sprintf('%sfix/dummy1', strFold));
tline = fgetl(fid);
while 1, counter = counter + 1;
    tline = fgetl(fid);
    if ~ischar(tline),   break,   end;            
    C = textscan(tline, '%d %d %f %f %f %f %f %f %f');
    drow(counter,:) = [counter C{1} C{2} ];
end; 
fclose(fid);
delete(sprintf('%sfix/dummy1*', strFold));

% get all the cluster size
if counter>1    
    X = double(drow(:,3));
    X = X(X>4);
    if(length(X)<3), X = [X; zeros(3-length(X),1)]; end
    Y = sort(X, 'descend')*xSiz(1)*xSiz(2)*xSiz(3);
    feat = [length(X) mean(X)-median(X) max(X) var(X) skewness(X) kurtosis(X) Y(1) Y(2) Y(3)];
else
    feat = [0 0 0 0 0 1.5 0 0 0];
end

end
