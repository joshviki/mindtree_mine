#!/bin/bash
echo "Please wait... Collecting the GKE cluster list"
gcloud projects list --format="value(PROJECT_ID)" > temp_total.txt
nl -s ")" temp_total.txt > temp_ID.txt
while read line
do
	for i in $line
	do
		gcloud config set project $i
		gcloud container clusters list --format="value(name)" > ins_total.txt
		echo '*****************************************'
		echo "Clusters in $i project"
		cat ins_total.txt
		echo '*****************************************'
	done
done<temp_total.txt
cat temp_ID.txt
read -p "Please choose the project in which the GKE cluster has to be deleted :" option
line_num=`cat temp_ID.txt | wc -l`

if [[ $option -gt $line_num ]]
then
	echo "Wrong option... exiting the deletion process"
else
	ID=`cat temp_ID.txt | grep -w $option | awk -F ")" '{print $2}'`
	echo "The project ID which you have chosen is $ID"
	echo "Please wait while we switch to the desired project"
	gcloud config set project $ID
	proj_id=`gcloud config get-value project`
	if [[ $proj_id == $ID ]]
	then 
		echo "Switched to $proj_id" 
		gcloud container clusters list --format="value(name)" > ins_total.txt
		nl -s ")" ins_total.txt > ins_list.txt
		cat ins_list.txt
		read -p "Please choose the GKE cluster which has to be deleted :" ins_opt
		ins_line_num=`cat ins_list.txt | wc -l`
		if [[ $ins_opt -gt $ins_line_num ]]
		then
			echo "Wrong option... exiting the creation process"
		else
			ins=`cat ins_list.txt | grep -w $ins_opt | awk -F ")" '{print $2}'`
			zone=`gcloud container clusters list --filter="name=$ins" --format="value(location)"`
			gcloud container clusters delete $ins --zone=$zone
			echo "$ins deleted successfully in zone $zone"
		fi
	else
		echo "Switching to $ID failed"
	fi
fi
rm ./*.txt

