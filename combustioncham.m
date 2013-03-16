function [def_tMAX,def_cv,def_ncomb,def_cpe,tOUT,tOUTdash,sOUT,sOUTdash,maf,cv,ncomb,cpe] = combustioncham(tIN,tINdash,resln,sIN,sINdash)
%this calculates the parameters associated with combustion chamber
%show hlep dlg if the comb cham is second in line that mass air-fuel ratio
%needs to be re-considered because whatever is coming in exhaust gas from
%previous combustion chamber that has expanded in the turbine
prompt={'Maximum Cycle Temperature:','Calorific Value of Fuel:','Efficiency of Combustion Chamber:','Cp(kj/kg-K)(expansion)'};
name = 'Inputs for Gas Turbine Cycle:';
numlines = 1;
defaultresp={'1073','40000','0.90','1.148'};
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
resp=str2num(char(inputdlg(prompt,name,numlines,defaultresp,options)));
def_tMAX = resp(1);
def_cv = resp(2);
def_ncomb = resp(3);
def_cpe = resp(4);
tMAX = resp(1);
cv = resp(2);
ncomb = resp(3);
cpe = resp(4);
t2 = tIN; 
maf = (ncomb*cv-cpe*tMAX)/(cpe*(tMAX-t2));
t3 = tMAX; t2dash = tINdash; %isentropic
tOUT = tMAX; tOUTdash = tMAX;
s2 = sIN; s2dash = sINdash; 
t23dash = linspace(t2dash,t3,resln); %isentropic
% disp('inside cc')
qs = (1+1/maf)*cpe*(tOUT-tIN) ;%cpe available here
t23 = linspace(t2,t3,resln); %actual
q23 = linspace(0,qs,resln);
for loop = 1:length(q23)
    if loop==1
        s23(loop) = s2;
        s23dash(loop) = s2dash;
    else
        s23(loop) = q23(loop)/t23(loop)+ s2; %ds = dq/t where  s3 = (q-0)/t+s2
        s23dash(loop) = q23(loop)/t23dash(loop)+ s23dash(1);
    end
end
sOUT = s23(length(s23));
sOUTdash = s23dash(length(s23dash));
plot(s23,t23,'--r');
plot(s23dash,t23dash,':r');
%drawnow;