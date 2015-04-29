#!/bin/bash

#set -x

SLUG=$1
DEBUG=${2:-TRUE}

git clone git@github.com:$SLUG $SLUG
cd $SLUG
git fetch --all
git reset --hard origin/master
git log --oneline | head -10
if [ `git tag --contains HEAD | wc -l` != 0 ] ; then
    echo ";; nothing new exitting..."
    exit 0
fi

echo "catkin_generate_changelog"
catkin_generate_changelog -y
wget https://raw.githubusercontent.com/jsk-ros-pkg/jsk_common/master/jsk_tools/bin/force_to_rename_changelog_user.py -O /tmp/force_to_rename_changelog_user.py
chmod u+x /tmp/force_to_rename_changelog_user.py
find . -name CHANGELOG.rst -exec /tmp/force_to_rename_changelog_user.py {} \;
git diff | cat

if [ $DEBUG == TRUE ]; then
    echo ";; exitting since this is dry run"
    exit 0
fi

git commit -m "update CHANGELOG.rst" -a
git clean -xfd
source /opt/ros/hydro/setup.bash
echo "catkin_prepare_release"
catkin_prepare_release -y


