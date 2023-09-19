%
%
% Script name: bb_netmats.m
%
% Description: Function to run netmats analysis
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
function bb_netmats(subj, general_subj_dir)

    addpath /home/fs0/steve/matlab/L1precision            
    addpath /home/fs0/steve/NETWORKS/FSLNets   

    addpath(sprintf('%s/etc/matlab',getenv('FSLDIR')))

    subj_dir=strcat(general_subj_dir,'/',subj)

    for dimensionality ={'25','100'}

        D=dimensionality{1}

        group_maps=strcat(sprintf('%s/etc/matlab',getenv('FSLDIR')),sprintf('/groupICA_d%s.ica/melodic_IC',D))
        ts_dir=strcat(subj_dir, '/fMRI/',sprintf('rfMRI_%s.dr',D))  
        ts=nets_load(ts_dir,0.735,0,1,490); 

        if strcmp(D,'25')
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
        
        po=fopen(strcat(subj_dir, '/fMRI/', sprintf('rfMRI_d%s_fullcorr_v1.txt',D)),'w');
        fprintf(po,[ num2str(NET(1,:),'%14.8f') '\n']);  
        fclose(po);

        clear NET; 

        grot=reshape(netmats2(1,:),ts.Nnodes,ts.Nnodes); 
        NET(1,:)=grot(triu(ones(ts.Nnodes),1)==1); 

        po=fopen(strcat(subj_dir, '/fMRI/', sprintf('rfMRI_d%s_partialcorr_v1.txt',D)),'w'); 
        fprintf(po,[num2str(NET(1,:),'%14.8f') '\n']);  
        fclose(po);

        ts_std=std(ts.ts);

        po=fopen(strcat(subj_dir, '/fMRI/', sprintf('rfMRI_d%s_NodeAmplitudes_v1.txt',D)),'w');

        fprintf(po,[num2str(ts_std(1,:),'%14.8f') '\n']);  
        fclose(po);

    end
