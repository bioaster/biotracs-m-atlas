% sMBbpls_plot_results('./decomposition','XY-f0.mat',30,1,'default');
function sMBbpls_plot_results(dataFile,nLV,fig1,fig2,colormap_type)
global Tb Pb Wb Wt Tt Ub Qb Wu Tu
GRAY=[0.4,0.4,0.4];
BARWIDTH=0.4;
load(dataFile);
nbX = size(data.Xin,1); % nbX : #blocks in X
nbY = size(data.Yin,1); % nbY : #blocks in Y
for i=1:nLV,
    fprintf('Latent factor %d\n',i);
    ti=find(Tt(:,i));
    ui=find(Tu(:,i));
    selected_samples=intersect(ti,ui);
    selected_samples=sort_vector(Tt(selected_samples),selected_samples);
    if (isempty(selected_samples)), continue; end
    
    for aa=1:nbY,
        rowi = data.Yin(aa,1):data.Yin(aa,2);
        Yb = data.Y(:,rowi);
        YYb=rescale(Yb);
        q = Qb(rowi,i);
        qi = find(q);
        qi = sort_vector(q(qi),qi);
        
        figure(fig1+i-1);
        subplot(2,nbX+nbY,nbX+aa);
        C=exp_colormap(colormap_type,64);
        image(YYb(selected_samples,qi)*64);
        colormap(gca,C);
        set(gca,'YTick',1:length(selected_samples),'YTickLabel',selected_samples,'XTick',1:length(qi),'XTickLabel',qi);
        title(['Y' num2str(aa)]); xlabel(['feature subset ' num2str(aa)  ' (' num2str(length(qi)) ')']); ylabel(['sample (' num2str(length(selected_samples)) ')']);
    end
    for aa=1:nbX,
        rowi = data.Xin(aa,1):data.Xin(aa,2);
        Xb = data.X(:,rowi);
        XXb=rescale(Xb);
        w = Wb(rowi,i);
        wi = find(w);
        wi = sort_vector(w(wi),wi);
        
        figure(fig1+i-1);
        subplot(2,nbX+nbY,aa);
        C=exp_colormap(colormap_type,64);
        image(XXb(selected_samples,wi)*64);
        colormap(gca,C);
        set(gca,'YTick',1:length(selected_samples),'YTickLabel',selected_samples,'XTick',1:length(wi),'XTickLabel',wi);
        title(['X' num2str(aa)]); xlabel(['feature subset ' num2str(aa)  ' (' num2str(length(wi)) ')']); ylabel(['sample (' num2str(length(selected_samples)) ')']);
        
        subplot(2,nbX+nbY,nbX+nbY+aa);
        plot(Tb(selected_samples,(i-1)*nbX+aa),Ub(selected_samples,i),'*k');
    end
end

function newLabels=sort_vector(vec,labels)
[tmp,sorti]=sort(vec);
newLabels=labels(sorti);

function newX=rescale(X)
minX=min(min(X));
maxX=max(max(X));
if (minX==maxX),
    newX=X;
else
    newX = (X-minX)/(maxX-minX);
end