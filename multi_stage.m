clc;
fprintf('                        ::MULTI STAGE CYCLE::');
cycle_incomplete=true;
regen = 0 ;
comp_work = 0;
turbo_work = 0;
heat_added = 0;
once_only = true ;
format long e;
dev_seq = zeros();  %store params for combustion cham %cycle temp %cv %ncomb %maf
counter = 1 ; %combustion chamber param counter
while cycle_incomplete %go on adding.. go on adding
    prompt=sprintf('\n1.Compressor\n2.InterCooler\n3.CombustionChamber\n4.Turbine\n5.Reheater\n6.Add Regenerator & EndCycle') ;
    defaultanswer={''} ;
    name = '::INPUT for Gas Turbine Cycles::' ;
    numlines = 1 ;
    options.Resize='on' ;
    options.WindowStyle='normal' ;
    options.Interpreter='tex' ;
    setmac=(inputdlg(prompt,name,numlines,defaultanswer,options)) ;
    setmac = char(setmac) ;
    setmac = str2num(setmac) ;
    switch setmac
        case 1
            if once_only
                %                 helpdlg('You will be asked to key in "Resolution of Graph".(Number of points per process to plot), the more you put the slower the computation, but smoother the graph')
                prompt = {'Relative Humidity(in %):','Mass flow Rate:(kg/s)','Ambient Temp:(K)','Temperature Inlet to Compressor(K)','Inlet Pressure (bar)','Resolution of Graph:'} ;
                options.Resize='on' ;
                options.WindowStyle='normal' ;
                options.Interpreter='tex' ;
                name = '::Inputs for Gas Turbine Cycle::' ;
                numlines = 1 ;
                defaultanswer = {'0.0','1','300','300','1.013','1000'} ;
                answer=str2num(char(inputdlg(prompt,name,numlines,defaultanswer,options))) ;
                rh=answer(1);
                m = answer(2);
                tAMB = answer(3);
                tIN = answer(4);
                t1 = tIN ;
                tINdash = tIN;
                pIN = answer(5);p1 = pIN;
                resln = answer(6) ;
                dev_seq(6,counter) = resln;
                dev_seq(7,counter) = rh;
                dev_seq(8,counter) = m;
                dev_seq(9,counter) = tAMB;
                dev_seq(10,counter) = t1;
                dev_seq(11,counter) = p1;  
                warning('off','MATLAB:dispatcher:InexactCaseMatch') ;
                s1 = Xsteam('s_pT',pIN,tIN-273);  %initial entropy;
                sIN = s1 ;
                sINdash = s1 ;
                once_only = false ;
                dev_seq(2,counter) = tIN ;
            end
            [def_nc,def_pr,def_gc,def_cpc,nc,pr,gc,cpc,rh,wc,pOUT,tOUTdash,tOUT,sOUT,sOUTdash]=compressor(once_only,m,sIN,sINdash,tIN,tINdash,pIN,rh,resln) ;
            dev_seq(12,counter) = def_nc;
            dev_seq(13,counter) = def_pr;
            dev_seq(14,counter) = def_gc;
            dev_seq(15,counter) = def_cpc;
            comp_work = comp_work+wc ;
            pBUFF = pOUT;  %allowed to update
            dev_seq(1,counter) = setmac ;
            dev_seq(3,counter) = tOUT ;
            counter = counter+1 ;
        case 2
            dev_seq(2,counter) = tIN ;
            [def_nic,tOUT,tOUTdash,sOUT,sOUTdash,nic]=intercooler(m,cpc,tIN,tINdash,tAMB,sIN,sINdash,resln);
            dev_seq(4,counter) = def_nic;
            dev_seq(1,counter) = setmac ;
            dev_seq(3,counter) = tOUT ;
            counter = counter+1 ;
        case 3
            dev_seq(1,counter) = setmac ;
            dev_seq(2,counter) = tIN ;
           [def_tMAX,def_cv,def_ncomb,def_cpe,tOUT,tOUTdash,sOUT,sOUTdash,maf,cv,ncomb,cpe] = combustioncham(tIN,tINdash,resln,sIN,sINdash) ;
