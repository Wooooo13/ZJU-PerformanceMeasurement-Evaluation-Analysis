#!/usr/bin/env bash
set -euo pipefail

# 用法：./run_specjvm_with_perf.sh [监测时长（秒）]
DURATION=${1:-60}

BASEDIR="$SPECJVM2008_HOME"
OPENJDK_PROPS_FILE="$SPECJVM_TEST_HOME/Assignment3/props/openjdk.properties"
DRAGONWELL_PROPS_FILE="$SPECJVM_TEST_HOME/Assignment3/props/dragonwell.properties"
TENCENTKONA_PROPS_FILE="$SPECJVM_TEST_HOME/Assignment3/props/tencentkona.properties"
BISHENG_PROPS_FILE="$SPECJVM_TEST_HOME/Assignment3/props/bisheng.properties"

# （可选）加载用户环境变量
source ~/.bashrc

echo "=== 启动 SPECjvm2008 ==="
java \
  -Dspecjvm.home.dir="$BASEDIR" \
  -jar "$BASEDIR/SPECjvm2008.jar" \
  -ikv \
  -pf "$OPENJDK_PROPS_FILE" \
  &> results/perf_specjvm.out &
SPEC_PID=$!

echo "SPECjvm2008 已启动，PID = $SPEC_PID"
echo "等待 200 秒让程序进入稳定期..."
sleep 200

echo "=== 开始 perf stat 监测（持续 ${DURATION}s） ==="
perf stat -p "$SPEC_PID" \
  -e cycles,instructions,branches,branch-misses,cache-references,cache-misses \
  -- sleep "$DURATION" \
  &> results/perf_stat.log &

STAT_PID=$!

echo "=== 开始 perf record 采样（持续 ${DURATION}s） ==="
perf record -F 99 -g -p "$SPEC_PID" \
  -- sleep "$DURATION" \
  &> results/perf_record.log &

RECORD_PID=$!

# 等待两个监测都结束
wait $STAT_PID
wait $RECORD_PID



echo "监测完成："
echo "  • perf stat 日志 -> results/perf_stat.log"
echo "  • perf record 日志 -> results/perf_record.log"
echo "  • perf record 数据 -> perf_record.data"

# 等待 SPECjvm2008 进程结束
echo "=== 等待 SPECjvm2008 (PID=$SPEC_PID) 运行完成 ==="
wait $SPEC_PID

echo "SPECjvm2008 已完成 (PID=$SPEC_PID)"