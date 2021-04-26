#!/bin/bash


dirSubject=$1

sub=$2
sub_upper=${sub}


mkdir -p $dirSubject"/QC/html"


MELODIC_html=$dirSubject"/QC/html/MELODIC.html"

rm -f $MELODIC_html

if [ ! -e $MELODIC_html ]; then
  
cat > $MELODIC_html << EOF


<!DOCTYPE html>
<html lang="en">
<title>MELODIC IMAGE REPORT</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="css/w3.css">
<script src="./togglesMELODIC.js" type="text/javascript" charset="utf-8"></script>
<script src="./sidebartoggles.js" type="text/javascript" charset="utf-8"></script>

<body class="w3-main" style="background-color:black; " onload="updateTitle();updateImage();updateTitle();">
<!--document.getElementById('image_link').innerHTML = document.getElementById('ex_a').src;-->


<!-- Header -->
<header class="w3-display-container  w3-center" style="max-height:1000px; ">
  <img class="w3-image" src="images/1.jpg" alt="Me" width=100% style="max-height:1000px;object-fit: cover;">
   
    <div class="w3-display-middle w3-padding-large w3-border w3-wide w3-text-light-grey w3-center" style="background-color:rgba(0, 0, 0, 0.75);">

      <h1 class="w3-hide-medium w3-hide-small w3-xxxlarge">MELODIC IMAGE REPORT</h1>
      <h5 class="w3-hide-large" style="white-space:nowrap">MELODIC IMAGE REPORT</h5>
      
      <h3 class="w3-hide-medium w3-hide-small">$sub_upper</h3>
      
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
</div>
</div>


<!-- Page content -->
<div class="w3-content w3-padding-large w3-margin-top" id="portfolio" style="color:white; text-align: center; height: 900px">


  <!-- Images (Portfolio) -->


  <br>______<br><br>
  <h1> $sub_upper <div id="analysis_title_0" style="display: inline;"></div> 
  <br>
</h1>
  <br>





<!-------------- OPTIONS -------------->

<!-- ICAs -->
  <label for="ICA" style="white-space:nowrap;">ICA <i>(q/e)</i>:
  <select name="ICA" id="ICA" onchange="updateTitle();updateImage();" onkeydown="IgnoreAlpha(event);">
    

EOF

fi







array=()
while IFS=  read -r -d $'\0'; do
    array+=("$REPLY")
done < <(find $dirSubject/fMRI -maxdepth 1 -type d -name "*.ica" -print0)



#for each .ica file
for t in ${array[@]}; do
  rfMRI_ver=`basename $t`
cat <<EOF >> $MELODIC_html

<option value="$rfMRI_ver" id="$rfMRI_ver">$rfMRI_ver</option>

EOF
done


#printing inbetween filler

cat <<EOF >> $MELODIC_html

  </select></label>
  &nbsp&nbsp&nbsp&nbsp


EOF