%             disp(ncomb);
            dev_seq(3,counter) = tOUT ;
            dev_seq(4,counter) = maf ;
            dev_seq(5,counter) = cv ;
            dev_seq(6,counter) = ncomb             ;
%             disp('outside cc') ;
            qs = (1+1/maf)*cpe*(tOUT-tIN); %cpe available here
            heat_added = heat_added+qs ;
            t3 = tOUT;  %update allowed, I need temp b4 entering the cc
            counter = counter+1 ;
        case 4
            dev_seq(2,counter) = tIN ;
            prompt={'Pressure Loss if any from last exit point to, till here:(in Percentage)'} ;
            name = 'Inputs for Gas Turbine Cycle:' ;
            numlines = 1;
            defaultanswer = {'3'};
            dp=str2num(char(inputdlg(prompt,name,numlines,defaultanswer,options))) ;
            def_dp = dp;
            dev_seq(4,counter) = dp;
            pIN = (1-dp*0.01)/(1+dp*0.01)*pBUFF ;
            [def_p4,def_nt,def_ge,def_cpe,p4,wt,pOUT,pOUTdash,tOUTdash,tOUT,sOUT,sOUTdash,nt,ge,cpe]=turbine(sIN,tIN,pIN,resln) ;
            dev_seq(5,counter) = def_p4;
            dev_seq(6,counter) = def_nt;
            dev_seq(7,counter) = def_ge;
            dev_seq(8,counter) = def_cpe;
            t4 = tOUT ; %update allowed
            pBUFF_turbo = pOUT ;
            turbo_work = turbo_work+wt ;
            s4 = sOUT;
            s4dash = sOUTdash ;
            t4dash = tOUTdash ;
            dev_seq(1,counter) = setmac ;
            dev_seq(3,counter) = tOUT ;
            counter = counter+1 ;
        case 5
            dev_seq(1,counter) = setmac ;
            dev_seq(2,counter) = tIN ;            
            [def_tOUT_rh,def_cv_rh,def_ncomb_rh,def_cpe_rh,tOUT,tOUTdash,sOUT,sOUTdash,maf,cv,ncomb,cpe]= reheater(tIN,tINdash,resln,sIN,sINdash) ;            
            qs = (1+1/maf)*cpe*(tOUT-tIN); %cpe available here
            heat_added = heat_added+qs ;
            dev_seq(7,counter) = def_tOUT_rh;
            dev_seq(8,counter) = def_cv_rh;
            dev_seq(9,counter) = def_ncomb_rh;
            dev_seq(10,counter) = def_cpe_rh;
            dev_seq(3,counter) = tOUT ;
            dev_seq(4,counter) = maf ;
            dev_seq(5,counter) = cv ;
            dev_seq(6,counter) = ncomb ;
            counter = counter+1 ;
            t3 = tOUT;
        case 6
            dev_seq(1,counter) = setmac ;
            dev_seq(2,counter) = tIN ;
            counter = counter+1 ;
            if ~exist('t4','var')
                t4 = tOUT ;
            end
            t41 = linspace(t4,t1,resln) ;
            t41dash = linspace(t4dash,t1,resln) ;
            s41dash = linspace(s4dash,s1,resln) ;
            s41 = linspace(s4,s1,resln) ;
            plot(s41,t41,'--b') ;
            plot(s41dash,t41dash,':b') ;
            prompt = {'Pressure loss from the exhaust of turbine through the whole line: (in %)','Regenerator efficiency: '} ;
            name = 'Inputs for Gas Turbine Cycle:' ;
            numlines = 1 ;
            defaultanswer = {'3','0.8'} ;
            answer=inputdlg(prompt,name,numlines,defaultanswer,options) ;
            answer=char(answer) ;
            answer=str2num(answer) ;epselon = answer(2) ;
            dev_seq(5,counter) = epselon;
            %%%%%%%%%pressue loss NOT taken into account after turbine
            
            fprintf('\nComputing...') ;
            %fix the problem for combustion chamber
            t5 = t3-epselon*(t3-t4);
            for x = 1:length(dev_seq);
                if dev_seq(1,x) == 3 %replaceinlet temperature for combusiton chamber
                    dev_seq(2,x) = t5 ;
                    break ;
                end
            end
            cycle_incomplete = false ;
        otherwise
            fprintf('\n Oops! Sorry we did not understand what you meant.. \n Would mind trying again?') ;
    end
    %one's exit is the inlet for the other
    sIN = sOUT ;
    sINdash = sOUTdash ;
    tIN = tOUT ;
    tINdash = tOUTdash ;
