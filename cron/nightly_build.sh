#! /bin/sh
#
# Quick script to build mantid everynight
#
#
# Run cmake and build.
run_build() {
    timeit "CMake time:" cmake -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DMANTID_DATA_STORE=/mnt/data1/ExternalData/LocalObjectStore -DMAKE_VATES=ON -DParaView_DIR=/mnt/data1/Code/ParaView-v4.3.b40280-source/build/ParaView-4.3.b40280 ../../Code/Mantid
    timeit "Build time (no tests):" ninja
    timeit "Test build time:" ninja AllTests
}

#
# Time a given command with arguments. The first argument
# is assumed to be a string to prefix the output and is shifted
# out before executing the rest
timeit() {
    msg=$1
    shift 1
    ts_1=`date +%s`
    $*
    ts_2=`date +%s`
    echo
    echo $msg `expr $ts_2 - $ts_1` seconds
}

#---------- master ----------------
MASTER_ROOT=/mnt/data1/source/github/mantidproject/mantid
LAST_BUILD_RECORD=$MASTER_ROOT/last_build.txt

echo "********* Updating master *********"
# Update code
cd ${MASTER_ROOT}
git fetch -p
git checkout master
git reset --hard origin/master
echo "*****************************************"

# Do we need to rebuild
if [ -f $LAST_BUILD_RECORD ]; then
	PREV_HEAD=`cat $LAST_BUILD_RECORD`
else
	PREV_HEAD=""
fi
echo
echo "Previous build of master: ${PREV_HEAD}"

CURRENT_HEAD=`git rev-parse HEAD`
echo "Current HEAD: ${CURRENT_HEAD}"
if [ "$CURRENT_HEAD" != "$PREV_HEAD"  ]; then
#	echo "****** Removing all iostream refs from headers ******"
#	patch -p1 < $HOME/Desktop/rm_iostream_headers.patch
	echo "****** Building ******"
	if [ ! -d builds ]; then
	    mkdir builds
	fi
	cd ${MASTER_ROOT}/builds
	rm -Rf relwithdbg
	mkdir relwithdbg && cd relwithdbg
	timeit "Total build time:" run_build
	echo "*****************************************"
else
        echo "Current sha1 matches previous build - no build required."
fi
# Record built head
echo $CURRENT_HEAD > $LAST_BUILD_RECORD
