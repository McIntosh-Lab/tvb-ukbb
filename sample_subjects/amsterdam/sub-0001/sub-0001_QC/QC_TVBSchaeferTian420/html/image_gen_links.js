
image_gen_links_dict={


"ex_under" : "../../T1/T1.nii.gz",
"ex_over1" : "../../T1/T1_brain_mask.nii.gz",
"NA3" : "NA3_link",


"uw_under" : "../../T1/T1.nii.gz",
"uw_over1" : "../../T1/T1_fast/T1_brain_WM_mask.nii.gz",
"NA4" : "NA4_link",


"ug_under" : "../../T1/T1.nii.gz",
"ug_over1" : "../../T1/T1_fast/T1_brain_GM_mask.nii.gz",
"NA5" : "NA5_link",


"us_under" : "../../T1/T1.nii.gz",
"us_over1" : "../../T1/T1_first/subcort_GM.nii.gz",
"NA7" : "NA7_link",


"lc_under" : "../../T1/T1.nii.gz",
"lc_over1" : "../../T1/labelled_GM_TVBSchaeferTian420.nii.gz",
"NA8" : "NA8_link",


"ls_under" : "../../T1/T1.nii.gz",
"ls_over1" : "../../T1/T1_first/T1_first_all_fast_firstseg.nii.gz",
"NA9" : "NA9_link",


"re_under_1" : "../../T1/T1_brain_to_MNI.nii.gz",
"re_over1_1" : "/opt/fsl/data/standard/MNI152_T1_1mm.nii.gz",
"NA12" : "NA12_link",


"re_under_2" : "/opt/fsl/data/standard/MNI152_T1_1mm.nii.gz",
"re_over1_2" : "../../T1/T1_brain_to_MNI.nii.gz",
"NA34" : "NA34_link",


"dorf_under" : "../../dMRI/dMRI/dti_FA.nii.gz",
"dorf_over1" : "../../dMRI/dMRI/dti_V1.nii.gz",
"NA19" : "NA19_link",


"dex_under" : "../../dMRI/dMRI/data_B0.nii.gz",
"dex_over1" : "../../dMRI/dMRI/nodif_brain_mask.nii.gz",
"NA24" : "NA24_link",


"dre_under_1" : "../../T1/T1.nii.gz",
"dre_over1_1" : "../../dMRI/dMRI/transforms/DTI_to_T1.nii.gz",
"NA25" : "NA25_link",


"dre_under_2" : "../../dMRI/dMRI/transforms/DTI_to_T1.nii.gz",
"dre_over1_2" : "../../T1/T1.nii.gz",
"NA26" : "NA26_link",


"wa_under_1" : "../../dMRI/dMRI/SynB0/b0_u.nii.gz",
"wa_over1_1" : "../../dMRI/dMRI/DWI_B0.nii.gz",
"NA13" : "NA13_link",


"wa_under_2" : "../../dMRI/dMRI/DWI_B0.nii.gz",
"wa_over1_2" : "../../dMRI/dMRI/SynB0/b0_u.nii.gz",
"NA33" : "NA33_link",


"dxc_under" : "../../dMRI/dMRI/dti_FA.nii.gz",
"dxc_over1" : "../../dMRI/probtrackx_TVBSchaeferTian420/exclude.nii.gz",
"NA29" : "NA29_link",


"dfs_under" : "../../dMRI/dMRI/dti_FA.nii.gz",
"dfs_over1" : "../../dMRI/probtrackx_TVBSchaeferTian420/labelledWM_GM_TVBSchaeferTian420.nii.gz",
"NA30" : "NA30_link",


"dfsrb_under" : "../../dMRI/dMRI/dti_FA.nii.gz",
"dfsrb_over1" : "../../dMRI/probtrackx_TVBSchaeferTian420/labelledWM_GM_TVBSchaeferTian420.nii.gz",
"NA31" : "NA31_link",


"dxs_under" : "../../dMRI/dMRI/dti_FA.nii.gz",
"dxs_over1" : "../../dMRI/probtrackx_TVBSchaeferTian420/exclude.nii.gz",
"dxs_over2" : "../../dMRI/probtrackx_TVBSchaeferTian420/labelledWM_GM_TVBSchaeferTian420.nii.gz",



};
	


function update_links(){

		var ana = document.getElementById("Analysis").value;
	if (!ana.endsWith(".pdf")){

		var underlay=1;
		var overlay1=1;
		var overlay2=1;

		if ((ana == "re")||(ana == "dre")||(ana == "Tre")||(ana == "wa")){
			if(document.getElementById("Order 1").checked == true){
				underlay=ana.concat("_","under_1");
				overlay1=ana.concat("_","over1_1");
				overlay2=ana.concat("_","over2_1");	

			}
			else{
				underlay=ana.concat("_","under_2");
				overlay1=ana.concat("_","over1_2");
				overlay2=ana.concat("_","over2_2");	
			}
		}
		else{
			underlay=ana.concat("_","under");
			overlay1=ana.concat("_","over1");
			overlay2=ana.concat("_","over2");
			
		}
		
		
		try{document.getElementById("underlay").href = image_gen_links_dict[underlay];
				document.getElementById("underlay").innerHTML = document.getElementById("underlay").href;
				document.getElementById("underlay").href = image_gen_links_dict[underlay].substring(0,image_gen_links_dict[underlay].lastIndexOf("/")+1);}
		catch(err){
			document.getElementById("underlay").innerHTML = "N/A";
			document.getElementById("underlay").href = "N/A";
		}
		
		
		try{document.getElementById("overlay1").href = image_gen_links_dict[overlay1];
				document.getElementById("overlay1").innerHTML = document.getElementById("overlay1").href;
				document.getElementById("overlay1").href = image_gen_links_dict[overlay1].substring(0,image_gen_links_dict[overlay1].lastIndexOf("/")+1);}
		catch(err){
			document.getElementById("overlay1").innerHTML = "N/A";
			document.getElementById("overlay1").href = "N/A";
		}
		
		
		try{document.getElementById("overlay2").href = image_gen_links_dict[overlay2];
				document.getElementById("overlay2").innerHTML =  document.getElementById("overlay2").href;
				document.getElementById("overlay2").href = image_gen_links_dict[overlay2].substring(0,image_gen_links_dict[overlay2].lastIndexOf("/")+1);}
		catch(err){
			document.getElementById("overlay2").innerHTML = "N/A";
			document.getElementById("overlay2").href = "N/A";
		}
}}



