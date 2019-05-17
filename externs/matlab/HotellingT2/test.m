

clc;
mu = [2,3];
sigma = [2,1.5;1.5,4];
r = mvnrnd(mu,sigma,500);


R = hotelling.HotellingT2(r, 'ExpectedMean', mean(r)*1.2);

close all;
plot(r(:,1),r(:,2),'.')
hold on
plot(R.ellipse(:,1), R.ellipse(:,2))
plot(R.ellipseT2(:,1), R.ellipseT2(:,2), '--r')
legend('95% ellipse N', '95% ellipse T2');

%%

mu = [2,3,4];
sigma = [   5,      1.5,    3;
            1.5,    4,      2;
            3       2,      5];
r = mvnrnd(mu,sigma,500);

R = hotelling.HotellingT2(r, 'ExpectedMean', mean(r)*1.2);

figure
plot3(r(:,1),r(:,2),r(:,3),'.')
hold on

h = surfl(R.ellipse{1}, R.ellipse{2}, R.ellipse{3}); 
set(h, 'FaceAlpha', 0.2)
shading interp

h = surfl(R.ellipseT2{1}, R.ellipseT2{2}, R.ellipseT2{3}); 
set(h, 'FaceAlpha', 0.1)
shading interp

%legend('95% ellipse N', '95% ellipse T2');