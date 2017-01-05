#!/bin/bash

BUILD_DIR=/tmp
	defaultProfile=default.substvar
	manifest=$BUILD_DIR/META-INF/MANIFEST.MF
	bwAppConfig="TIBCO-BW-ConfigProfile"
	bwAppNameHeader="Bundle-SymbolicName"
	bwEdition='bwcf'
	bwceTarget='TIBCO-BWCE-Edition-Target:'
	if [ -f ${manifest} ]; then
		bwAppProfileStr=`grep -o $bwAppConfig.*.substvar ${manifest}`
		bwBundleAppName=`while read line; do printf "%q\n" "$line"; done<${manifest} | awk '/.*:/{printf "%s%s", (NR==1)?"":RS,$0;next}{printf "%s", FS $0}END{print ""}' | grep -o $bwAppNameHeader.* | cut -d ":" -f2 | tr -d '[[:space:]]' | sed "s/\\\\\r'//g" | sed "s/$'//g"`
		if [ "$DISABLE_BWCE_EAR_VALIDATION" != true ]; then
			bwEditionHeaderStr=`grep -E $bwEdition ${manifest}`
			res=$?
			if [ ${res} -eq 0 ]; then
				echo " "
			else
				echo "Application [$bwBundleAppName] is not supported in TIBCO BusinessWorks Container Edition. Convert this application to TIBCO BusinessWorks Container Edition using TIBCO BusinessWorks Container Edition Studio. Refer Conversion Guide for more details."
				exit 1
			fi
			#bwceTargetHeaderStr=`grep -E $bwceTarget ${manifest}`
			#res=$?
			#if [ ${res} -eq 0 ]; then
				#bwceTargetStr=`echo "$bwceTargetHeaderStr" | grep -E 'docker'`
				#res2=$?
				#if [ ${res2} -eq 0 ]; then
					#echo ""
				#else
					#echo "Application [$bwBundleAppName] is not supported in the Docker platform and cannot be started. You should convert this application using TIBCO BusinessWorks Container Edition Studio. Refer Application Development guide for more details."
					#exit 1
				#fi
			#else
		 		#echo "Application [$bwBundleAppName] is not supported in the Docker platform and cannot be started. You should convert this application using TIBCO BusinessWorks Container Edition Studio. Refer Application Development guide for more details."
				#exit 1
			#fi
		else
			print_Debug "Validation disabled."
		fi
	fi
	arr=$(echo $bwAppProfileStr | tr "/" "\n")

	for x in $arr
	do
    	case "$x" in 
		*substvar)
		defaultProfile=$x;;esac	
	done

	if [ -z ${BW_PROFILE:=${defaultProfile}} ]; then echo "BW_PROFILE is unset. Set it to $defaultProfile"; 
	else 
		case $BW_PROFILE in
 		*.substvar ) ;;
		* ) BW_PROFILE="${BW_PROFILE}.substvar";;esac
		echo "BW_PROFILE is set to '$BW_PROFILE'";
	fi


tmp=/tmp
if [ -f ${tmp}/*.substvar ]; then
	cp -f ${tmp}/*.substvar ${tmp}/tmp/pcf.substvar # User provided profile
else
	
	cp -f ${tmp}/META-INF/$BW_PROFILE ${tmp}/tmp/pcf.substvar
fi

cd $TIBCO_HOME/deploymentHelper/
$JAVA_HOME/bin/java -cp `echo $TIBCO_HOME/tibco.home/bw*/*/system/shared/com.tibco.tpcl.com.fasterxml.jackson_*`/*:`echo $TIBCO_HOME/tibco.home/bw*/*/system/shared/com.tibco.bw.tpcl.org.codehaus.jettison_*`/*:$TIBCO_HOME:$JAVA_HOME/lib/*:. -DBWCE_APP_NAME=$bwBundleAppName ProfileTokenResolver

#TODO FIXX THIS
mv ${tmp}/tmp/ /opt/tibco/

exec bash $TIBCO_HOME/tibco.home/bw*/*/bin/startBWAppNode.sh

