% to run this snippet the main part should have run once
fprintf('\n What do you want to plot now? (all of them are practical cycles)');
fprintf('\n The following graphs plot Pressure ratio v/s efficiency of cycle, Select the type you want::');
fprintf('\n 1. with regenerator SINGLE tMAX/tINLET     (takes AIR-FUEL RATIO)');
fprintf('\n 2. WITHOUT regenerator SINGLE tMAX/tINLET  (takes AIR-FUEL RATIO)');
fprintf('\n 3  with regenerator MULTIPLE tMAX/tINLET   (takes MAX CYCLE TEMP)');
fprintf('\n 4. WITHOUT regenerator MULTIPLE tMAX/tINLET(takes MAX CYCLE TEMP)');
fprintf('\n 5.EXIT');
your_choice = input('\n::Please enter your Choice::');
close all; clc;
looper =1;
% can_exit = false;
% fig_num = 1;
% fig_num = fig_num +1;
% figure(fig_num);
% while can_exit == false
switch your_choice
    case 1
        prompt = {'PressureRatio::from::','PressureRatio::to::'};
        numlines = 1;
        name = '::pressure ratio input::(with HX)';
        defans = {'2','8'};
        rangE = str2num(char(inputdlg(prompt,name,numlines,defans)));
        pr_start = rangE(1); pr_end = rangE(2);
        for pr = pr_start : pr_end
            [af_reg,qs_reg,sfc_reg,wn_reg,p_reg,n_reg,af,qs,sfc,wn,p,n]=single_stage_mute(r,p1,t1,t3,rh,p4,m ,pr,nc,nt,ncomb,epselon,cv,gc,cpc,ge,cpe,dp2,dp3,resln);
            
            if n_reg >= 0
                y_axis(looper) = n_reg;
                x_axis(looper) = pr;
                looper = looper+1;
            end
        end
        
        plot(x_axis,y_axis); hold off;
        title('pr v/s n with regenerator SINGLE tMAX/tINLET');
        xlabel('Pressure Ratio'); ylabel('Efficiency');
        looper = 1;
    case 2
        prompt = {'PressureRatio::from::','PressureRatio::to::'};
        numlines = 1;
        name = '::pressure ratio input::(without HX)';
        defans = {'2','8'};
        rangE = str2num(char(inputdlg(prompt,name,numlines,defans)));
        pr_start = rangE(1); pr_end = rangE(2);
        for pr = pr_start : pr_end
             [af_reg,qs_reg,sfc_reg,wn_reg,p_reg,n_reg,af,qs,sfc,wn,p,n]=single_stage_mute(r,p1,t1,t3,rh,p4,m ,pr,nc,nt,ncomb,epselon,cv,gc,cpc,ge,cpe,dp2,dp3,resln);
            if n >= 0
                y_axis(looper) = n;
                x_axis(looper) = pr;
                looper = looper+1;
            end
        end        
        plot(x_axis,y_axis,'--r'); title('pr v/s n WITHOUT regenerator SINGLE tMAX/tINLET');hold off;looper = 1;xlabel('Pressure Ratio'); ylabel('Efficiency');
    case 3
        prompt = {'Maximum Temperature cycle(1) : ','Maximum Temperature cycle(2)','Number of graphs betn these two limit: '};
        defaultanswer = {'600','1500','4'};
        resp = str2num(char(inputdlg(prompt,name,numlines,defaultanswer)));
        tMAX = linspace(resp(1),resp(2),resp(3));
        prompt = {'PressureRatio::from::','PressureRatio::to::'};
        numlines = 1;
        name = '::pressure ratio input::(without HX)';
        defans = {'2','8'};
        rangE = str2num(char(inputdlg(prompt,name,numlines,defans)));
        pr_start = rangE(1); pr_end = rangE(2);
        hold on
        for looper_case3=1: length(tMAX)
            for pr = pr_start:pr_end
%                                     fprintf('\nt4 = %.2f',t4);
%                                     fprintf('\nt3 = %.2f',tMAX(looper_case3));
%                                     fprintf('\nt2 = %.2f',t2);
%                                     fprintf('\nt5 = %.2f',t5);
%                                     fprintf('\npr = %.2f',pr);
                [af_reg,qs_reg,sfc_reg,wn_reg,p_reg,n_reg,af,qs,sfc,wn,p,n]=single_stage_mute(r,p1,t1,tMAX(looper_case3),rh,p4,m ,pr,nc,nt,ncomb,epselon,cv,gc,cpc,ge,cpe,dp2,dp3,resln);
%                                     fprintf('\nn_reg = %.2f',n_reg');
                if n_reg >= 0
                    y_axis(looper) = n_reg;
                    x_axis(looper) = pr;
                    looper = looper+1;
                end
            end
            if length(x_axis)>1 && length(y_axis)>1
                title('pr v/s n with regenerator MULTIPLE tMAX/tINLET');xlabel('Pressure Ratio'); ylabel('Efficiency');
                plot(x_axis,y_axis,'--r');
            end
            looper = 1;
            
        end
        hold off
    case 4
        prompt = {'Maximum Temperature cycle(1) : ','Maximum Temperature cycle(2)','Number of graphs betn these two limit: '};
        defaultanswer = {'600','1500','4'};
        resp = str2num(char(inputdlg(prompt,name,numlines,defaultanswer)));
        tMAX = linspace(resp(1),resp(2),resp(3));
        prompt = {'PressureRatio::from::','PressureRatio::to::'};
        numlines = 1;
        name = '::pressure ratio input::(without HX)';
        defans = {'2','8'};
        rangE = str2num(char(inputdlg(prompt,name,numlines,defans)));
        pr_start = rangE(1); pr_end = rangE(2);
        hold on
        for looper_case4=1: length(tMAX)
            for pr = pr_start : pr_end
                [af_reg,qs_reg,sfc_reg,wn_reg,p_reg,n_reg,af,qs,sfc,wn,p,n]=single_stage_mute(r,p1,t1,tMAX(looper_case4),rh,p4,m ,pr,nc,nt,ncomb,epselon,cv,gc,cpc,ge,cpe,dp2,dp3,resln);
                if n_reg >= 0
                    y_axis(looper) = n_reg;
                    x_axis(looper) = pr;
                    looper = looper+1;
                end
            end
            if length(x_axis)>1 && length(y_axis)>1
                title('pr v/s n WITHOUT regenerator MULTIPLE tMAX/tINLET');xlabel('Pressure Ratio'); ylabel('Efficiency');
                plot(x_axis,y_axis,'--b');
            end
            looper = 1;            
        end
    case 5
        can_exit = true;
        imshow('thank_you.png');
        break;
    otherwise
        fprintf('\n Oops! Sorry we did not understand what you meant.. \n Would mind trying again?');
end
% end