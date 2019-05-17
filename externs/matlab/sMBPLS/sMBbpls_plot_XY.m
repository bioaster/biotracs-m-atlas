% colormap_type can be 'colormap_type', 'green-red', 'yellow', 'default'
function sMBbpls_plot_XY(dataFile,fig,figure_title,colormap_types,iFactor,nTopRank)
global Tb Pb Wb Wt Tt Ub Qb Wu Tu
load(dataFile);
K=size(data.X,1);
nbX = size(data.Xin,1); % nbX : #blocks in X
nbY = size(data.Yin,1); % nbY : #blocks in Y
if nargin==4,
    sampleSort=[1:K]'; % keep original order
    for aa=1:nbX,
        XfeatureSort{aa,1}=[1:(data.Xin(aa,2)-data.Xin(aa,1)+1)]'; % keep original order
    end
    for aa=1:nbY,
        YfeatureSort{aa,1}=[1:(data.Yin(aa,2)-data.Yin(aa,1)+1)]'; % keep original order
    end
    colormap_type='default';
else
    [tmp,sampleSort]=sort(Tt(:,iFactor),'descend');
    for aa=1:nbX,
        rowi = data.Xin(aa,1):data.Xin(aa,2);
        [tmp,XfeatureSort{aa,1}]=sort(Wb(rowi,iFactor),'descend');
    end
    for aa=1:nbY,
        rowi = data.Yin(aa,1):data.Yin(aa,2);
        [tmp,YfeatureSort{aa,1}]=sort(Qb(rowi,iFactor),'descend');
    end
end
if nargin<=5,
    nTopRank=max(size(data.X,2),size(data.Y,2));
end
listTopRankSample=1:min(K,nTopRank);
figure(fig);
%set(gcf,'name',figure_title,'numbertitle','off');
set(gcf,'name',figure_title);
for aa=1:nbX,
    rowi = data.Xin(aa,1):data.Xin(aa,2);
    listTopRankSFeature=1:min(length(rowi),nTopRank);
    Xb = data.X(:,rowi);
    subplot(1,nbX+nbY,aa);
%    figure(fig+aa);
    C=exp_colormap(colormap_types{aa},64);
    h=image(Xb(sampleSort(listTopRankSample),XfeatureSort{aa}(listTopRankSFeature)));
    colormap(gca,C);
%    set(gca,'YTick',1:length(sampleSort),'YTickLabel',sampleSort(listTopRankSample),'XTick',1:length(XfeatureSort{aa}(listTopRankSFeature)),'XTickLabel',XfeatureSort{aa}(listTopRankSFeature));
    set(h,'CDataMapping','scaled');
    set(gca,'FontSize',14,'TickLength',[0;0.1],'XTick',[1 50:50:length(XfeatureSort{aa}(listTopRankSFeature))]);
    if (aa==1),
        set(gca,'TickLength',[0;0.1],'YTick',[1 20:20:length(sampleSort)]);
    end
    title(['X' num2str(aa)]); %xlabel(['feature set ' num2str(aa)]); ylabel('samples');
end
for aa=1:nbY,
    rowi = data.Yin(aa,1):data.Yin(aa,2);
    listTopRankSFeature=1:min(length(rowi),nTopRank);
    Yb = data.Y(:,rowi);
    subplot(1,nbX+nbY,nbX+aa);
%    figure(fig+nbX+aa);
    C=exp_colormap(colormap_types{nbX+aa},64);
    colormap(C);
    h=image(Yb(sampleSort(listTopRankSample),YfeatureSort{aa}(listTopRankSFeature)));
%    set(gca,'YTick',1:length(sampleSort),'YTickLabel',sampleSort(listTopRankSample),'XTick',1:length(YfeatureSort{aa}(listTopRankSFeature)),'XTickLabel',YfeatureSort{aa}(listTopRankSFeature));
    set(h,'CDataMapping','scaled');
    set(gca,'FontSize',14,'TickLength',[0;0],'XTick',[1 50:50:length(YfeatureSort{aa}(listTopRankSFeature))]);
    title('Y'); %xlabel(['feature set ' num2str(aa)]); ylabel('samples');
end