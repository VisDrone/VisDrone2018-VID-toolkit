function [allgt, alldet] = saveAnnoRes(gtPath, resPath, seqPath, numSeqs, nameSeqs, isNMS, nmsThre)
%% process the annotations and groundtruth
allgt = cell(1,numSeqs);
alldet = cell(1,numSeqs);

for idSeq = 1:numSeqs
    oldgt = load(fullfile(gtPath, nameSeqs{idSeq}));
    det = load(fullfile(resPath, nameSeqs{idSeq}));
    % remove the objects in ignored regions or labeled as others
    img = imread(fullfile(seqPath, nameSeqs{idSeq}(1:end-4), '0000001.jpg'));
    [imgHeight, imgWidth, ~] = size(img);     
    newgt = dropObjectsInIgr(oldgt, imgHeight, imgWidth);    
    gt = newgt;
    gt(newgt(:,7) == 0, 7) = 1;
    gt(newgt(:,7) == 1, 7) = 0; 
    % NMS
    newdet = nmsProcess(det, isNMS, nmsThre);
    [~, id] = sort(-newdet(:,7));
    allgt{idSeq} = gt;
    alldet{idSeq} = newdet(id,:);
end