% check the LAB calculation by visualizing as a colorchecker
for i = 1:7
    subplot(2,4,i)
    lab = squeeze(lab_measure(i,:,:));
    lab2colorchecker24(lab);
    title(sprintf('CIELAB #%d',i))
end

subplot(2,4,8)
lab = squeeze(lab_truth);
lab2colorchecker24(lab);
title('Truth')