#printing components
for t in ${array[@]}; do
  rfMRI_ver=`basename $t`
  #deal with multiple fix4melview
  file=$(find $t -maxdepth 1 -name "fix4melview_*.txt" -print0)


    num=`tail -n2 $file| head -n1`
  noise=`tail -n1 $file| head -n1`
    
    num="${num%%,*}"

  noise=${noise#"["}
  noise=${noise%"]"}
  IFS=', ' read -r -a noise_array <<< "$noise"


cat <<EOF >> $MELODIC_html

<!-- Component -->

  <label for="$rfMRI_ver" id="${rfMRI_ver}_label" style="white-space:nowrap; display: none;">Component <i>(a/d)</i>:
  <select name="$rfMRI_ver" id="${rfMRI_ver}_select" onchange="updateTitle();updateImage();" onkeydown="IgnoreAlpha(event);">

    <optgroup label="Signal">
EOF


for ((n=1;n<=$num;n++)); do
  if [[ " ${noise_array[@]} " =~ " $n " ]]; then
      SIG_or_NOISE="NOISE"
  else
cat <<EOF >> $MELODIC_html
      <option value="$n" id="$n">SIGNAL: IC_$n</option>
EOF
  fi
done


cat <<EOF >> $MELODIC_html
    </optgroup>
    <optgroup label="Noise">
EOF



for ((n=1;n<=$num;n++)); do
  if [[ " ${noise_array[@]} " =~ " $n " ]]; then
cat <<EOF >> $MELODIC_html
      <option value="$n" id="$n">NOISE: IC_$n</option>
EOF
  else
    SIG_or_NOISE="SIGNAL"
  fi
done



cat <<EOF >> $MELODIC_html
    </optgroup>
  </select></label>


EOF
done



cat <<EOF >> $MELODIC_html

<br>
<br>
  <!-- Analyses -->
  <label for="Analysis" style="white-space:nowrap;">Analysis <i>(z/c)</i>:
  <select name="Analysis" id="Analysis" onchange="updateTitle();updateImage();" onkeydown="IgnoreAlpha(event);">
    
      <option value="ev" id="ev">Eigenspectrum Analysis</option>
      <option value="ic" id="ic">IC</option>
      <option value="mm" id="mm">IC Mixture Model Fit</option>
  </select></label>
  &nbsp&nbsp&nbsp&nbsp


<!-------------- OVERLAYS -------------->


  <br> <br> 

______<br><br>
<div id="analysis_title_1" style="display: inline; font-size: 28px"></div>



EOF




for t in ${array[@]}; do
  
  folder=`basename $t`
  echo $folder


    file=$(find $t -maxdepth 1 -name "fix4melview_*.txt" -print0)


    num=`tail -n2 $file| head -n1`
    noise=`tail -n1 $file| head -n1`
    
    num="${num%%,*}"

  noise=${noise#"["}
  noise=${noise%"]"}
  IFS=', ' read -r -a noise_array <<< "$noise"


  rfMRI_ver=`basename $t`

  report_dir=$rfMRI_ver/filtered_func_data.ica/report


  home=$report_dir/00index.html
  EV=$report_dir/EVplot.png

  for ((n=1;n<=$num;n++)); do

    SIG_or_NOISE=""

    if [[ " ${noise_array[@]} " =~ " $n " ]]; then
      SIG_or_NOISE="NOISE"
      # whatever you want to do when array contains value
    else
      SIG_or_NOISE="SIGNAL"
    fi

      IC_html=$report_dir/IC_${n}.html
    IC_MM_html=$report_dir/IC_${n}_MM.html

    IC_MMfit_png=$report_dir/IC_${n}_MMfit.png
    IC_prob_png=$report_dir/IC_${n}_prob.png
    IC_thresh_png=$report_dir/IC_${n}_thresh.png
    IC_png=$report_dir/IC_${n}.png

    f_png=$report_dir/f${n}.png
    t_png=$report_dir/t${n}.png



cat <<EOF >> $MELODIC_html


<div class="c_${n}_$rfMRI_ver" style="display: none;">
<a href="../../fMRI/$rfMRI_ver/filtered_func_data.ica/report/00index.html">MEDLODIC ICA Home</a><br>
&nbsp&nbsp<a href="../../fMRI/$rfMRI_ver/filtered_func_data.ica/report/IC_${n}.html">IC Report</a> &nbsp&nbsp-&nbsp&nbsp  
<a href="../../fMRI/$rfMRI_ver/filtered_func_data.ica/report/IC_${n}_MM.html">IC MM report</a><br>

<br>
<img name="${rfMRI_ver}_${n}_ev" src="../../fMRI/$rfMRI_ver/filtered_func_data.ica/report/EVplot.png" class="${n}" width="1000" style="padding: 10px" >
<img name="${rfMRI_ver}_${n}_ic" src="../../fMRI/$rfMRI_ver/filtered_func_data.ica/report/IC_${n}_thresh.png" class="${n}" width="1000" style="padding: 30px" >
<img name="${rfMRI_ver}_${n}_ic" src="../../fMRI/$rfMRI_ver/filtered_func_data.ica/report/t${n}.png" class="${n}" width="1000" style="padding: 10px" >
<img name="${rfMRI_ver}_${n}_ic" src="../../fMRI/$rfMRI_ver/filtered_func_data.ica/report/f${n}.png" class="${n}" width="1000" style="padding: 10px" >
<img name="${rfMRI_ver}_${n}_mm" src="../../fMRI/$rfMRI_ver/filtered_func_data.ica/report/IC_${n}.png" class="${n}" width="1000" style="padding: 30px" >
<img name="${rfMRI_ver}_${n}_mm" src="../../fMRI/$rfMRI_ver/filtered_func_data.ica/report/IC_${n}_prob.png" class="${n}" width="1000" style="padding: 30px" >
<img name="${rfMRI_ver}_${n}_mm" src="../../fMRI/$rfMRI_ver/filtered_func_data.ica/report/IC_${n}_MMfit.png" class="${n}" width="1000" style="padding-top: 30px" >
</div>


EOF

    #output=$ok$'\n'


  done

done




cat <<EOF >> $MELODIC_html


 <br> <br>
 


<div style="text-align: left; font-size: 12px" >
IMAGE 1 FILE:<br> <a id="image_link_0" href="../images/T1_extraction_masked/sub-CC520055_T1_extraction_masked_axial.png">N/A</a>
<br>
IMAGE 2 FILE:<br> <a id="image_link_1" href="../images/T1_extraction_masked/sub-CC520055_T1_extraction_masked_axial.png">N/A</a>
<br>
IMAGE 3 FILE:<br> <a id="image_link_2" href="../images/T1_extraction_masked/sub-CC520055_T1_extraction_masked_axial.png">N/A</a>
<br><br><br>
</div>
<!-- End page content -->
</div>

</body>

<script>
 updateTitle();updateImage();
</script>



</html>

EOF