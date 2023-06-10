#!/bin/sh

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

export PRESTO_SERVER=${PRESTO_SERVER_VAL}
export DATA_DIR=${PRESTO_HOME}/data
export WORKER_COUNT=0

cd ${PRESTO_TOP}
./mvnw exec:java -pl presto-native-execution -Dexec.mainClass="com.facebook.presto.nativeworker.HiveExternalWorkerQueryRunner" -DjvmArgs="-Xmx5G -XX:+ExitOnOutOfMemoryError" -Duser.timezone=America/Bahia_Banderas -Dhive.security=legacy -DDATA_DIR="${DATA_DIR}" -DPRESTO_SERVER="${PRESTO_SERVER}" -DWORKER_COUNT="${WORKER_COUNT}" -Dexec.classpathScope=test
