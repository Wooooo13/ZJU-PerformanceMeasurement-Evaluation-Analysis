# Assignment 3: Software Performance Analysis
结合使用 perf、FlameGraph 以及其他辅助工具，仔细地定位并可视化所选 Java 应用的关键执行路径。这里选用 SPECjvm2008 基准套件中的compress工作负载。

文件结构
```
Assignment3
├── a3_README.md
├── out.folded
├── out.perf
├── perf.data
├── perf-flamegraph.svg
├── props
│   ├── openjdk.properties
│   └── openjdk.reporter.properties
├── results
│   ├── openjdk_results
│   ├── perf_record.log
│   ├── perf_specjvm.out
│   └── perf_stat.log
└── src
    ├── flamegraph.sh
    └── perf.sh
```

`perf.sh`用来运行SPECjvm2008、perf stat和perf record的脚本，监测时长都是60s。
`perf record -F`指定了采样频率为 99 Hz，也就是大约每秒采集 99 次样本，平均每隔约 10 ms 进行一次采样，生成`perf.data`文件。

采样结束后运行
```bash
perf report
```
对 perf record 收集到的数据进行汇总展示，按函数或符号列出占用样本最多的条目，帮助快速定位最耗时的代码段。

`./src/flamegraph`生成火焰图`perf-flamegraph.svg`。