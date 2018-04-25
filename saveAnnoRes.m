function [allgt, alldet] = saveAnnoRes(gtPath, resPath, numSeqs, nameSeqs)
%% process the annotations and groundtruth
allgt = cell(1,numSeqs);
alldet = cell(1,numSeqs);

for idSeq = 1:numSeqs
    oldgt = load(fullfile(gtPath, nameSeqs{idSeq}));
    det = load(fullfile(resPath, nameSeqs{idSeq}));
    % remove the objects in ignored regions or labeled as others
    gt = oldgt;
    gt(oldgt(:,7) == 0, 7) = 1;
    gt(oldgt(:,7) == 1, 7) = 0; 
    [~, id] = sort(-det(:,7));
    allgt{idSeq} = gt;
    alldet{idSeq} = det(id,:);
end