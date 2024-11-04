
%%% This code calculates SQL metrics using Optical Density, Concentration files in xlsx format and
% generates plots and excel files to be saved in the current path,The following
% devices are used in the paper: OctaMon, Brite 23, Brite 24 and OxyMon.
%
% oxysoft2matlab、spm12 is needed
%
% reference--------------------------------------------------------------------
% https://www.artinis.com/blogpost-all/2023/assessing-nirs-signal-quality-implementation-of-the-signal-quality-index-sqi
% paper------------------------------------------------------------------------
% https://opg.optica.org/boe/fulltext.cfm?uri=boe-11-11-6732&id=441993

clear;clc;

% duration(sec) of segments to run SQI algorithm on
duration=5;% 10s is used in paper,5s is used in oxysoft

[fname,pname] = uigetfile('*.oxy5','select oxy5 file','MultiSelect', 'on');

if iscell(fname)
    for i = 1:size(fname,2)
        sqi_cal(fname{i},pname,duration);
    end
else
    sqi_cal(fname,pname,duration);
end