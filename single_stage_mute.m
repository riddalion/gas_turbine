function [af_reg,qs_reg,sfc_reg,wn_reg,p_reg,n_reg,af,qs,sfc,wn,p,n]=single_stage_mute(r,p1,t1,tMAX,rh,p4,m ,pr,nc,nt,ncomb,epselon,cv,gc,cpc,ge,cpe,dp2,dp3,resln)
t3 = tMAX;
es = 1.7526*10^8*exp(-5315.56/t1);
density = 3.4848*(p1*10^2-0.00376960*rh*es)*10^-3/t1;
v1 = m/density;
v2 = ((1/pr)^(1/gc))*v1;
%compressor work per unit mass
%PREPARE TO PLOT STAGE 1-2 PV AND TS DIAGRAM
p2=p1*pr;
v12 = linspace(v1,v2,resln);
p12 = (p1*v1^gc)./((v12).^(gc));
%prepare to plot TS diagram
t12dash = t1.*(p12).^((gc-1)/gc); %the final value would be t2' -READ T2 DASH
t12 = t1+(t12dash-t1)./nc; %actual; tdash is isentropic
t2=t12(length(t12));
warning('off','MATLAB:dispatcher:InexactCaseMatch');
s1 = Xsteam('s_pT',p1,t1-273); %initial entropy
s2 = s1; %isentropic compression
s12dash = linspace(s1,s2,resln);
s12 = cpc.*log(t12dash./t1)-r.*log(p12./p1)+s1;
%process 2-3
af = (ncomb*cv-cpc*t3)/(cpe*(t3-t2));
qs = (1+1/af)*cpe*(t3-t2);
t2dash = t12dash(length(t12dash)); %isentropic
t2 = t12(length(t12)); %actual
t23dash = linspace(t2dash,t3,resln); %isentropic
t23 = linspace(t2,t3,resln); %actual
q23 = linspace(0,qs,resln);
for loop = 1:length(q23)
    if loop==1
        s23(loop) = s2;
        s23dash(loop) = s12dash(length(s12dash));
    else
        s23(loop) = q23(loop)/t23(loop)+ s2; %ds = dq/t where  s3 = (q-0)/t+s2
        s23dash(loop) = q23(loop)/t23dash(loop)+ s23dash(1);
    end
end
%plot ts diagram for process3-4
% fprintf('\n Computing Parameters...Process 3-4');
p3 = p2*(1-dp2/100)/(1+dp2/100);
p3dash = p3(1); %dash is isentropic
p4dash = p1; %p4 is provided by user
%will simulate linear relation now #else use valgen
p34 = linspace(p3,p4,resln);
p34dash = linspace(p3dash,p4dash,resln);
t34dash = t3.*(p34dash./p3).^((ge-1)/ge);
t34 = t3-nt.*(t3-t34dash);
s3 = s23(length(s23));
s4 = s3;
s34dash = linspace(s3,s4,resln);
s34 = cpe.*log(t34dash./t3)-0.287.*log(p34dash./p3)+s3;
%plot to 4-1
s4dash = s34dash(length(s34dash));
s4 = s34(length(s34));
t4dash = t34dash(length(t34dash));
t4 = t34(length(t34));
t41 = linspace(t4,t1,resln);
t41dash = linspace(t4dash,t1,resln);
s41dash = linspace(s4dash,s1,resln);
s41 = linspace(s4,s1,resln);
%plot stuffs done, the main things now
t5 = t3-epselon*(t3-t4);
wt = (1+1/af)*(cpe)*(t3-t4);
af_reg =(ncomb*cv-cpe*t3)/(cpe*(t3-t5));
qs_reg = (1+1/af_reg)*cpe*(t3-t5);
wt_reg = (1+1/af_reg)*(cpe)*(t3-t4);
wc = cpc*(t2-t1);
wn = wt-wc;
wn_reg = wt_reg - wc;
n = wn/qs;
n_reg = wn_reg/qs_reg;
sfc = 3600/(af*wn);
sfc_reg = 3600/(af_reg*wn_reg);
p = m*wn;
p_reg = m*wn_reg;