function [def_nic,tOUT,tOUTdash,sOUT,sOUTdash,nic]=intercooler(m,cpc,tIN,tINdash,tAMB,sIN,sINdash,resln)
%this calculates the parameters related to intercooler
nic = str2num(char(inputdlg('InterCooler Efficiency:')));
def_nic= nic;
tOUT = tIN-nic*(tIN-tAMB);
tOUTdash = tINdash-nic*(tINdash-tAMB);
tICdash = linspace(tINdash,tOUTdash,resln);
%pressure doesnot fall inside intercooler so we will take Xsteam to
%determine the entropy inside intercooler
tIC = linspace(tIN,tOUT,resln);
q = m*cpc*(tIN-tOUT);
qIC = linspace(0,q,resln);
for loop = 1:length(qIC)
    if loop==1
        sIC(loop) = sIN;
        sICdash(loop) = sINdash;
    else
        sIC(loop) = qIC(loop)/tIC(loop)+ sIN; %ds = dq/t where  s3 = (q-0)/t+sIN
        sICdash(loop) = qIC(loop)/tICdash(loop)+ sICdash(1);
    end
end
sOUT = sIC(length(sIC));
sOUTdash = sICdash(length(sICdash));
plot(sIC,tIC,'--b');
plot(sICdash,tICdash,':b');
%%drawnow;
%entropy change is only due to friction and other irreversible process here
%according to purdue epub paper. Hence, neglecting entropy changes.