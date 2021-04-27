#!/bin/env python

import pandas as pd
import numpy as np
import sys
import os


def generate_full_IDPoi_data(df,IDP_dir):
	flag=False
	output=[]
	for category in df['category'].unique():
		df_sub=df[df['category']==category]
		cat_data=[]
		with open(IDP_dir+category+'.txt') as my_file:
			for line in my_file:
				line = line.strip()
				line = line.split(' ')
				cat_data.append(line)
		cat_data=pd.DataFrame(cat_data)
		cat_data=cat_data.T
		cat_data.columns = ['value']
		cat_data['num_in_cat']=cat_data.index+1


		cat_data = cat_data.astype({"num_in_cat": int})
		df_sub = df_sub.astype({"num_in_cat": int})

		df_sub=df_sub.merge(cat_data,how='inner', on='num_in_cat')
		if not flag:
			output=df_sub
			flag=True
		else:
			output=output.append(df_sub,ignore_index=True)
	return output



def IDP_html_gen(subj,IDP_list_path,IDPoi_list_path):



	if subj.endswith('/'):
		subj = subj[:-1]
  
	QC_dir=subj + '/QC/html/'
	IDP_dir=subj + '/IDP_files/'
	if not os.path.exists(IDP_dir):
		os.makedirs(IDP_dir)


	subjName=subj[subj.rfind('/')+1:]


	IDP_list = []
	with open(IDP_list_path) as my_file:
		for line in my_file:
			line = line.strip()
			IDP_list.append(line)
	i=0
	while i < len(IDP_list):
		IDP_list[i]=IDP_list[i].replace('"','')
		IDP_list[i]=' '.join(IDP_list[i].split())
		IDP_list[i]=' '.join(IDP_list[i].split('\\t'))
		IDP_list[i]=IDP_list[i].split(' ', 7)
		i+=1

	IDP = pd.DataFrame(IDP_list, columns=["num","short","category","num_in_cat","long","unit","dtype","description"])


	#LOADING IDPois LIST

	IDPoi_list = []

	with open(IDPoi_list_path) as my_file:
		for line in my_file:
			line = line.strip()
			IDPoi_list.append(line)
	IDPoi = np.array(IDPoi_list)


	#SPLITTING PRIORITY AND NON PRIORITY IDPois

	priority=True
	priority_array=[]
	non_priority_array=[]
	for line in IDPoi:
		if line == "HIGH_PRIORITY":
			priority=True
		elif line == "LOW_PRIORITY":
			priority=False
		else:
			if priority:
				priority_array.append(line)
			else:
				non_priority_array.append(line)
				
	priority_df = pd.DataFrame(priority_array, columns=["short"])
	non_priority_df = pd.DataFrame(non_priority_array, columns=["short"])


	#/Users/justinwang/Documents/McIntosh/ukbbqc/full_subs/sub-CC520055/IDP_files/

	priority_df=priority_df[['short']]
	priority_df=priority_df.merge(IDP,how='inner', left_on='short', right_on='short')

	non_priority_df=non_priority_df[['short']]
	non_priority_df=non_priority_df.merge(IDP,how='inner', left_on='short', right_on='short')



	priority_output=generate_full_IDPoi_data(priority_df,IDP_dir)
	non_priority_output=generate_full_IDPoi_data(non_priority_df,IDP_dir)

	#print(priority_output)
	#print(non_priority_output)

	priority_output.to_csv(r''+IDP_dir+'priority_output.txt', header=priority_output.columns.values, index=None, sep='\t', mode='w')
	non_priority_output.to_csv(r''+IDP_dir+'non_priority_output.txt', header=non_priority_output.columns.values, index=None, sep='\t', mode='w')



	# write-html.py



	f = open(QC_dir+'IDP.html','a')

	message = """
	<!DOCTYPE html>
	<html lang="en">
	<title>IDP IMAGE REPORT</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="css/w3.css">
	<script src="./sidebartoggles.js" type="text/javascript" charset="utf-8"></script>
	<style>
	  th, td {
	  padding: 10px;
	}
	</style>
	<body class="w3-main" style="background-color:black; " onload="updateTitle();updateImage();updateTitle();">
	<!--document.getElementById('image_link').innerHTML = document.getElementById('ex_a').src;-->


	<!-- Header -->
	<header class="w3-display-container  w3-center" style="max-height:1000px; ">
	  <img class="w3-image" src="images/1.jpg" alt="Me" width=100% style="max-height:1000px;object-fit: cover;">
	  
		<div class="w3-display-middle w3-padding-large w3-border w3-wide w3-text-light-grey w3-center" style="background-color:rgba(0, 0, 0, 0.75);">

		  <h1 class="w3-hide-medium w3-hide-small w3-xxxlarge">IDP IMAGE REPORT</h1>
		  <h5 class="w3-hide-large" style="white-space:nowrap">IDP IMAGE REPORT</h5>
		  
		  <h3 class="w3-hide-medium w3-hide-small">sub-CC520055</h3>
		  
		</div>
	 

	  <!-- Sidebar -->

	  <div id="mySidebar" class="sidebar" style="width: 0; margin-left: 0; font-size: 12px">
		<a href="file:notes/" class="w3-center">open notes.txt file in local system to make changes</a>
		<br>
		<iframe src="notes/notes.txt" style="background: #FFFFFF; height: 90%"></iframe>

	  </div>

	  <!-- Sidebar button -->
	   <div id="main" align="left" >
		<button id="togglebutton" class="openbtn sticky" onclick="toggNav()">NOTES</button>  
	  </div>




	  <!-- Navbar (placed at the bottom of the header image) -->
	  <div class="w3-bar w3-light-grey w3-round w3-display-bottommiddle w3-hide-small w3-hide-medium" style="bottom:65px">
		<a href="report.html" class="w3-bar-item w3-button">Home</a>
		<a href="anat.html" class="w3-bar-item w3-button">Anatomical</a>
		<a href="fMRI.html" class="w3-bar-item w3-button">fMRI</a>
		<a href="MELODIC.html" class="w3-bar-item w3-button">MELODIC</a>
		<a href="DTI.html" class="w3-bar-item w3-button">DTI</a>
		<a href="SCFC.html" class="w3-bar-item w3-button">SC/FC</a>
		<a href="IDP.html" class="w3-bar-item w3-button">IDP</a>
	  </div>
	</header>

	<!-- Navbar on small screens -->
	<div class="w3-center w3-black w3-padding-16 w3-hide-large ">
	<div class="w3-bar w3-light-grey w3-round ">
	  <a href="report.html" class="w3-bar-item w3-button">Home</a>
		<a href="anat.html" class="w3-bar-item w3-button">Anatomical</a>
		<a href="fMRI.html" class="w3-bar-item w3-button">fMRI</a>
		<a href="MELODIC.html" class="w3-bar-item w3-button">MELODIC</a>
		<a href="DTI.html" class="w3-bar-item w3-button">DTI</a>
		<a href="SCFC.html" class="w3-bar-item w3-button">SC/FC</a>
		<a href="IDP.html" class="w3-bar-item w3-button">IDP</a>
	</div>
	</div>


	<!-- Page content -->
	<div class="w3-content w3-padding-large w3-margin-top" id="portfolio" style="color:white; text-align: center; height: 925px">


	  <!-- Images (Portfolio) -->

	<br><br><a name="fMRI_REPORTS">______</a><br><br>
	  <h1> IDP REPORTS </h1>
	  ______<br><br><br>
	<a href="../../IDP_files/" class="w3-bar-item w3-button">High-Priority IDPs: """+ str(IDP_dir)+"priority_output.txt" +"""</a>
	<br>
	<a href="../../IDP_files/" class="w3-bar-item w3-button">Lower-priority IDPs: """+ str(IDP_dir)+"non_priority_output.txt" +"""</a>
	<br><br>

	  <table style="  margin-left: auto;
	  margin-right: auto; text-align: left" >
		<tr>
		  <th>IDP Name (short)</th>
		  <th>Category</th>
		  <th>Value</th>
		  <th>Unit</th>
		</tr>
	  
	"""

	f.write(message)

	for index, row in priority_output.iterrows():
		
		message = """
			<tr>
			  <td>"""+str(row['short'])+"""</td>
			  <td>"""+str(row['category'])+"""</td>
			  <td>"""+str(row['value'])+"""</td>
			  <td>"""+str(row['unit'])+"""</td>
			</tr>
			
			"""
		f.write(message)


	for index, row in non_priority_output.iterrows():

		message = """
			<tr>
			  <td>"""+str(row['short'])+"""</td>
			  <td>"""+str(row['category'])+"""</td>
			  <td>"""+str(row['value'])+"""</td>
			  <td>"""+str(row['unit'])+"""</td>
			</tr>

			"""
		f.write(message)


	message = """ </table>


	<!-- End page content -->
	</div>

	</body>

	<script>
	 updateTitle();updateImage();
	</script>



	</html>

	 """
	f.write(message)

	f.close()


if __name__ == "__main__":
	#try:
	IDP_html_gen(sys.argv[1],sys.argv[2],sys.argv[3])
