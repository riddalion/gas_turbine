function [tOUT,tOUTdash,sOUT,sOUTdash,maf,cv,ncomb,cpe] = combustioncham2(def_tMAX,def_cv,def_ncomb,def_cpe,tIN,tINdash,resln,sIN,sINdash)
%this calculates the parameters associated with combustion chamber
%show hlep dlg if the comb cham is second in line that mass air-fuel ratio
%needs to be re-considered because whatever is coming in exhaust gas from
%previous combustion chamber that has expanded in the turbine
tMAX=def_tMAX;
cv = def_cv;
ncomb=def_ncomb;
cpe=def_cpe;
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
%drawnow;