%mini project-DEVELOPMENT OF COMPUTER CODE FOR GAS TURBINE CYCLES
clear all;
clc;
fig_num = 1; cpg = 1.148;
fprintf('\n Starting Code: DEVELOPMENT OF COMPUTER CODE FOR THERMODYNAMIC ANALYSIS OF GAS TURBINE CYCLES\n');
warnState = warning('off', 'MATLAB:gui:latexsup:BadTeXString');
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
clc;
fprintf('\n                 DEVELOPMENT OF COMPUTER CODE FOR GAS TURBINE CYCLES\n');
%main file for mini project
fprintf('\nThis program is capable to plot Pressure Ratio v/s Efficiency graphs for varying Maximum Cycle Temperature');
fprintf('\nIt can plot with Regenerator and without Regenerator');
fprintf('\nPLUS it will provide other valuable informations...');
fprintf('\nNow which of these do you wish to activate?');
fprintf('\n1.Purely Single Stage Processes');
fprintf('\n2.Multi-Stage Processes');
fprintf('\n3.EXIT');
choice=input('\n::YOUR CHOICE::' );
con_more = true;
% while con_more
switch choice
    case 1
        fprintf('\n (Selected: Case 1)\n We will set up your       		cycle now...');
        fprintf('\n Regenerator if added, they will be connected 		with the line, just before the combustor');
        fprintf('\n Initializing...');
        single_stage;
        ss_ext;
        fprintf('Will Wait for 10s and EXIT');
        pause(10);clf;clc;
        fprintf('\nThank YOU');
        imshow('thank_you.png');
    case 2
        clc;
        fprintf('\n (Selected: Case 2)\n We will set up your 			cycle now...');
        fprintf('\n Regenerators if added, they will be 				connected with the line, just before the combustor');
        fprintf('\n Lets begin...');
        multi_stage;        
        mm_ext;
        fprintf('Will Wait for 10s and EXIT');
        pause(10);clf;clc;
        fprintf('\nThank YOU');
        imshow('thank_you.png');
    case 3
        clf;clc;
        fprintf('\nThank YOU');
        imshow('thank_you.png');
%         con_more = false;
end