#!/bin/env python
#

# go into any existing QCand change pages so line before is new parc line a la

# <option value="../../QC_TVBSchaeferTian420/html/anat.html">TVBSchaeferTian420</option>

# "      <option >&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</option>
# "

import os
import re
# subj 
landmark_string="<option >&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</option>"

subjdir=#???



QC_subdirs = filter(os.path.isdir, os.listdir(subjdir))
QC_subdirs = [os.path.join(subjdir, f) for f in QC_subdirs if f[0:2]=="QC"] # add path to each file
QC_subdirs.sort(key=lambda x: os.path.getmtime(x))


#iterate through QC parcellations
for QC in QC_subdirs:

	#current parcellation
	parc=QC_subdirs[3:]
	
	#only interested in non-new parcellations
	if not PARC_NAME==parc:
		
		#iterate through html pages
		htmlfile_list=["anat.html","fMRI.html","dMRI.html","IDP.html","MELODIC_FIX.html","SCFC.html"]
		for htmlfile in htmlfile_list:
			
			#list to contain dictionaries
			mydictlist=[]

			#dictionary containing string to insert into current non-new parcellation QC and location of non-new parcellation QC
			#for adding link to new parc as a dropdown item in the current non-new parcellation QC
			mydict={
			"insert_string":'<option value="../../QC_'+PARC_NAME+'/html/'+htmlfile+'">'PARC_NAME'</option>',
			"file":os.path.join(QC,"html",htmlfile)
			}
			mydictlist.append(mydict)

			#dictionary containing string to insert into new parcellation QC and location of new parcellation QC
			#for adding link to the current non-new parcellation as a dropdown item in the new parc QC
			mydict={
			"insert_string":'<option value="../../QC_'+parc+'/html/'+htmlfile+'">'parc'</option>',
			"file":os.path.join(subjdir,"QC_"+PARC_NAME,"html",htmlfile)
			}
			mydictlist.append(mydict)


			#add the links to the corresponding files
			for dict_item in mydictlist:

				with open(dict_item["file"], 'r+') as f:
			    	a = [x.rstrip() for x in f]
				    index = 0
				    for item in a:
				        if re.search(landmark_string, item):
			     			a.insert(index, dict_item["insert_string"]) # Inserts "Hello everyone" into `a`
				            break
				        index += 1
			
				    f.seek(0)
				    f.truncate()
				    # Write each line back
				    for line in a:
				        f.write(line + "\n")

			    	f.close()
