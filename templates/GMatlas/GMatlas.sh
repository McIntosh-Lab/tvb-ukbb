cd $FSLDIR/data/atlases
/bin/rm grot*
fslsplit HarvardOxford/HarvardOxford-sub-prob-1mm grot
fslmerge -t grot grot00{03,14,04,15,05,16,06,17,08,18,09,19,10,20,07}.nii.gz
fslroi grot grot2 0 1
fslmaths grot2 -mul 0 -add 1 -roi 60 60 90 40 48 30 0 1 grot2
fslmaths Cerebellum/Cerebellum-MNIfnirt-prob-1mm -Tmax -thr 5 -binv -mul grot2 grot2
fslmaths HarvardOxford/HarvardOxford-sub-prob-1mm -Tmax -thr 25 -binv -mul grot2 -mul 25 grot2
fslmaths grot -mul 0 -add 1 -roi 0 -1 0 -1 0 -1 14 1 -mul grot2 -max grot grot3
fslmaths HarvardOxford/HarvardOxford-cort-prob-1mm -roi 90 -1 0 -1 0 -1 0 -1 grotL
fslmaths HarvardOxford/HarvardOxford-cort-prob-1mm -roi 0 90 0 -1 0 -1 0 -1 grotR
fslsplit grotL grotL
fslsplit grotR grotR
ls -1 grotL00??.nii.gz > grotL.txt
ls -1 grotR00??.nii.gz > grotR.txt
fslmerge -t grot4 `paste grotL.txt grotR.txt`
fslmerge -t grot5 grot4 grot3 Cerebellum/Cerebellum-MNIfnirt-prob-1mm
fslmaths grot5 -Tmax -thr 5 -bin grot6
fslmaths grot5 -Tmaxn -add 1 -mas grot6 -dilD -dilD GMatlas -odt char
