function [def_nc,def_pr,def_gc,def_cpc,nc,pr,gc,cpc,rh,wc,pOUT,tOUTdash,tOUT,sOUT,sOUTdash]=compressor(once_only,m,sIN,sINdash,tIN,tINdash,pIN,rh,resln)
%calculates the work absorbed by the compressor
%PLOTs TS DIAGRAM
prompt = {'Efficiency of the Compressor: ','Pressure Ratio','gamma (compression)','Cp (Compression) kJ/kg-K'};
name = 'Inputs for Gas Turbine Cycle:';
numlines = 1;
defaultanswer={'0.8','6','1.4','1.005'};
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer=str2num(char(inputdlg(prompt,name,numlines,defaultanswer,options)));
def_nc = answer(1);
def_pr = answer(2);
def_gc = answer(3);
def_cpc = answer(4);
nc = answer(1);
pr = answer(2);
gc = answer(3);
cpc = answer(4);
t1 = tIN;
t1dash = tINdash;
p1=pIN;
p2=p1*pr;
es = 1.7526*10^8*exp(-5315.56/t1);
% fprintf('rh before:%d',rh);
%%%%%%%%%%%%%%%%%%% calculate relative humidity variation with compression
%first time rh comes directly from user second time it is calculated, it is
%then whatever value entered by default into this function is over-written 
p_sat_inlet_temp = xsteam('psat_T',tIN-273); %answer in bar
pv1 = (rh/100)*100*p_sat_inlet_temp; %converted to kPa, rh fed in as percentage
omega = (0.622*pv1)/(100-pv1); %kg of water per kg of dry air
texit = tIN*(pr)^((gc-1)/gc); %answer in kelvin
pg2 = 100*xsteam('psat_T',(texit-273)); %answer in bar, input in deg , converted to kPa by ans x 100
pv2 = omega*p2*100/(omega+0.622); %answer in kpa
rh = pv2/pg2; %answer in percentage
% fprintf('rh after:%d',rh );
density = 3.4848*(p1*10^2-0.00376960*rh*es)*10^-3/t1;
v1 = m/density;
v2 = ((1/pr)^(1/gc))*v1;
v12 = linspace(v1,v2,resln);
p12 = (p1*v1^gc)./((v12).^(gc));
%prepare to plot TS diagram
t12dash = t1.*(p12).^((gc-1)/gc); %the final value would be t2' -READ T2 DASH
t12 = t1+(t12dash-t1)./nc; %actual; tdash is isentropic
t2=t12(length(t12));
t2dash=t12dash(length(t12dash));
pOUT = p2;
tOUT = t2;
tOUTdash = t2dash;
warning('off','MATLAB:dispatcher:InexactCaseMatch');
% fprintf('\n Computing Inital entropy');
if once_only
s1 = Xsteam('s_pT',p1,t1-273); %initial entropy
s2 = s1; %isentropic compression
s12dash = linspace(s1,s2,resln);
else
    s1 = sIN;
    s2 = s1;
    s12dash = linspace(sINdash,s2,resln);
end
% for loop = 1:resln %%%%%THIS DOESNOT WORK
%  s12(loop) = Xsteam('s_pT',p12(loop),t12(loop)-273);
% end
% for loop = 1:resln
%  s12dash(loop) = Xsteam('s_pT',p12(loop),t12dash(loop)-273);
% end
s12 = cpc.*log(t12dash./t1)-0.287.*log(p12./p1)+s1;
sOUT = s12(length(s12));
sOUTdash = s12dash(length(s12dash));
hold on
plot(s12,t12,'--c');
plot(s12dash,t12dash,':c');
wc = cpc*(t2-t1);
%drawnow; %try update the plot without erase