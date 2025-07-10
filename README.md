# ZJU-PerformanceMeasurement-Evaluation-Analysis

## 测试环境

#### 1. 硬件平台

- **CPU**  
  - 型号：AMD EPYC 7343 16-Core Processor  
  - 架构：x86_64，支持 32-bit、64-bit  
  - 核心/线程：16 核 × 2 线程（共 32 线程），两颗插槽共 64 逻辑 CPU（在线 CPU 列表：0–63）  
  - 主频：最低 1.5 GHz，最高加速至 3.940 GHz  
  - 缓存：L1d 1 MiB, L1i 1 MiB, L2 16 MiB, L3 256 MiB（8 实例）  
  - NUMA：2 个节点（节点0: CPU 0–15,32–47；节点1: CPU 16–31,48–63）

- **内存**  
  - 总量：512 GiB DDR4 RDIMM

- **存储**  
  - NVMe SSD（型号与容量依据实际环境填写，例如 Samsung PM1733 2 TB）

#### 2. 软件环境

- **操作系统**  
  - Ubuntu 22.04 LTS  
  - 内核版本：5.15.0-…generic  

- **JVM**  
  - 版本：OpenJDK 1.8.0_452  
  - 运行时：OpenJDK 64-Bit Server VM (build 25.452-b09, mixed mode)  


- **SPECjvm2008**  
  - 版本：1.1

## 描述
`Assignment1/a1_README.md`记录完成Assignment1步骤。
`Assignment2/a2_README.md`记录完成Assignment2步骤。
`Assignment3/a3_README.md`记录Assignment3步骤。