end
clc;
fprintf('                        ::MULTI STAGE CYCLE::');
fprintf('\nComputing...');
%now calculate the heat added
heat_added_reg = 0 ;
turbo_work_reg = 0 ;
nums=size(dev_seq) ;
chkn = find(dev_seq(1,:)==5);
if ~isempty(chkn)
    reheater_exists = true;
else
    reheater_exists = false;
end
for x = 1:nums(2)
    %combustion chamber heat production AND reheater
    if dev_seq(1,x) == 3
        ncomb = dev_seq(6,x) ;
        cv = dev_seq(5,x) ;
        maf_reg =(ncomb*cv-cpe*dev_seq(3,x))/(cpe*(dev_seq(3,x)-dev_seq(2,x))) ;
        qs_reg =(1+1/maf_reg)*cpe*(dev_seq(3,x)-dev_seq(2,x)) ;
        heat_added_reg = heat_added_reg + qs_reg ;
    end
    %turbine work production
    if dev_seq(1,x) == 4
        work_reg = (1+1/maf_reg)*(cpe)*(dev_seq(3,x)-dev_seq(2,x)) ;
        turbo_work_reg = turbo_work_reg + work_reg ;
    end
    %compressor work absorption: taken care in the beginning itself
    if reheater_exists
        if dev_seq(1,x) == 5
            ncomb = dev_seq(6,x) ;
            cv = dev_seq(5,x) ;
            maf_reg =(ncomb*cv-cpe*dev_seq(3,x))/(cpe*(dev_seq(3,x)-dev_seq(2,x))) ;
            qs_reg =(1+1/maf_reg)*cpe*(dev_seq(3,x)-dev_seq(2,x)) ;
            heat_added_reg = heat_added_reg + qs_reg ;
        end
    end
end
%calculate the compressor work absorbed
turbo_work = (1+1/maf)*(cpe)*(t3-t4);
wn_reg = -(turbo_work_reg) - comp_work;
p_reg = m*wn_reg;
n_reg = wn_reg/heat_added_reg;
%without regenerator
wn = turbo_work-comp_work ;
n = wn/heat_added ;
sfc = 3600/(maf*wn);
sfc_reg = 3600/(maf_reg*wn_reg) ;
p = m*wn ;
save('multi_vars');
clc;
fprintf('\n                        ::MULTI STAGE CYCLE::');
fprintf('\n \n Parameters With regenerator...... ')
fprintf('\n Air fuel ratio                             : %.2f',maf_reg)
fprintf('\n Heat Supplied per unit mass of air (kJ/kg) : %.2f',heat_added_reg)
fprintf('\n Specific Fuel Consumption (kg/kWh)         : %.2f',sfc_reg')
fprintf('\n Work Output(kJ/kg)                         : %.2f',wn_reg')
fprintf('\n Power output(kW)                           : %.2f ',p_reg)
fprintf('\n Efficiency of cycle (0-1)                  : %.2f',n_reg)
fprintf('\n \n Parameters WITHOUT regenerator...... ')
fprintf('\n Air fuel ratio                            : %.2f',maf)
fprintf('\n Heat Supplied per unit mass of air (kJ/kg): %.2f',heat_added)
fprintf('\n Specific Fuel Consumption (kg/kWh)        : %.2f',sfc')
fprintf('\n Work Output(kJ/kg)                        : %.2f',wn')
fprintf('\n Power output(kW)                          : %.2f ',p)
fprintf('\n Efficiency of cycle (0-1)                 : %.2f\n ',n)
fprintf('\n \n')