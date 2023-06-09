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
    PRESTO_SERVER_VAL=${PRESTO_TOP}/presto-native-execution/presto_cpp/main/presto_server
elif [ -e "${PRESTO_TOP}/presto-native-execution/_build/release/presto_cpp/main/presto_server" ]; then
    PRESTO_SERVER_VAL=${PRESTO_TOP}/presto-native-execution/presto_cpp/main/presto_server
elif [ -e "${PRESTO_TOP}/presto-native-execution/presto_cpp/main/presto_server" ]; then
    PRESTO_SERVER_VAL=${PRESTO_TOP}/presto-native-execution/presto_cpp/main/presto_server
else
    echo "Could not find the presto_server executable. Please rebuild."
    exit 1
fi

export PRESTO_SERVER=${PRESTO_SERVER_VAL}
export DATA_DIR=${PRESTO_HOME}/data
export WORKER_COUNT=0

# Build the classpath
JARS=`ls ${PRESTO_HOME}/lib`
CLASSPATH="${PRESTO_TOP}/presto-native-execution/target/test-classes:\
${PRESTO_TOP}/presto-hive/target/classes:\
${PRESTO_TOP}/presto-hive/target/test-classes:\
${PRESTO_TOP}/presto-hive-metastore/target/classes:\
${PRESTO_TOP}/presto-tests/target/classes:\
${PRESTO_TOP}/presto-tpch/target/classes:\
${PRESTO_TOP}/presto-tpcds/target/classes:\
${PRESTO_TOP}/presto-orc/target/classes:\
${PRESTO_TOP}/presto-delta/target/classes:\
${PRESTO_TOP}/presto-hive-common/target/classes:\
${PRESTO_TOP}/presto-parquet/target/classes:\
${PRESTO_TOP}/presto-cache/target/classes:\
${PRESTO_TOP}/presto-rcfile/target/classes:\
${HOME}/.m2/repository/io/airlift/tpch/tpch/0.10/tpch-0.10.jar:\
${HOME}/.m2/repository/org/apache/thrift/libthrift/0.9.3/libthrift-0.9.3.jar:\
${HOME}/.m2/repository/org/apache/hudi/hudi-presto-bundle/0.12.0/hudi-presto-bundle-0.12.0.jar:\
${HOME}/.m2/repository/com/google/cloud/bigdataoss/gcs-connector/hadoop2-1.9.17/gcs-connector-hadoop2-1.9.17.jar:\
${HOME}/.m2/repository/com/google/cloud/bigdataoss/gcsio/1.9.17/gcsio-1.9.17.jar:\
${HOME}/.m2/repository/com/google/cloud/bigdataoss/util/1.9.17/util-1.9.17.jar:\
${HOME}/.m2/repository/com/google/cloud/bigdataoss/util-hadoop/hadoop2-1.9.17/util-hadoop-hadoop2-1.9.17.jar:\
${HOME}/.m2/repository/com/google/flogger/flogger/0.3.1/flogger-0.3.1.jar:\
${HOME}/.m2/repository/com/google/flogger/google-extensions/0.3.1/google-extensions-0.3.1.jar:\
${HOME}/.m2/repository/com/google/flogger/flogger-system-backend/0.3.1/flogger-system-backend-0.3.1.jar:\
${HOME}/.m2/repository/com/github/luben/zstd-jni/1.5.2-2/zstd-jni-1.5.2-2.jar:\
${HOME}/.m2/repository/com/facebook/presto/hive/hive-apache/3.0.0-8/hive-apache-3.0.0-8.jar:\
${HOME}/.m2/repository/com/facebook/presto/hive/hive-apache-jdbc/0.13.1-5/hive-apache-jdbc-0.13.1-5.jar:\
${HOME}/.m2/repository/com/facebook/presto/hadoop/hadoop-apache2/2.7.4-9/hadoop-apache2-2.7.4-9.jar:\
${HOME}/.m2/repository/com/facebook/hive/hive-dwrf/0.8.5/hive-dwrf-0.8.5.jar:\
${HOME}/.m2/repository/com/facebook/presto/orc/orc-protobuf/13/orc-protobuf-13.jar:\
${HOME}/.m2/repository/com/amazonaws/aws-java-sdk-s3/1.11.697/aws-java-sdk-s3-1.11.697.jar:\
${HOME}/.m2/repository/com/amazonaws/aws-java-sdk-core/1.11.697/aws-java-sdk-core-1.11.697.jar:\
${HOME}/.m2/repository/org/testng/testng/7.5/testng-7.5.jar"

# Use newline as separator (default is space)
# load more classes from the presto-server
set -f; IFS='
'
for filename in ${JARS}; do
    CLASSPATH=${CLASSPATH}:${PRESTO_HOME}/lib/$filename
done
set +f; unset IFS

java -ea -Xmx5G -XX:+ExitOnOutOfMemoryError -Duser.timezone=America/Bahia_Banderas -Dhive.security=legacy -DDATA_DIR="${DATADIR}" -classpath "${CLASSPATH}" com.facebook.presto.nativeworker.HiveExternalWorkerQueryRunner
