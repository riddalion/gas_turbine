function [n,maf,heat_added,sfc,wn,p,maf_reg,heat_added_reg,sfc_reg,wn_reg,p_reg,n_reg]=nprt(maf,cv,ncomb,cpe,cpg,nic,nc,pr,gc,cpc,m,resln,rh,tAMB,tIN,pIN,epselon)
%this function returns n for given pressure ratio and input and is done for
%multi stage cycle
%the input data is like a reservoir, dumps every available data into the
%workspace, which is continuously updated and used as when required or
%available
t1 = tIN;tINdash = tIN;
warnState = warning('off', 'MATLAB:gui:latexsup:BadTeXString');
cycle_incomplete=true;
comp_work = 0; turbo_work = 0; heat_added = 0;
once_only = true;
direct_exit = false;
for loop = 1:length(dev_seq)
    while cycle_incomplete
        setmac = dev_seq(loop); %automated device selection
        switch setmac
            case 1
                if once_only
                    warning('off','MATLAB:dispatcher:InexactCaseMatch');
                    s1 = Xsteam('s_pT',pIN,tIN-273); %initial entropy
                    sIN = s1;
                    sINdash = s1;
                    once_only = false;
                end
                [cpc,rh,wc,pOUT,tOUTdash,tOUT,sOUT,sOUTdash]=compressor_2(nc,pr,gc,cpc,once_only,m,sIN,sINdash,tIN,tINdash,pIN,rh,resln);
                comp_work = comp_work+wc;
                pBUFF = pOUT; %allowed to update
            case 2
                [tOUT,tOUTdash,sOUT,sOUTdash,~]=intercooler_2(nic,m,cpc,tIN,tINdash,tAMB,sIN,sINdash,resln);
            case 3
                [tOUT,tOUTdash,sOUT,sOUTdash,maf,cv,ncomb,cpe] = combustioncham_2(maf,cv,ncomb,cpe,cpg,tIN,tINdash,resln,sIN,sINdash);
                qs = (1+1/maf)*cpe*(tOUT-tIN); %cpe available here
                heat_added = heat_added+qs;
                t3 = tOUT; %update allowed, I need temp b4 entering the cc
            case 4
                pIN = (1-dp*0.01)/(1+dp*0.01)*pBUFF;
                [wt,pOUT,pOUTdash,tOUTdash,tOUT,sOUT,sOUTdash,nt,ge,cpe]=turbine_2(p4,nt,ge,cpe,sIN,tIN,pIN,resln);
                t4 = tOUT; %update allowed
                turbo_work = turbo_work+wt;
                s4 = sOUT; s4dash = sOUTdash;
                t4dash = tOUTdash; t4 = tOUT;
            case 5
                [tOUT,tOUTdash,sOUT,sOUTdash,maf,cv,ncomb,cpe] = reheater_2(maf,cv,ncomb,cpe,cpg,tIN,tINdash,resln,sIN,sINdash);
            case 6
                if ~exist('t4','var');
                    t4 = tOUT;
                end
                t41 = linspace(t4,t1,resln);
                t41dash = linspace(t4dash,t1,resln);
                s41dash = linspace(s4dash,s1,resln);
                s41 = linspace(s4,s1,resln);
                t5 = t3-epselon*(t3-t4);
                heat_added_reg = cpe*(t3-t5);
                turbo_work = (1+1/maf)*(cpe)*(t3-t4);
                maf_reg =(ncomb*cv-cpe*t3)/(cpe*(t3-t5));
                turbo_work_reg = (1+1/maf_reg)*(cpe)*(t3-t4);
                wn_reg = turbo_work_reg - comp_work;
                wn = turbo_work-comp_work;
                n = wn/heat_added;
                n_reg = wn_reg/heat_added_reg;
                sfc = 3600/(maf*wn);
                sfc_reg = 3600/(maf_reg*wn_reg);
                p = m*wn;
                p_reg = m*wn_reg;
                fprintf('\n \n');
                cycle_incomplete=false;
        end
        %one's exit is the inlet for the other
        sIN = sOUT;
        sINdash = sOUTdash;
        tIN = tOUT;
        tINdash = tOUTdash;
    end
end