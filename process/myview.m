function myview (x)
load('..\\output\\results.mat')
a = lab_truth;
b = squeeze(lab_measure(x,:,:));
c = dE(x,:);
myquiver3(a,b,c)
end

