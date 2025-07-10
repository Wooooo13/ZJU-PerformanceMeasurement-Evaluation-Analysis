# 把 perf.data 转成文本
perf script > out.perf

# 折叠调用栈
$FLAMEGRAPH_HOME/stackcollapse-perf.pl out.perf > out.folded

# 生成 SVG
$FLAMEGRAPH_HOME/flamegraph.pl --title="SPECjvm2008 Hot Methods" \
                           --width=1200 \
                           out.folded > perf-flamegraph.svg


