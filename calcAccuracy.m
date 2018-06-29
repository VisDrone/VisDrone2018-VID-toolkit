function [AP, AR, AP_all, AP_50, AP_75, AR_1, AR_10, AR_100, AR_500] = calcAccuracy(numSeqs, allgt, alldet)
%% claculate average precision and recall over all 10 IoU thresholds (i.e., [0.5:0.05:0.95]) of all avaliable object categories
AP = zeros(10, 10);
AR = zeros(10, 10, 4);
evalClass = [];

for idClass = 1:10
    disp(['evaluating object category ' num2str(idClass) '/10...'])    
    x = 0;
    % find the avaliable object categories
    for idSeq = 1:numSeqs
        gt = allgt{idSeq};
        if(nnz(gt(:, 8) == idClass))
            evalClass = cat(1, evalClass, idClass);
        end
    end
    
    for thr = 0.5:0.05:0.95
        disp(['evaluating IOU threshold ' num2str(x+1) '/10...'])    
        x = x + 1;
        y = 0;
        for maxDets = [1 10 100 500]
            y = y + 1;
            gtMatch = [];
            detMatch = [];    
            for idSeq = 1:numSeqs
                gt = allgt{idSeq};
                det = alldet{idSeq};  
                frs = unique(gt(:,1));
                for i = 1:numel(frs)
                    idxGtCurClass = gt(:, 1) == frs(i) & gt(:, 8) == idClass;
                    idxDetCurClass = det(:, 1) == frs(i) & det(:, 8) == idClass;
                    gt0 = gt(idxGtCurClass,3:7);
                    dt0 = det(idxDetCurClass,3:7); 
                    if(~isempty(dt0))
                        dt0 = dt0(1:min(size(dt0,1),maxDets),:);
                    end
                    [gt1, dt1] = evalRes(gt0, dt0, thr);
                    gtMatch = cat(1, gtMatch, gt1(:,5));
                    detMatch = cat(1, detMatch, dt1(:,5:6));
                end
            end 

            [~,idrank] = sort(-detMatch(:,1));
            tp = cumsum(detMatch(idrank,2)==1);
            rec = tp/max(1,numel(gtMatch));
            if(~isempty(rec))
                AR(idClass, x, y) = max(rec)*100;
            end
        end
        fp = cumsum(detMatch(idrank,2)==0);        
        prec = tp./max(1,(fp+tp));
        AP(idClass, x) = VOCap(rec,prec)*100;
    end
end

AP_all = mean2(AP(evalClass,:)); % calculate APmax=0.50:0.95
AP_50 = mean2(AP(evalClass,1)); % calculate APmax=0.50
AP_75 = mean2(AP(evalClass,6)); % calculate APmax=0.75
AR_1 = mean2(AR(evalClass,:,1)); % the maximum recall given 1 detection per frame
AR_10 = mean2(AR(evalClass,:,2)); % the maximum recall given 10 detections per frame
AR_100 = mean2(AR(evalClass,:,3)); % the maximum recall given 100 detections per frame
AR_500 = mean2(AR(evalClass,:,4)); % the maximum recall given 500 detections per frame

disp('Evaluation Completed. The peformance of the detector is presented as follows.')
