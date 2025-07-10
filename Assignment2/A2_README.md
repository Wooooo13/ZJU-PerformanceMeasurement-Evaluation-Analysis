# Assignment 2: Software Performance Evaluation
## 系统校准  
统一设置 CPU 调度模式（governor）
```bash
# 查看所有CPU的调度模式
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 设置为performance模式
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
``` 
统一设置I/O 调度器
```bash
# 查看当前磁盘的I/O调度器（例如sda、nvme0n1）
cat /sys/block/{sda,nvme0n1}/queue/scheduler

# 设置为deadline或none（NVMe建议none）
echo deadline | sudo tee /sys/block/sda/queue/scheduler
echo none | sudo tee /sys/block/nvme0n1/queue/scheduler
```

## 安装JDK 路径`/opt/jdks`
- `openjdk 1.8.0_452` 在 `~/.bashrc`中已经配置
- `Alibaba_Dragonwell_Standard_8.25.24_x64_linux` （dragonwell-8）下载地址[Dragonwell 8](https://dragonwell.oss-cn-shanghai.aliyuncs.com/8.25.24/Alibaba_Dragonwell_Standard_8.25.24_x64_linux.tar.gz)
- `TencentKona8.0.22.b1_jdk_linux-x86_64_8u452` （TencentKona-8）下载地址[TencentKona-8](https://github.com/Tencent/TencentKona-8/releases/download/8.0.22-GA/TencentKona8.0.22.b1_jdk_linux-x86_64_8u452.tar.gz)
- `bisheng-jdk-8u452-b12-linux-x64` （bisheng-8）下载地址[毕昇JDK 8](https://www.hikunpeng.com/developer/devkit/download/jdk)

--------------------------

项目结构
```
Assignment2/
├── A2_README.md
├── props
│   ├── bisheng.properties
│   ├── bisheng.reporter.properties
│   ├── dragonwell.properties
│   ├── dragonwell.reporter.properties
│   ├── openjdk.properties
│   ├── openjdk.reporter.properties
│   ├── tencentkona.properties
│   └── tencentkona.reporter.properties
├── results
│   ├── analyze.py
│   ├── bisheng_results
│   ├── compress_ops_bar.png
│   ├── dragonwell_results
│   ├── openjdk_results
│   └── tencentkona_results
└── src
    └── runspecjvm.sh
```
工作负载选择：用于 CPU 密集型任务的 compress  
`runspecjvm.sh`配置每个JDK，但是只配置了`-Xmx -Xms`堆大小？

添加测试的环境变量
```bash
export SPECJVM_TEST_HOME=/home/wwow/test_SPECjvm
export SPECJVM2008_HOME=/home/wwow/SPECjvm2008
```

```bash
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
  export JAVA_HOME="/opt/jdks/$1"
  export JRE_HOME="$JAVA_HOME/jre"
  PATH="$(echo "$PATH" | tr ':' '\n' | grep -v "$JAVA_HOME" | paste -sd: -)"
  export PATH="$JAVA_HOME/bin:$PATH"
  export CLASSPATH=".:$JAVA_HOME/lib/"
  echo "Switched to $1:"
  java -version
}
# usejdk dragonwell-8

source ~/.bashrc
java \
  -Xms8G -Xmx8G \
  -Dspecjvm.home.dir="$BASEDIR" \
  -jar "$BASEDIR/SPECjvm2008.jar" \
  -ikv \
  -pf "$OPENJDK_PROPS_FILE"

# AI给的这一块，看不懂
#     -XX:+AlwaysPreTouch \
#   -XX:+UseParallelGC \
#   -XX:ParallelGCThreads=$(nproc) \
#   -XX:ConcGCThreads=$(( $(nproc)/2 )) \
#   -XX:+UseLargePages \
#   -XX:+UseTransparentHugePages \
#   -XX:-UseBiasedLocking \

usejdk dragonwell-8
java \
  -Xms8G -Xmx8G \
  -Dspecjvm.home.dir="$BASEDIR" \
  -jar "$BASEDIR/SPECjvm2008.jar" \
  -ikv \
  -pf "$DRAGONWELL_PROPS_FILE"

#
usejdk TencentKona-8
java \
  -Xms8G -Xmx8G \
  -Dspecjvm.home.dir="$BASEDIR" \
  -jar "$BASEDIR/SPECjvm2008.jar" \
  -ikv \
  -pf "$TENCENTKONA_PROPS_FILE"

#
usejdk bisheng-8
java \
  -Xms8G -Xmx8G \
  -Dspecjvm.home.dir="$BASEDIR" \
  -jar "$BASEDIR/SPECjvm2008.jar" \
  -ikv \
  -pf "$BISHENG_PROPS_FILE"
```

`props/*.properties`文件中都配置迭代次数为5
```
specjvm.miniter=5
specjvm.maxiter=5
```

`analyze.py`用于画图和分析`compress_ops_bar.png`
```
(specjvm_env) wwow@LAPTOP-LF7LLJ3M:~/test_SPECjvm/Assignment2$ python3 results/analyze.py 
=== 平均值和标准差 ===
                Mean       Std
bisheng     1139.708  5.316838
dragonwell  1131.918  2.987034
openjdk     1131.638  8.562019
tencentkoa  1131.554  4.272760
Saved bar chart to compress_ops_bar.png

=== Paired t-test 结果 ===
bisheng vs dragonwell: t=2.647, p=0.057
bisheng vs openjdk: t=2.358, p=0.078
bisheng vs tencentkoa: t=2.541, p=0.064
dragonwell vs openjdk: t=0.065, p=0.952
dragonwell vs tencentkoa: t=0.121, p=0.910
openjdk vs tencentkoa: t=0.017, p=0.987
```

![平均值和误差线](https://pic1.imgdb.cn/item/686a60ac58cb8da5c8928781.png)



删除目标文件夹
```bash
# 先做一次“演练”，仅列出要删除的目录
find results -type d -name 'SPECjvm2008.002' -print
# 如果列表没问题，就真正删除
find results -type d -name 'SPECjvm2008.002' -exec rm -rf {} +
```

## Bonus Points
Answer the following questions. Deep analysis is welcome.
1. **Why is there run to run performance variation?**
   **为什么不同运行（run）之间会出现性能波动？**
   不同运行之间存在性能波动，是因为现代计算环境本质上是非确定性的：操作系统可能插入后台任务，JIT 编译和垃圾回收在不同时间点触发，CPU 缓存、TLB 和分支预测器的“热身”状态各不相同，甚至功耗管理和温度调节也会动态改变处理器频率，这些因素共同造成同一基准在多次执行时产生不同的测量结果。
2. **What contributes to run-to-run variation?**
   **哪些因素会导致这种运行间（run-to-run）的性能差异？**
   跑分抖动的主要来源包括：操作系统调度与中断、后台 daemon、I/O 活动对 CPU 的抢占；JIT 编译何时优化热点方法以及垃圾回收何时暂停应用；缓存和 TLB 冷/热状态下的内存访问差异；处理器的功耗/温度管理（如 Turbo Boost）导致的主频变化；以及硬件中断、上下文切换等微观事件对基准线程的干扰。
3. **How do we validate the factors contributing to run-to-run variation?**
   **我们如何验证这些因素对性能波动的影响？**
   验证这些抖动因素通常需要受控实验：通过绑定线程到固定核、关闭频率调节（固定 P-态）来排除调度与功耗影响；丢弃预热迭代以稳定缓存和 JIT；开启 GC/JIT 日志、使用硬件性能计数器（缓存未命中、分支预测失败、上下文切换等）来关联性能异常；以及有选择地打开或关闭子系统，再比较运行间抖动幅度，以量化各子系统对性能变异的贡献。
4. **What are the pros and cons of using arithmetic mean versus geometric mean in summarizing scores?**
   **在汇总多个分数时，使用算术平均数与几何平均数各有什么优缺点？**
   在汇总多项基准分数时，算术平均直观易懂，却会被极端值拉偏且无法对称合并倍数变化；而几何平均能公平地对待加速与减速（2× 慢与 0.5× 快平均回 1×），但理解不如算术平均直观并且要求所有值为正。两者各有优缺点，选择时应考虑数据的分布特性和度量目的。
5. **Why does SPECjvm2008 use geometric mean? (In fact, it uses hierarchical geometric mean)**
   **为什么 SPECjvm2008 采用几何平均数？（实际上，它使用分层几何平均数）**
   SPECjvm2008 采用分层几何平均，一方面因为各子基准输出的是“参考时间÷测量时间”的比率，几何平均才能保持加速／减速的对称与公平；另一方面它先在每个基准组内做一次几何平均，再对所有组的分数再做一次几何平均，保证没有某一组因子基准数量或时长不同而主导整体结果，从而得到更均衡、公正的综合性能评分。
