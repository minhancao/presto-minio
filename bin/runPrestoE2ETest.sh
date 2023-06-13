#!/bin/sh

if [ -z ${1} ]; then
   echo "Please provide the test class name."
   echo "Example: runPrestoE2ETest.sh TestPrestoNativeGeneralQueriesJSON"
   exit 1
fi


# Check PRESTO_TOP
if [ -z "${PRESTO_TOP}" ]; then
    echo "Set PRESTO_TOP environment variable."
    exit 1
fi

if [ -z "${PRESTO_HOME}" ]; then
    echo "Set PRESTO_HOME environment variable. Where should presto go?"
    exit 1
fi

if [ ! -d "${PRESTO_HOME}/lib" ]; then
    echo "Run uselvl_presto to set up presto."
    exit 1
fi

# Find the presto_server executable - it could be in 3 locations depending on the how the build was done.
if [ -e "${PRESTO_TOP}/presto-native-execution/_build/debug/presto_cpp/main/presto_server" ]; then
    PRESTO_SERVER_VAL=${PRESTO_TOP}/presto-native-execution/_build/debug/presto_cpp/main/presto_server
elif [ -e "${PRESTO_TOP}/presto-native-execution/_build/release/presto_cpp/main/presto_server" ]; then
    PRESTO_SERVER_VAL=${PRESTO_TOP}/presto-native-execution/_build/release/presto_cpp/main/presto_server
elif [ -e "${PRESTO_TOP}/presto-native-execution/presto_cpp/main/presto_server" ]; then
    PRESTO_SERVER_VAL=${PRESTO_TOP}/presto-native-execution/presto_cpp/main/presto_server
else
    echo "Could not find the presto_server executable. Please rebuild."
    exit 1
fi

export PRESTO_SERVER_PATH=${PRESTO_SERVER_VAL}
export DATA_DIR=${PRESTO_HOME}/data
export WORKER_COUNT=1

echo "Path to presto_server: ${PRESTO_SERVER_PATH}"

cd ${PRESTO_TOP}/presto-native-execution
../mvnw clean test -Dtest=com.facebook.presto.nativeworker.${1} -Duser.timezone=America/Bahia_Banderas -DPRESTO_SERVER=${PRESTO_SERVER_PATH} -DWORKER_COUNT=${WORKER_COUNT} -DDATA_DIR=${DATA_DIR} -Dsurefire.useFile=false

