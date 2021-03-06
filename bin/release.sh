#!/bin/bash

# ------------------------------------------------------------------------
# Usage:
# sh release.sh --env asf
# sh release.sh --env echartsjs
# sh release.sh --env dev # the same as "debug"
# sh release.sh --onlynext # only build next
# # Check `./config` to see the available env
# ------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        --env) envType="$2"; shift; shift ;;
        --env=*) envType="${1#*=}"; shift ;;
        --onlynext) onlyNext="YES"; shift ;;
        *) shift ;;
    esac
done
if [[ ! -n "${envType}" ]]; then
    echo "--env must be specified."
    exit 1;
fi

echo "Building with env type: ${envType}"

currWorkingDir=$(pwd)
thisScriptDir=$(cd `dirname $0`; pwd)
wwwProjectDir="${thisScriptDir}/..";
docProjectDir="${wwwProjectDir}/../incubator-echarts-doc";
examplesProjectDir="${wwwProjectDir}/../echarts-examples";
themeProjectDir="${wwwProjectDir}/../ECharts-Theme-Builder";

# Next
nextDocProjectDir="${wwwProjectDir}/../incubator-echarts-doc-next";
nextExamplesProjectDir="${wwwProjectDir}/../echarts-examples-next";

cd ${wwwProjectDir}

if [[ "${envType}" = "echartsjs" ]]; then
    mkdir ${wwwProjectDir}/release
fi

# Cleanup
cd ${thisScriptDir}
node build.js --env ${envType} --clean


if [[ ! -n "${onlyNext}" ]]; then

    # Build Theme Builder
    echo "Build theme builder ..."
    if [ ! -d "${themeProjectDir}" ]; then
        echo "Directory ${themeProjectDir} DOES NOT exists."
        exit 1
    fi
    cd ${themeProjectDir}
    node build.js --release

    # Build doc
    echo "Build doc ..."
    if [ ! -d "${docProjectDir}" ]; then
        echo "Directory ${docProjectDir} DOES NOT exists."
        exit 1
    fi
    cd ${docProjectDir}
    npm run build:site
    node build.js --env ${envType}
    cd ${currWorkingDir}
    echo "Build doc done."

    # Build examples
    echo "Build examples ..."
    if [ ! -d "${examplesProjectDir}" ]; then
        echo "Directory ${examplesProjectDir} DOES NOT exists."
        exit 1
    fi
    cd ${examplesProjectDir}
    node build.js --env ${envType}
    cd ${currWorkingDir}
    echo "Build examples done."

fi


# Build doc next
echo "Build doc next ..."
if [ ! -d "${nextDocProjectDir}" ]; then
    echo "Directory ${nextDocProjectDir} DOES NOT exists."
    exit 1
fi
cd ${nextDocProjectDir}
npm run build:site
node build.js --env ${envType}
cd ${currWorkingDir}
echo "Build doc next done."

# Build examples next
echo "Build examples next..."
if [ ! -d "${nextExamplesProjectDir}" ]; then
    echo "Directory ${nextExamplesProjectDir} DOES NOT exists."
    exit 1
fi
cd ${nextExamplesProjectDir}
npm run release
cd ${currWorkingDir}
echo "Build examples next done."


# Build www
echo "Build www ..."
cd ${wwwProjectDir}
node bin/build.js --env ${envType}
cd ${currWorkingDir}
echo "Build www done."


if [[ "${envType}" = "echartsjs" ]]; then
    cd ${wwwProjectDir}
    echo "zip echarts-www.zip ..."
    if [ -f echarts-www.zip ]; then
        rm echarts-www.zip
    fi
    zip -r -q echarts-www.zip release
    echo "zip echarts-www.zip done."
    cd ${currWorkingDir}
fi

echo "echarts-www release done for ${envType}"
