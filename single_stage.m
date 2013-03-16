% mini project-DEVELOPMENT OF COMPUTER CODE FOR GAS TURBINE CYCLES
clc;
fig_num = 1;
fprintf('                  SINGLE STAGE compression expansion');
fprintf('\n Initializing...');
imshow('typical.gif');
clc;
fprintf('                  SINGLE STAGE compression expansion');
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
% inputs to the code
% helpdlg('\nThis program currently supports, piston-cylinder compressors.');
prompt1 = {'Input Pressure (bar): ','Inlet Temperature (K):','Maximum Cycle Temperature/Firing Temperatue(K):','Relative Humidity(%):','Mass Flow Rate(kg/s):','Pressure Ratio(compressor)','Turbine Exit Pressure:'};
% prompt5 = {'Input bore(mm):','Input Stroke(mm):','Input Speed(rpm):'};
prompt2 = {'Compressor Efficiency(0-1):','Turbine Efficiency(0-1):','Combustion Efficiency(0-1):','Regenerator Efficiency(0-1)','Calorific Value(kJ/kg):'};
prompt3={'gamma (Compression)','Cp(kj/kg-K)(compression)','gamma (expansion)','Cp(kj/kg-K)(expansion)'};
prompt4={'Pressure loss(delta p2) (% of p2)','Pressure loss(delta p3) (% of p3)','Number of steps/ resoultion(the more, the smoother) graph: ' };
name = 'Inputs for Gas Turbine Cycle:';
numlines = 1;
defaultanswer1={'1.013','300','1073','0.0','1','6','1.013'};
% defaultanswer5 = {'120','150','1200'};
defaultanswer2={'0.8','0.85','0.95','0.8','42000'};
defaultanswer3={'1.4','1.005','1.33','1.148'};
defaultanswer4={'3','3','1000'};
answer1=inputdlg(prompt1,name,numlines,defaultanswer1,options);
answer2=inputdlg(prompt2,name,numlines,defaultanswer2,options);
answer3=inputdlg(prompt3,name,numlines,defaultanswer3,options);
answer4=inputdlg(prompt4,name,numlines,defaultanswer4,options);
close all;
fprintf('\n Processing Provided Values...');
% answer5=inputdlg(prompt5,name,numlines,defaultanswer5,options);
format bank;
% convert cell to char and char to double
answer1=char(answer1);
answer1=str2num(answer1);
answer2=char(answer2);
answer2=str2num(answer2);
answer3=char(answer3);
answer3=str2num(answer3);
answer4=char(answer4);
answer4=str2num(answer4);
% answer5=char(answer5);
% answer5=str2num(answer5);
% assigning the values to rightful variables
r = 0.287; %gas constant
p1 = answer1(1); %inlet pressure
t1 = answer1(2); %inlet temp
t3 = answer1(3); %max temp in cycle
rh = answer1(4); %relative humidity
p4 = answer1(5); %turbine exhaust pressure
m = answer1(5); %mass flow rate
pr = answer1(6); %pressure ratio
nc = answer2(1); %compressor eff
nt = answer2(2); %turbine eff
ncomb = answer2(3); %combustion eff
epselon = answer2(4);
cv = answer2(5); %calorific value
gc = answer3(1); %gm for compression
cpc = answer3(2); %specific heat for compression
ge = answer3(3); %gm for expansion
cpe = answer3(4); %specific heat for expansion
dp2 = answer4(1); %delta p2
dp3 = answer4(2); %delta p3
resln = answer4(3);
% dia=answer5(1);
% stroke=answer5(2);
% rpm =answer5(3);
fprintf('\n Computing Parameters...Process 1-2');
es = 1.7526*10^8*exp(-5315.56/t1);
density = 3.4848*(p1*10^2-0.00376960*rh*es)*10^-3/t1;
v1 = m/density;
v2 = ((1/pr)^(1/gc))*v1;
% compressor work per unit mass
% PREPARE TO PLOT STAGE 1-2 PV AND TS DIAGRAM
p2=p1*pr;
v12 = linspace(v1,v2,resln);
p12 = (p1*v1^gc)./((v12).^(gc));
% prepare to plot TS diagram
t12dash = t1.*(p12).^((gc-1)/gc); %the final value would be t2' -READ T2 DASH
t12 = t1+(t12dash-t1)./nc; %actual; tdash is isentropic
t2=t12(length(t12));
warning('off','MATLAB:dispatcher:InexactCaseMatch');
fprintf('\n Computing Inital entropy');
s1 = Xsteam('s_pT',p1,t1-273); %initial entropy
s2 = s1; %isentropic compression
s12dash = linspace(s1,s2,resln);
s12 = cpc.*log(t12dash./t1)-r.*log(p12./p1)+s1;
hold on
plot(s12,t12,'--c'); %COLLECT ALL THESE SECOND AND PUT IT IN THIRD FIGURE
plot(s12dash,t12dash,':c');
fprintf('\n Computing Parameters...Process 2-3');
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
plot(s23,t23,'--r');
plot(s23dash,t23dash,':r');
% plot ts diagram for process3-4
fprintf('\n Computing Parameters...Process 3-4');
p3 = p2*(1-dp2/100)/(1+dp2/100);
p3dash = p3(1); %dash is isentropic
p4dash = p1; %p4 is provided by user
% will simulate linear relation now #else use valgen
p34 = linspace(p3,p4,resln);
p34dash = linspace(p3dash,p4dash,resln);
t34dash = t3.*(p34dash./p3).^((ge-1)/ge);
t34 = t3-nt.*(t3-t34dash);
s3 = s23(length(s23));
s4 = s3;
s34dash = linspace(s3,s4,resln);
s34 = cpe.*log(t34dash./t3)-0.287.*log(p34dash./p3)+s3;
plot(s34,t34,'--b');
plot(s34dash,t34dash,':r');
fprintf('\n Computing Parameters...Process 4-1');
% plot to 4-1
% will take linear variation of volume- should be consistent even if an
% piston cylinder engine is assumed and also coz of constant pressure stline
v4dash = v1*(p1/p4)^ge;
v4 = v4dash;
p41dash = linspace(p4dash,p1,resln);
p41 = linspace(p4,p1,resln);
t41dash = p41dash.*v4./0.287;
t41 = p41.*v4./0.287;
s4dash = s34dash(length(s34dash));
s4 = s34(length(s34));
t4dash = t34dash(length(t34dash));
t4 = t34(length(t34));
t41 = linspace(t4,t1,resln);
t41dash = linspace(t4dash,t1,resln);
s41dash = linspace(s4dash,s1,resln);
s41 = linspace(s4,s1,resln);
plot(s41,t41,'--b');
plot(s41dash,t41dash,':b');

