function [tOUT,tOUTdash,sOUT,sOUTdash,maf,cv,ncomb,cpe] = reheater2(def_tOUT_rh,def_cv_rh,def_ncomb_rh,def_cpe_rh,tIN,tINdash,resln,sIN,sINdash)
%this calculates the parameters associated with the reheater (same as cc,
%only taking cpg instead of cpa
tOUT = def_tOUT_rh;
cv = def_cv_rh;
ncomb = def_ncomb_rh;
cpe = def_cpe_rh;
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
%drawnow;