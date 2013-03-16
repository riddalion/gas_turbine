function  [def_tOUT_rh,def_cv_rh,def_ncomb_rh,def_cpe_rh,tOUT,tOUTdash,sOUT,sOUTdash,maf,cv,ncomb,cpe] = reheater(tIN,tINdash,resln,sIN,sINdash)
%this calculates the parameters associated with the reheater (same as cc,
%only taking cpg instead of cpa
prompt={'Maximum Cycle Temperature:','Calorific Value of Fuel:','Efficiency of Combustion Chamber:','Cp(kj/kg-K)(expansion)'};
name = 'Inputs for Gas Turbine Cycle:';
numlines = 1;
defaultanswer={'1073','42000','0.90','1.148'};
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer=str2num(char(inputdlg(prompt,name,numlines,defaultanswer,options)));
tOUT = answer(1);
cv = answer(2);
ncomb = answer(3);
cpe = answer(4);
cpg = 1.148;
def_tOUT_rh  = answer(1);
def_cv_rh = answer(2);
def_ncomb_rh = answer(3);
def_cpe_rh = answer(4);
maf = (ncomb*cv-cpe*tOUT)/(cpe*(tOUT-tIN));
tOUTdash = tOUT;
t2 = tIN; t3 = tOUT; t2dash = tINdash; %isentropic
s2 = sIN; s2dash = sINdash; 
t23dash = linspace(t2dash,t3,resln); %isentropic
qs = (1+1/maf)*cpe*(tOUT-tIN); %cpe available here
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