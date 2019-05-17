function randpartitions=rand_nFold(n,nfold)
randpartitions=cell(nfold,1);
sizePartition=ceil(n/nfold);
r = randperm(n);
base=1;
for i=1:(nfold-1),
    randpartitions{i,1}=r((base:(base+sizePartition-1)))';
    base = base+sizePartition;
end
randpartitions{nfold,1}=r(base:n)';