fprintf('\n Plotting...');
figure(fig_num);
fig_num= fig_num+1;
hold on
plot(s12,t12,'--c'); %COLLECT ALL THESE SECOND AND PUT IT IN THIRD FIGURE
plot(s12dash,t12dash,':c');

plot(s23,t23,'--r');
plot(s23dash,t23dash,':r');

plot(s34,t34,'--b');
plot(s34dash,t34dash,':b');

plot(s41,t41,'--m');
plot(s41dash,t41dash,':m');
title('Temperature v/s Entropy Diagram');
xlabel('Entropy (kJ/K)');
ylabel('Temperature (K)');
leg_pos = legend('Process 1-2','Process 1-2(isentropic)','Process 2-3','Process 2-3(isentropic)',...
    'Process 3-4','Process 3-4 (isentropic)','Process 4-1','Process 4-1(isentropic)');
set(leg_pos,'Location','NorthWest')
fprintf('\n Now activating regenerator...');
fprintf('\n Computing...');
t5 = t3-epselon*(t3-t4);
wt = (1+1/af)*(cpe)*(t3-t4);
af_reg =(ncomb*cv-cpe*t3)/(cpe*(t3-t5));
qs_reg =(1+1/af_reg)*cpe*(t3-t5);
wt_reg = (1+1/af_reg)*(cpe)*(t3-t4);
%%%%%computations without regenerator
wc = cpc*(t2-t1);
wn = wt-wc;
wn_reg = wt_reg - wc;
n = wn/qs;
n_reg = wn_reg/qs_reg;
sfc = 3600/(af*wn);
sfc_reg = 3600/(af_reg*wn_reg);
p = m*wn;
p_reg = m*wn_reg;
fprintf('\n \n Parameters With regenerator...... ');
fprintf('\n Air fuel ratio                             : %.2f',af_reg);
fprintf('\n Heat Supplied per unit mass of air (kJ/kg) : %.2f',qs_reg);
fprintf('\n Specific Fuel Consumption (kg/kWh)         : %.2f',sfc_reg');
fprintf('\n Work Output(kJ/kg)                         : %.2f',wn_reg');
fprintf('\n Power output(kW)                           : %.2f ',p_reg);
fprintf('\n Efficiency of cycle (0-1)                  : %.2f',n_reg);
fprintf('\n \n Parameters WITHOUT regenerator...... ');
fprintf('\n Air fuel ratio                            : %.2f',af);
fprintf('\n Heat Supplied per unit mass of air (kJ/kg): %.2f',qs);
fprintf('\n Specific Fuel Consumption (kg/kWh)        : %.2f',sfc');
fprintf('\n Work Output(kJ/kg)                        : %.2f',wn');
fprintf('\n Power output(kW)                          : %.2f ',p);
fprintf('\n Efficiency of cycle (0-1)                 : %.2f\n ',n);
fprintf('\n \n');
close all;
% upto = input('Compute efficiency upto _____ pressure ratio: ');
% gm = input('Input gamma for efficiency calculation wrto pressure: ');
% % sir notes
% %t = 1073/300;
% %         for pr = 1:upto
% %             n = 1-(pr^(0.4/1.4))/t
% %             hold on
% %             plot(pr,n,'--b')
% %         end
% % university of waterloo
% % con = 1;
% % for pr = 1:upto
% %     n = 1-(pr^((1-gm)/gm));
% %     hold on
% %     x_axis(con) = pr;
% %     y_axis(con) = n;
% %     con = con+1;
% % end
% %     figure(fig_num);
% %     fig_num=fig_num+1;
% plot(x_axis,y_axis,'--r');
% title('Pressure ratio v/s Efficiency');
% xlabel('Pressure ratio');
% ylabel('Efficiency');
% con = 1;
% for pr = 1:upto
%     wnplot = ((t3/t1)-((t3/t1)/(pr^((gm-1)/gm))-(pr^((gm-1)/gm)+1)));
%     x_axis(con) = pr;
%     y_axis(con) = wnplot;
%     con = con+1;
% end
% figure(2)
% plot(x_axis,y_axis,'--b');
% title('Work(dimensionless) v/s Pressure Ratio');
% xlabel('Pressure Ratio');
% ylabel('Work(dimensionless)');
% my contribution
%     for pr = 1:upto
%         [n,n_reg,wn,wn_reg]=room(p1,r,t1,t3,rh,p4,m,pr,nc,nt,ncomb,epselon,cv,gc,cpc,ge,cpe,dp2,resln);
%         n_list(counter) = n;
%         n_reg_list(counter) = n_reg;
%         pr_list(counter) = pr;
%         counter  = counter +1;
%     end
%      figure(2);
%     plot(pr_list,n_list,'--b',pr_list,n_reg_list,':b');
%     title('Efficiency vs Pressure ratio');
%     legend('without regenerator','with regenerator');
%     xlabel('efficiency');
%     ylabel('pressure ratio');
% elseif decision == 2
%     fprintf('\n  Preparing to plot graph of effects of pressure ratio and max cycle temperature ratio on efficiency of a cycle\n');
%     numlines = 1;
%     name = '::t3 param::';
%     prompt = {'Max Cycle Temp:: from(K)','Max Cycle Temp:: upto(K)','And the number of times I must calculate?:'};
%     defans = {'600','1500','5'};
%     t = inputdlg(prompt,name,numlines,defans);
%     t = char(t);
%     t = str2num(t);
%     prompt_again={'Pressure ratio to begin with? :','And the Pressure ratio upto which I must calculate? :'};
%     prompt_once_again = {'One more thing... the gamma? : '};
%     defans_once_again = {'1.4'};
%
%     defans_again  = {'6','10'};
%     name = '::Pressure Ratio Range::';
%     pr_range= inputdlg(prompt_again,name,numlines,defans_again);
%     name ='::gamma::';
%     gm= inputdlg(prompt_once_again,name,numlines,defans_once_again);
%     gm = char(gm);
%     gm = str2num(gm);
%     pr_range = char(pr_range);
%     pr_range = str2num(pr_range);
%     pr_begin = pr_range(1);
%     pr_end = pr_range(2);
%     fprintf('\n Plotting!!!');
%     hold on
%     t3from = t(1);
%     t3to = t(2);
%     num_times = t(3);
%     t_mat = linspace(t3from,t3to,num_times);
%     %    close(gcf);
%     hold on
%     for loop_var = 1:num_times
%         t = t_mat(loop_var)/t1;
%         con = 1;
%         for pr = pr_begin:pr_end
%             n = 1-(pr^((1-gm)/gm))/t;
%             x_axis(con) = pr;
%             y_axis(con) = n;
%             con = con+1;
%         end
%         plot(x_axis,y_axis,'--r');
%     end
%     title('Pressure ratio v/s efficiency (with T3/T1 changing) (Please See Command Window)');
%     fprintf('\n Each line represents ratio=max_temperature/inlet_temperature varying,the top most is with maximum temperature ratio');
%     xlabel('pressure ratio');
%     ylabel('efficiency');
% elseif decision == 3
% %     imshow('thank_you.png');
% %     fprintf('Thank you \n Quitting...');
% end
% end
% close all;
% clc;clear all;close all;
% v = v1.*((p1./p).^(1./gc)); %the last term of this vector is v2
% % axis([xmin,xmax,ymin,ymax]) USE THIS BUT CREATE YMAX & XMAX SOME VALUE
% figure('Name','The PV diagram');
% hold on
% plot(v,p,':c');
% title('The PV diagram');
% xlabel('V ---------->');
% ylabel('P ---------->');