% to run this snippet the main part should have run once
fprintf('\n What do you want to plot now? (all of them are practical cycles)');
fprintf('\n **Single is a special case of multiple** ');
fprintf('\n Pressure ratio versus Efficiency and Pressure ratio versus Work (dimensionless)');
fprintf('\n 1  with regenerator MULTIPLE tMAX/tINLET   (takes MAX CYCLE TEMP)');
fprintf('\n 2. WITHOUT regenerator MULTIPLE tMAX/tINLET(takes MAX CYCLE TEMP)');
fprintf('\n 3.EXIT');
your_choice = input('\n::Please enter your Choice::');
close all; clc;
looper =1;
switch your_choice
    case 1
        prompt = {'Maximum Temperature cycle(1) : ','Maximum Temperature cycle(2)','Number of graphs betn these two limit: '};
        defaultanswer = {'600','1500','4'};
        name = '::INPUTS::';
        resp = str2num(char(inputdlg(prompt,name,numlines,defaultanswer)));
        tMAX_array = linspace(resp(1),resp(2),resp(3));
        prompt = {'PressureRatio::from::','PressureRatio::to::'};
        numlines = 1;
        name = '::pressure ratio input::(without HX)';
        defans = {'2','8'};
        rangE = str2num(char(inputdlg(prompt,name,numlines,defans)));
        pr_start = rangE(1); pr_end = rangE(2);
        hold on
        for looper_case=1: length(tMAX_array)
            tMAX=tMAX_array(looper_case);
            for pr = pr_start:pr_end
                multi_stage_mute;
                if n_reg >= 0
                    y_axis(looper) = n_reg;
                    x_axis(looper) = pr;
                    y_work_axis(looper) = wn_reg/(cpc*t1);
                    looper = looper+1;
%                       plot(pr,n_reg,'*r');
                end
            end
            if length(x_axis)>1 && length(y_axis)>1
                title('pr v/s n with regenerator MULTIPLE tMAX/tINLET');xlabel('Pressure Ratio'); ylabel('Efficiency');
                plot(x_axis,y_axis,'--r',x_axis,y_work_axis,':g');
                legend('efficiency','work');
            end
            looper = 1;            
        end
        hold off
    case 2
        prompt = {'Maximum Temperature cycle(1) : ','Maximum Temperature cycle(2)','Number of graphs betn these two limit: '};
        name = '::INPUTS::';
        defaultanswer = {'600','1500','4'};
        resp = str2num(char(inputdlg(prompt,name,numlines,defaultanswer)));
        tMAX_array = linspace(resp(1),resp(2),resp(3));
        prompt = {'PressureRatio::from::','PressureRatio::to::'};
        numlines = 1;
        name = '::pressure ratio input::(with HX)';
        defans = {'2','8'};
        rangE = str2num(char(inputdlg(prompt,name,numlines,defans)));
        pr_start = rangE(1); pr_end = rangE(2);
        hold on
        looper = 1;
        for looper_case=1: length(tMAX_array)
            tMAX=tMAX_array(looper_case);
            for pr = pr_start:pr_end
                multi_stage_mute;
                if n >= 0
                    y_axis(looper) = n;
                    x_axis(looper) = pr;
                    y_work_axis(looper) = wn/(cpc*t1);
                    looper = looper+1;
                end
            end
            if length(x_axis)>1 && length(y_axis)>1
                title('pr v/s n WITHOUT regenerator MULTIPLE tMAX/tINLET');xlabel('Pressure Ratio'); ylabel('Efficiency');
                plot(x_axis,y_axis,'--b',x_axis,y_axis,':g');
                legend('efficiency','work');
            end
            looper = 1;            
        end
    case 3
        can_exit = true;
        imshow('thank_you.png');
        break;
    otherwise
        fprintf('\n Oops! Sorry we did not understand what you meant.. \n Would mind trying again?');
end
% end