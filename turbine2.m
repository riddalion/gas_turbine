function [p4,wt,pOUT,pOUTdash,tOUTdash,tOUT,sOUT,sOUTdash,nt,ge,cpe]=turbine2(def_p4,def_nt,def_ge,def_cpe,sIN,tIN,pIN,resln)
%calculates the work done by the turbine
%PLOTs TS DIAGRAM
%pIN must be calculated considering the pressure drop till the turbine is
%reached
p3=pIN;
t3 = tIN; %we dont have a t3dash, hence, tINdash is not used in this function
p3dash = p3(1); %dash is isentropic
p4 = def_p4;
nt = def_nt;
ge = def_ge;
cpe = def_cpe;
p4dash = p4;
pOUT = p4;
pOUTdash = pOUT;
p34 = linspace(p3,p4,resln); %this is not used but still kept to have similarity with the original code snippet
p34dash = linspace(p3dash,p4dash,resln);
t34dash = t3.*(p34dash./p3).^((ge-1)/ge);
t34 = t3-nt.*(t3-t34dash);
tOUT = t34(length(t34));
tOUTdash = t34dash(length(t34dash));
s3 = sIN;
s4 = s3;
sOUTdash = s4;
s34dash = linspace(s3,s4,resln);
s34 = cpe.*log(t34dash./t3)-0.287.*log(p34dash./p3)+s3;
sOUT = s34(length(s34));
t4 = tOUT;
wt = cpe*(t3-t4);
%drawnow;