#!/bin/bash
#
# Copyright 2012 - 2016 by TIBCO Software Inc. 
# All rights reserved.
#
# This software is confidential and proprietary information of
# TIBCO Software Inc.
#
#


extract ()
{
if [ -f $1 ] ; then
  case $1 in
    *.tar.gz)  tar xvfz $1;;
    *.gz)      gunzip $1;;
    *.tar)     tar xvf $1;;
    *.tgz)     tar xvzf $1;;
    *.tar.bz2) tar xvjf $1;;
    *.bz2)     bunzip2 $1;;
    *.rar)     unrar x $1;;
    *.tbz2)    tar xvjf $1;;
    *.zip)     unzip -q $1;;
    *.Z)       uncompress $1;;
    *)         echo "can't extract from $1";;
  esac
else
  echo "no file called $1"
fi
}



#####################
#install config
#####################
tmp=/tmp
sourceJarFolder=${tmp}/jars
sourceMonitorAgentFolder=${tmp}/monitor-agents
sourceLibFolder=${tmp}/lib
sourcePluginFolder=${tmp}/plugins
sourceKeystore=${tmp}/certs


#####################
#extract and copy binaries
#####################
unzip -q /tmp/bwce*.zip -d /tmp
cp -r /tmp/tibco.home ${TIBCO_HOME}

#####################
#setup java
#####################

export JAVA_HOME=$TIBCO_HOME/tibco.home/tibcojre64/1.8.0
chmod 511 $TIBCO_HOME/tibco.home/tibcojre64/*/bin/java
chmod 511 $TIBCO_HOME/tibco.home/tibcojre64/*/bin/javac

#####################
#setup bw
#####################
chmod 511 $TIBCO_HOME/tibco.home/bw*/*/bin/startBWAppNode.sh
chmod 511 $TIBCO_HOME/tibco.home/bw*/*/bin/bwappnode
touch $TIBCO_HOME/tibco.home/keys.properties

# update config files	
# here still improvement needed
sed -i "s#_APPDIR_#$TIBCO_HOME#g" $TIBCO_HOME/tibco.home/bw*/*/bin/bwappnode.tra
sed -i "s#_APPDIR_#$TIBCO_HOME#g" $TIBCO_HOME/tibco.home/bw*/*/bin/bwappnode
sed -i.bak "s#_APPDIR_#$TIBCO_HOME#g" $TIBCO_HOME/tibco.home/bw*/*/config/appnode_config.ini

#config memory Limit
if [[ ${MEMORY_LIMIT} ]]; then
		memory_Number=`echo $MEMORY_LIMIT | sed 's/m$//I'`
		configured_MEM=$((($memory_Number*67+50)/100))
		thread_Stack=$((memory_Number))
		JAVA_PARAM="-Xmx"$configured_MEM"M -Xms128M -Xss512K"
		export BW_JAVA_OPTS=$JAVA_PARAM" "$BW_JAVA_OPTS
fi

#add custom Plugins
if [ -d ${sourcePluginFolder} ] && [ "$(ls $sourcePluginFolder)" ]; then 
	echo -e "name=Addons Factory\ntype=bw6\nlayout=bw6ext\nlocation=$TIBCO_HOME/addons" > `echo $TIBCO_HOME/tibco.home/bw*/*/ext/shared`/addons.link
	# unzip whatever is there not done
	for name in $(find $sourcePluginFolder -type f); 
	do	
		# filter out hidden files
		if [[  "$(basename $name )" != .* ]];then
	   		extract $name
			mkdir -p $TIBCO_HOME/tibco.home/addons/runtime/plugins/ && mv plugins/* "$_"
		fi
	done
fi

# add custom libs
if [ -d ${sourceLibFolder} ] && [ "$(ls $sourceLibFolder)" ]; then
	for name in $(find $sourceLibFolder -type f); 
		do	
		# filter out hidden files
		if [[  "$(basename $name )" != .* ]];then
			mkdir -p $TIBCO_HOME/tibco.home/addons/lib/ 
   			unzip -q $name -d $TIBCO_HOME/tibco.home/addons/lib/ 
   		fi
	done
fi

#add keystore
if [ -d ${sourceKeystore} ] && [ "$(ls $sourceKeystore)" ]; then
	mkdir -p $TIBCO_HOME/certs
  	cp -r  ${sourceKeystore}/* ${TIBCO_HOME}/tibco.home/certs
  	export BW_KEYSTORE_PATH=${TIBCO_HOME}/tibco.home/certs
fi


#add jdbc driver and osgi bundle jars
if [ -d ${sourceJarFolder} ] && [ "$(ls $sourceJarFolder)" ]; then
	#Copy jars to Hotfix
  	cp -r  ${sourceJarFolder}/* `echo $TIBCO_HOME/tibco.home/bw*/*`/system/hotfix/shared
fi

# add monitor agents
if [ -d ${sourceMonitorAgentFolder} ] && [ "$(ls $sourceMonitorAgentFolder)" ]; then 

	for name in $(find $agentFolder -type f); 
		do	
		# filter out hidden files
		if [[  "$(basename $name )" != .* ]];then
			mkdir -p $TIBCO_HOME/tibco.home/agent/
   			unzip -q $name -d $TIBCO_HOME/tibco.home/agent/
		fi
	done		
fi


# set log level
logback=$TIBCO_HOME/tibco.home/bw*/*/config/logback.xml
sed -i.bak "/<root/ s/\".*\"/\"$BW_LOGLEVEL\"/Ig" $logback

#####################
#add deployment helper
#####################

# create ProfileTokenResolver
mkdir -p $TIBCO_HOME/deploymentHelper
$JAVA_HOME/bin/javac -d $TIBCO_HOME/deploymentHelper -cp `echo $TIBCO_HOME/tibco.home/bw*/*/system/shared/com.tibco.tpcl.com.fasterxml.jackson_*`/*:`echo $TIBCO_HOME/tibco.home/bw*/*/system/shared/com.tibco.bw.tpcl.org.codehaus.jettison_*`/*:.:$JAVA_HOME/lib ${tmp}/ProfileTokenResolver.java

# copy configuration script to $TIBCO_HOME
mkdir -p $TIBCO_HOME/scripts
if [ -f ${tmp}/configuration.sh ]; then
  	cp ${tmp}/configuration.sh ${TIBCO_HOME}/scripts
fi
if [ -f ${tmp}/start.sh ]; then	
  	cp ${tmp}/start.sh ${TIBCO_HOME}/scripts
fi
