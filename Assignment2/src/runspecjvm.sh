#!/usr/bin/env bash
BASEDIR="$SPECJVM2008_HOME"
OPENJDK_PROPS_FILE="$SPECJVM_TEST_HOME/Assignment2/props/openjdk.properties"
DRAGONWELL_PROPS_FILE="$SPECJVM_TEST_HOME/Assignment2/props/dragonwell.properties"
TENCENTKONA_PROPS_FILE="$SPECJVM_TEST_HOME/Assignment2/props/tencentkona.properties"
BISHENG_PROPS_FILE="$SPECJVM_TEST_HOME/Assignment2/props/bisheng.properties"

# 定义一个函数，切换 JDK

usejdk() {
  if [ -z "$1" ]; then
    echo "Usage: usejdk <jdk-name>"
    return 1
  fi

  # 目标 JDK 路径
  local target="$JDK_ROOT/$1"
  if [ ! -d "$target" ]; then
    echo "Error: JDK '$1' not found under $JDK_ROOT"
    return 1
  fi

  # 清理 PATH 中旧的 JDK_ROOT 下的条目
  local clean_path
  clean_path=$(echo "$PATH" | tr ':' '\n' \
               | grep -v "^$JDK_ROOT" \
               | paste -sd: -)

  export JAVA_HOME="$target"
  export JRE_HOME="$JAVA_HOME/jre"
  export PATH="$JAVA_HOME/bin:$JRE_HOME/bin:$clean_path"
  export CLASSPATH=".:$JAVA_HOME/lib/"

  echo "Switched to $1:"
  java -version
}

# usejdk() {
#   if [ -z "$1" ]; then
#     echo "Usage: usejdk <jdk-name>"
#     return 1
#   fi
#   export JAVA_HOME="/opt/jdks/$1"
#   export JRE_HOME="$JAVA_HOME/jre"
#   PATH="$(echo "$PATH" | tr ':' '\n' | grep -v "$JAVA_HOME" | paste -sd: -)"
#   export PATH="$JAVA_HOME/bin:$PATH"
#   export CLASSPATH=".:$JAVA_HOME/lib/"
#   echo "Switched to $1:"
#   java -version
# }
# usejdk dragonwell-8

source ~/.bashrc
java \
  -Xms350g \
  -Xmx350g \
  -XX:NewSize=100g \
  -XX:MaxNewSize=100g \
  -XX:MetaspaceSize=1g \
  -XX:MaxMetaspaceSize=2g \
  -XX:+UseParallelGC \
  -XX:+UseParallelOldGC \
  -XX:ParallelGCThreads=16 \
  -XX:+DisableExplicitGC \
  -XX:+UseAdaptiveSizePolicy \
  -XX:MaxTenuringThreshold=4 \
  -Dspecjvm.home.dir="$BASEDIR" \
  -jar "$BASEDIR/SPECjvm2008.jar" \
  -ikv \
  -pf "$OPENJDK_PROPS_FILE"

# # 初始堆大小（建议为总内存的1/4）
# -Xms350g

# # 最大堆大小（建议不超过物理内存的70%）
# -Xmx350g

# # 年轻代大小（推荐为堆的1/3~1/2）
# -XX:NewSize=100g
# -XX:MaxNewSize=100g

# # 元空间大小（避免动态扩容开销）
# -XX:MetaspaceSize=1g
# -XX:MaxMetaspaceSize=2g
# # 垃圾回收器
# -XX:+UseParallelGC
# -XX:+UseParallelOldGC

# # 并行GC线程数（建议等于CPU核心数）
# -XX:ParallelGCThreads=16

# # 禁用显式GC调用（避免RMI等干扰测试）
# -XX:+DisableExplicitGC

# # 启用自适应大小策略（动态调整代大小）
# -XX:+UseAdaptiveSizePolicy

# # 老年代晋升阈值（默认6，降低可减少晋升）
# -XX:MaxTenuringThreshold=4



usejdk dragonwell-8

java \
  -Xms350g \
  -Xmx350g \
  -XX:NewSize=100g \
  -XX:MaxNewSize=100g \
  -XX:MetaspaceSize=1g \
  -XX:MaxMetaspaceSize=2g \
  -XX:+UseG1GC \
  -XX:ParallelGCThreads=16 \
  -XX:+DisableExplicitGC \
  -XX:+UseAdaptiveSizePolicy \
  -XX:MaxTenuringThreshold=4 \
  -Dspecjvm.home.dir="$BASEDIR" \
  -jar "$BASEDIR/SPECjvm2008.jar" \
  -ikv \
  -pf "$DRAGONWELL_PROPS_FILE"


# # 初始堆大小（建议为总内存的1/4）
# -Xms350g

# # 最大堆大小（建议不超过物理内存的70%）
# -Xmx350g

