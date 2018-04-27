function displaySeq(seqPath, numSeqs, nameSeqs, allgt, alldet, isSeqDisplay) 
%% show the groundtruth and detection results
if(isSeqDisplay)
    for idSeq = 2%1:numSeqs
        dataset = dir(fullfile(seqPath, nameSeqs{idSeq}(1:end-4), '*.jpg'));
        gt = allgt{idSeq};
        det = alldet{idSeq};
        for idFr = 1:length(dataset)
            img = imread(fullfile(seqPath, nameSeqs{idSeq}(1:end-4), dataset(idFr).name));
            if(idFr == 1)
                [height, width, ~] = size(img);
            end
            mask = false(height, width);
            curgt = gt(gt(:,1) == idFr, :);
            curdet = det(det(:,1) == idFr, :);
            % show the ignored regions
            idxIgnore = find(curgt(:,8) == 0);
            for k = 1:numel(idxIgnore)
                ignorePos = gt(idxIgnore(k),1:4);
                mask(max(1,ignorePos(2)):min(height,ignorePos(2)+ignorePos(4)), max(1,ignorePos(1)):min(width,ignorePos(1)+ignorePos(3))) = true;
            end
            for c = 1:3
                tmp = img(:,:,c);
                tmp(mask) = max(0,tmp(mask) - 100);
                img(:,:,c) = tmp;
            end
            figure(1),imshow(img); hold on;
            % show the detections
            for k = 1:size(curdet,1)
                rectangle('position', curdet(k,3:6), 'linewidth', 1, 'edgecolor', 'r');            
            end          
            % show the groundtruth
            idxObject = find(curgt(:,8) ~= 0);
            for k = 1:numel(idxObject)
                rectangle('position', curgt(idxObject(k),3:6), 'linewidth', 2, 'edgecolor', 'g');
            end
            text(5,30,['#' num2str(idFr) '/' num2str(length(dataset))], 'Color','red','FontSize',15);
            title([num2str(idSeq) '/' num2str(numSeqs)  '-->{\color{black}ignored / \color{green}groundtruth / \color{red}detection}']);
            pause(0.01);
        end
        close all;
    end
end