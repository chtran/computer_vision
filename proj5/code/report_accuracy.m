function [tpr, fpr, tnr, fnr] = report_accuracy( confidences, label_vector )
% by James Hays

% correct_classification = sign(confidences .* label_vector);

[confidences, ind] = sort(confidences, 'descend');
label_vector = label_vector(ind);

% accuracy = 1 - sum(correct_classification <= 0)/length(correct_classification);
% fprintf('  accuracy:   %.3f\n', accuracy);

true_positives = (confidences >= 0) & (label_vector >= 0);
tpr = sum( true_positives ) / length( true_positives);
fprintf('  true  positive rate: %.3f\n', tpr);

false_positives = (confidences >= 0) & (label_vector < 0);
fpr = sum( false_positives ) / length( false_positives);
fprintf('  false positive rate: %.3f\n', fpr);

true_negatives = (confidences < 0) & (label_vector < 0);
tnr = sum( true_negatives ) / length( true_negatives);
fprintf('  true  negative rate: %.3f\n', tnr);

false_negatives = (confidences < 0) & (label_vector >= 0);
fnr = sum( false_negatives ) / length( false_negatives);
fprintf('  false negative rate: %.3f\n', fnr);

npos = sum(label_vector == 1);

cum_fp=cumsum(label_vector == -1);
cum_tp=cumsum(label_vector ==  1);

recall=cum_tp/npos;
precision=cum_tp./(cum_fp+cum_tp);

average_precision=VOCap(recall,precision);
fprintf('   Average Precision: %.3f (chance %.3f)\n', average_precision, npos/length(label_vector));