# # 年轻代大小（推荐为堆的1/3~1/2）
# -XX:NewSize=100g
# -XX:MaxNewSize=100g

# # 元空间大小（避免动态扩容开销）
# -XX:MetaspaceSize=1g
# -XX:MaxMetaspaceSize=2g

# # 垃圾回收器
# -XX:+UseG1GC
# -XX:+G1ElasticHeap
# -XX:+ElasticHeapPeriodicUncommit

# # 并行GC线程数（建议等于CPU核心数）
# -XX:ParallelGCThreads=16

# # 禁用显式GC调用（避免RMI等干扰测试）
# -XX:+DisableExplicitGC

# # 启用自适应大小策略（动态调整代大小）
# -XX:+UseAdaptiveSizePolicy

# # 老年代晋升阈值（默认6，降低可减少晋升）
# -XX:MaxTenuringThreshold=4

#
usejdk TencentKona-8
java \
  -Xms350g \
  -Xmx350g \
  -XX:NewSize=100g \
  -XX:MaxNewSize=100g \
  -XX:MetaspaceSize=1g \
  -XX:MaxMetaspaceSize=2g \
  -XX:+UseG1GC \
  -XX:+G1ParallelFullGC \
  -XX:+G1RebuildRemSet \
  -XX:ParallelGCThreads=16 \
  -XX:+DisableExplicitGC \
  -XX:+UseAdaptiveSizePolicy \
  -XX:MaxTenuringThreshold=4 \
  -Dspecjvm.home.dir="$BASEDIR" \
  -jar "$BASEDIR/SPECjvm2008.jar" \
  -ikv \
  -pf "$TENCENTKONA_PROPS_FILE"


# # 初始堆大小（建议为总内存的1/4）
# -Xms350g

# # 最大堆大小（建议不超过物理内存的70%）
# -Xmx350g

# # 年轻代大小（推荐为堆的1/3~1/2）
# -XX:NewSize=100g
# -XX:MaxNewSize=100g

# # 元空间大小（避免动态扩容开销）
# -XX:MetaspaceSize=1g
# -XX:MaxMetaspaceSize=2g

# # 垃圾回收器
# -XX:+UseG1GC
# -XX:+G1ParallelFullGC
# -XX:+G1RebuildRemSet

# # 并行GC线程数（建议等于CPU核心数）
# -XX:ParallelGCThreads=16

# # 禁用显式GC调用（避免RMI等干扰测试）
# -XX:+DisableExplicitGC

# # 启用自适应大小策略（动态调整代大小）
# -XX:+UseAdaptiveSizePolicy

# # 老年代晋升阈值（默认6，降低可减少晋升）
# -XX:MaxTenuringThreshold=4



#
usejdk bisheng-8
java \
  -Xms350g \
  -Xmx350g \
  -XX:NewSize=100g \
  -XX:MaxNewSize=100g \
  -XX:MetaspaceSize=1g \
  -XX:MaxMetaspaceSize=2g \
  -XX:+UseG1GC \
  -XX:+G1ParallelFullGC \
  -XX:+UseNUMA \
  -XX:+G1Uncommit \
  -XX:ParallelGCThreads=16 \
  -XX:+DisableExplicitGC \
  -XX:+UseAdaptiveSizePolicy \
  -XX:MaxTenuringThreshold=4 \
  -Dspecjvm.home.dir="$BASEDIR" \
  -jar "$BASEDIR/SPECjvm2008.jar" \
  -ikv \
  -pf "$BISHENG_PROPS_FILE"


# # 初始堆大小（建议为总内存的1/4）
# -Xms350g

# # 最大堆大小（建议不超过物理内存的70%）
# -Xmx350g

# # 年轻代大小（推荐为堆的1/3~1/2）
# -XX:NewSize=100g
# -XX:MaxNewSize=100g

# # 元空间大小（避免动态扩容开销）
# -XX:MetaspaceSize=1g
# -XX:MaxMetaspaceSize=2g

# # 垃圾回收器
# -XX:+UseG1GC
# -XX:+G1ParallelFullGC
# -XX:+UseNUMA

# # 并行GC线程数（建议等于CPU核心数）
# -XX:ParallelGCThreads=16

# # 禁用显式GC调用（避免RMI等干扰测试）
# -XX:+DisableExplicitGC

# # 启用自适应大小策略（动态调整代大小）
# -XX:+UseAdaptiveSizePolicy

# # 老年代晋升阈值（默认6，降低可减少晋升）
# -XX:MaxTenuringThreshold=4



# # 使用G1GC时开启该选项，JVM能够检测应用负载下降和Java堆有空闲内存的情况，并自动减少JVM Java堆占用情况，将空闲内存资源归还给操作系统，以便在按资源使用量付费的容器场景中可以节省开销。
# -XX:+G1Uncommit

# -XX:+UseG1GC -XX:+UseNUMA
