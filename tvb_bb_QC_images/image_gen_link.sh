#!/bin/bash

#USAGE:
#./image_gen_link_script.sh $dirSubject "uw_under" "../../fMRI/tfMRI_0.nii.gz" "uw_over1" "../../fMRI/tfMRI_0.nii.gz" "NA1" "NA1_link" 0


subjdir=$1
underlay=$2
underlay_link=$3
first_overlay=$4
first_overlay_link=$5
second_overlay=$6
second_overlay_link=$7
last_addition=$8


mkdir $subjdir"/QC/html"

image_gen_link_js=$subjdir"/QC/html/image_gen_links.js"


if [ ! -e $image_gen_link_js ]; then
	
cat > $image_gen_link_js << EOF

image_gen_links_dict={

EOF

fi



cat <<EOF >> $image_gen_link_js

"$underlay" : "$underlay_link",
"$first_overlay" : "$first_overlay_link",
"$second_overlay" : "$second_overlay_link",

EOF




if [ $last_addition -eq 1 ]; then
	
cat > $image_gen_link_js << EOF


};
	


function update_links(){

		var ana = document.getElementById("Analysis").value;
	if (!ana.endsWith(".pdf")){
		var underlay=ana.concat("_","under");
		var overlay1=ana.concat("_","over1");
		var overlay2=ana.concat("_","over2");
		
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



EOF

fi