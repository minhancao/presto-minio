#!/bin/sh

# Check PRESTO_TOP


export PRESTO_SERVER=${PRESTO_TOP}/presto-native-execution/cmake-build-debug/presto_cpp/main/presto_server
export DATA_DIR=${PRESTO_HOME}/data
export WORKER_COUNT=0

CLASSPATH=${PRESTO_TOP}/presto-native-execution
java -classpath -classpath "$CLASSPATH"   com.facebook.presto.hive.HiveExternalWorkerQueryRunner -ea -Xmx5G -XX:+ExitOnOutOfMemoryError -Duser.timezone=America/Bahia_Banderas -Dhive.security=legacy