clc;
fprintf('                        ::MULTI STAGE CYCLE::');
load('devxxx');
dev_seq_mute = dev_seq;
nums=size(dev_seq_mute) ;
regen = 0 ;
comp_work = 0;
turbo_work = 0;
heat_added = 0;
once_only = true ;
format long e;
for rc = 1:nums(2)
dev_seq_mute(13,rc) = pr;
dev_seq_mute(3,rc) = tMAX;
end
for rc = 1:nums(2)
    setmac = dev_seq_mute(1,rc);
    switch setmac
        case 1
            if once_only
                resln = dev_seq_mute(6,rc);
                rh=dev_seq_mute(7,rc);
                m = dev_seq_mute(8,rc);
                tAMB = dev_seq_mute(9,rc);
                tIN =dev_seq_mute(10,rc);
                p1= dev_seq_mute(11,rc);
                t1 = tIN ;
                tINdash = tIN;
                pIN = p1;
                warning('off','MATLAB:dispatcher:InexactCaseMatch') ;
                s1 = Xsteam('s_pT',pIN,tIN-273);  %initial entropy;
                sIN = s1 ;
                sINdash = s1 ;
                once_only = false ; 
                dev_seq_mute(2,rc) = tIN ;
            end
            def_nc=dev_seq_mute(12,rc);
            def_pr = dev_seq_mute(13,rc);
            def_gc = dev_seq_mute(14,rc);
            def_cpc = dev_seq_mute(15,rc);
            [nc,pr,gc,cpc,rh,wc,pOUT,tOUTdash,tOUT,sOUT,sOUTdash]=compressor2(def_nc,def_pr,def_gc,def_cpc,once_only,m,sIN,sINdash,tIN,tINdash,pIN,rh,resln);            
            comp_work = comp_work+wc ;
            pBUFF = pOUT;  %allowed to update
%             dev_seq_mute(1,rc) = setmac ;
%             dev_seq_mute(3,rc) = tOUT ;
        case 2
            dev_seq_mute(2,rc) = tIN ;
            def_nic = dev_seq_mute(4,rc);
            [tOUT,tOUTdash,sOUT,sOUTdash,nic]=intercooler2(def_nic,m,cpc,tIN,tINdash,tAMB,sIN,sINdash,resln);
            dev_seq_mute(1,rc) = setmac ;
            dev_seq_mute(3,rc) = tOUT ;             
        case 3
            dev_seq_mute(1,rc) = setmac ;
            dev_seq_mute(2,rc) = tIN ;
            def_tMAX = dev_seq_mute(3,rc);
            def_cv =dev_seq_mute(4,rc);
            def_ncomb =dev_seq_mute(5,rc);
            def_cpe=dev_seq_mute(6,rc);
            [tOUT,tOUTdash,sOUT,sOUTdash,maf,cv,ncomb,cpe] = combustioncham2(def_tMAX,def_cv,def_ncomb,def_cpe,tIN,tINdash,resln,sIN,sINdash);
