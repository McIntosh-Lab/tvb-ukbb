%
%
% Script name: bb_IDP_T1_SIENAX
%
% Description: Script to generate the IDPs related to netmats in ICA.
%
% Authors: Fidel Alfaro-Almagro, Stephen M. Smith & Mark Jenkinson
%
% Copyright 2017 University of Oxford
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
addpath /home/fs0/steve/matlab/L1precision;                          
addpath /home/fs0/steve/NETWORKS/FSLNets;
addpath(sprintf('%s/etc/matlab',getenv('FSLDIR')));

IDP_dir='../IDP_files/'

for D = {25,100}

    group_maps=sprintf('%s/group/melodic_IC_%s',getenv('templ'),D{1});
    ts_dir=sprintf('%s/rfMRI_%d.dr', pwd, D{1});   % needs changing to match above eg $f/fMRI/rfMRI_${D}.dr/dr_stage1.txt from the subject dir

    if exist([ts_dir '/dr_stage1.txt'], 'file') == 2

        ts=nets_load(ts_dir,0.735,0,1,490); 

        if D{1} == 25
          ts.DD=[setdiff([1:25],[4 23 24 25])];
          r2zFULL=10.6484;
          r2zPARTIAL=10.6707;
        else
          ts.DD=[setdiff([1:100],[1 44 47 51 54 55 56 59 61 62 65:92 94:100])];
          r2zFULL=19.7177;
          r2zPARTIAL=18.8310;
        end
        ts=nets_tsclean(ts,1);

        netmats1=  nets_netmats(ts,-r2zFULL,'corr');
        netmats2=  nets_netmats(ts,-r2zPARTIAL,'ridgep',0.5);

        clear NET; 

        grot=reshape(netmats1(1,:),ts.Nnodes,ts.Nnodes); 
        NET(1,:)=grot(triu(ones(ts.Nnodes),1)==1);

        po=fopen(sprintf([IDP_dir 'bb_IDP_func_ICA_d%d_fullcorr_v1.txt'],D{1}),'w');
        fprintf(po,[num2str(NET(1,:),'%10.2e') '\n']);
        fclose(po);

        clear NET;
        grot=reshape(netmats2(1,:),ts.Nnodes,ts.Nnodes); 
        NET(1,:)=grot(triu(ones(ts.Nnodes),1)==1);
        po=fopen(sprintf([IDP_dir 'bb_IDP_func_ICA_d%d_partialcorr_v1.txt'],D{1}),'w');
        fprintf(po,[num2str(NET(1,:),'%10.2e') '\n']);
        fclose(po);

        ts_std=std(ts.ts);

        po=fopen(sprintf([IDP_dir 'bb_IDP_func_ICA_d%d_NodeAmplitudes_v1.txt'],D{1}),'w');
        fprintf(po, [num2str(ts_std(1,:),'%10.2e') '\n']);
        fclose(po);
    end
end;

% these 6 (total) new text files to be saved into $f/fMRI/rfMRI
