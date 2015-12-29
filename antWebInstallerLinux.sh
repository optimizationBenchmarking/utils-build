#!/bin/bash
#
# Installation Script for Ant
# apt-get may sometimes not be available and/or install
# the wrong version of Ant. This script alleviates this
# problem.
#
# This script follows more or less the suggestions from
# http://www.askubuntu.com/questions/674328/
#
currentDir=`pwd`
antVersion=1.9.6
#
purgeAnt=true
#
# Parse command line arguments, as in
# http://www.http://stackoverflow.com/questions/192249
for i in "$@"
do
case $i in
    --purgeAnt=*)
    purgeAnt="${i#*=}"
    shift # past argument=value
    ;;    
    *)
            # unknown option
    ;;
esac
done
#
echo "We are in folder ${currentDir} and now go to folder /tmp/."
cd /tmp/

# remove the old version of ant, if possible
if [ "$purgeAnt" == "true" ]; then
  echo "Attempting to uninstall any existing version of ant."
  sudo apt-get -y purge ant
else
  echo "Not purging Ant. We are keeping Ant and try to just override the environment variables."
fi

# trying to remove link to Ant if it still exists (it may if we did not purge Ant)
sudo rm -f /usr/bin/ant

# download, unpack, and install the required version
echo "Downloading Ant ${antVersion} from http://archive.apache.org/dist/ant/binaries/apache-ant-${antVersion}-bin.tar.gz"
wget http://archive.apache.org/dist/ant/binaries/apache-ant-${antVersion}-bin.tar.gz
tar -xvzf apache-ant-${antVersion}-bin.tar.gz
echo "Installing ant into /opt/apache-ant-${antVersion}"
sudo mv apache-ant-${antVersion} /opt/
rm -f apache-ant-${antVersion}-bin.tar.gz
sudo ln -s /opt/apache-ant-${antVersion}/bin/ant /usr/bin/ant

echo "export ANT_HOME=\"/opt/apache-ant-${antVersion}\"" >> ~/.bashrc
echo "export ANT_OPTS=\"-Xmx2048m -XX:MaxPermSize=1024m\"" >> ~/.bashrc
export ANT_HOME="/opt/apache-ant-${antVersion}"
export ANT_OPTS="-Xmx2048m -XX:MaxPermSize=1024m"

# return back to original directory
cd ${currentDir}
echo "Everything is good, we are back in ${currentDir}."