%             disp(ncomb);            dev_seq_mute(3,rc) = tOUT ;
%             dev_seq_mute(4,rc) = maf ;            dev_seq_mute(5,rc) = cv ;            dev_seq_mute(6,rc) = ncomb             ;%  disp('outside cc') ;
            maf = (ncomb*cv-cpe*tOUT)/(cpe*(tOUT-tIN));            
            dev_seq_mute(3,rc) = tOUT ;
            qs = (1+1/maf)*cpe*(tOUT-tIN); %cpe available here
            heat_added = heat_added+qs ;
            t3 = tOUT;  %update allowed, I need temp b4 entering the cc
        case 4
            dev_seq_mute(2,rc) = tIN ;
            dp = dev_seq_mute(4,rc);
            pIN = (1-dp*0.01)/(1+dp*0.01)*pBUFF ;
            def_p4 = dev_seq_mute(5,rc);
            def_nt = dev_seq_mute(6,rc);
            def_ge = dev_seq_mute(7,rc);
            def_cpe =dev_seq_mute(8,rc);
            [p4,wt,pOUT,pOUTdash,tOUTdash,tOUT,sOUT,sOUTdash,nt,ge,cpe]=turbine2(def_p4,def_nt,def_ge,def_cpe,sIN,tIN,pIN,resln);
            t4 = tOUT ; %update allowed
            pBUFF_turbo = pOUT ;
            turbo_work = turbo_work+wt ;
            s4 = sOUT;
            s4dash = sOUTdash ;
            t4dash = tOUTdash ;
            dev_seq_mute(1,rc) = setmac ;
            dev_seq_mute(3,rc) = tOUT ;
             
        case 5
            dev_seq_mute(1,rc) = setmac ;
            dev_seq_mute(2,rc) = tIN ;
            def_tOUT_rh= dev_seq_mute(7,rc);
            def_cv_rh=dev_seq_mute(8,rc);
            def_ncomb_rh=dev_seq_mute(9,rc);
            def_cpe_rh=dev_seq_mute(10,rc);
            [tOUT,tOUTdash,sOUT,sOUTdash,maf,cv,ncomb,cpe] = reheater2(def_tOUT_rh,def_cv_rh,def_ncomb_rh,def_cpe_rh,tIN,tINdash,resln,sIN,sINdash);
            qs = (1+1/maf)*cpe*(tOUT-tIN); %cpe available here
            %the following four lines are not going to make any difference 
            dev_seq_mute(3,rc) = tOUT ;
            dev_seq_mute(4,rc) = maf ;
            dev_seq_mute(5,rc) = cv ;
            dev_seq_mute(6,rc) = ncomb ;
            heat_added = heat_added+qs ;
            t3 = tOUT;
        case 6
            dev_seq_mute(1,rc) = setmac ;
            dev_seq_mute(2,rc) = tIN ;
            if ~exist('t4','var')
                t4 = tOUT ;
            end
            t41 = linspace(t4,t1,resln) ;
            t41dash = linspace(t4dash,t1,resln) ;
            s41dash = linspace(s4dash,s1,resln) ;
            s41 = linspace(s4,s1,resln) ;

            %%%%%%%%%pressue loss NOT taken into account after turbine
            epselon = dev_seq_mute(5,rc);            
            %fix the problem for combustion chamber
            t5 = t3-epselon*(t3-t4);
            for x = 1:length(dev_seq_mute);
                if dev_seq_mute(1,x) == 3 %replaceinlet temperature for combusiton chamber
                    dev_seq_mute(2,x) = t5 ;
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
nums=size(dev_seq_mute) ;
chkn = find(dev_seq_mute(1,:)==5);
if ~isempty(chkn)
    reheater_exists = true;
else
    reheater_exists = false;
end
for x = 1:nums(2)
    %combustion chamber heat production AND reheater
    if dev_seq_mute(1,x) == 3
        ncomb = dev_seq_mute(6,x) ;
        cv = dev_seq_mute(5,x) ;
        maf_reg =(ncomb*cv-cpe*dev_seq_mute(3,x))/(cpe*(dev_seq_mute(3,x)-dev_seq_mute(2,x))) ;
        qs_reg =(1+1/maf_reg)*cpe*(dev_seq_mute(3,x)-dev_seq_mute(2,x)) ;
        heat_added_reg = heat_added_reg + qs_reg ;
    end
    %turbine work production
    if dev_seq_mute(1,x) == 4
        work_reg = (1+1/maf_reg)*(cpe)*(dev_seq_mute(3,x)-dev_seq_mute(2,x)) ;
        turbo_work_reg = turbo_work_reg + work_reg ;
    end
    %compressor work absorption: taken care in the beginning itself
    if reheater_exists
        if dev_seq_mute(1,x) == 5
            ncomb = dev_seq_mute(6,x) ;
            cv = dev_seq_mute(5,x) ;
            maf_reg =(ncomb*cv-cpe*dev_seq_mute(3,x))/(cpe*(dev_seq_mute(3,x)-dev_seq_mute(2,x))) ;
            qs_reg =(1+1/maf_reg)*cpe*(dev_seq_mute(3,x)-dev_seq_mute(2,x)) ;
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
clc;
% fprintf('\n                        ::MULTI STAGE CYCLE::');
% fprintf('\n \n Parameters With regenerator...... ')
% fprintf('\n Air fuel ratio                             : %.2f',maf_reg)
% fprintf('\n Heat Supplied per unit mass of air (kJ/kg) : %.2f',heat_added_reg)
% fprintf('\n Specific Fuel Consumption (kg/kWh)         : %.2f',sfc_reg')
% fprintf('\n Work Output(kJ/kg)                         : %.2f',wn_reg')
% fprintf('\n Power output(kW)                           : %.2f ',p_reg)
% fprintf('\n Efficiency of cycle (0-1)                  : %.2f',n_reg)
% fprintf('\n \n Parameters WITHOUT regenerator...... ')
% fprintf('\n Air fuel ratio                            : %.2f',maf)
% fprintf('\n Heat Supplied per unit mass of air (kJ/kg): %.2f',heat_added)
% fprintf('\n Specific Fuel Consumption (kg/kWh)        : %.2f',sfc')
% fprintf('\n Work Output(kJ/kg)                        : %.2f',wn')
% fprintf('\n Power output(kW)                          : %.2f ',p)
% fprintf('\n Efficiency of cycle (0-1)                 : %.2f\n ',n)