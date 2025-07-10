import os
import re
import sys
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import pingouin as pg
import seaborn as sns
from scipy import stats
from scipy.stats import ttest_rel


# 指定当前 run_id
run_id = sys.argv[1] if len(sys.argv) > 1 else "SPECjvm2008.001"

files = {
    "Huawei_Bisheng":     f"results/bisheng_results/{run_id}/{run_id}.txt",
    "Alibaba_Dragonwell": f"results/dragonwell_results/{run_id}/{run_id}.txt",
    "OpenJDK":            f"results/openjdk_results/{run_id}/{run_id}.txt",
    "Tencent_Kona":       f"results/tencentkona_results/{run_id}/{run_id}.txt",
}

line_re = re.compile(r"iteration\s+\d+.*?([0-9]+\.[0-9]+)\s*$")
opspm = {}

for jdk, path in files.items():
    if not os.path.exists(path):
        raise FileNotFoundError(f"Cannot find report: {path}")
    with open(path) as f:
        vals = [
            float(m.group(1))
            for line in f
            if "iteration" in line
            for m in [line_re.search(line)]
            if m
        ][:5]
    opspm[jdk] = vals

data = pd.DataFrame(
    [
        *[{"JDK": "Huawei_Bisheng",     "ops/m": v} for v in opspm["Huawei_Bisheng"]],
        *[{"JDK": "Alibaba_Dragonwell","ops/m": v} for v in opspm["Alibaba_Dragonwell"]],
        *[{"JDK": "OpenJDK",           "ops/m": v} for v in opspm["OpenJDK"]],
        *[{"JDK": "Tencent_Kona",      "ops/m": v} for v in opspm["Tencent_Kona"]],
    ]
)


# 平均数&中位数
summary = []

for jdk in data["JDK"].unique():
    jdk_data = data[data["JDK"] == jdk]["ops/m"]

    arithmetic_mean = jdk_data.mean()
    geometric_mean = stats.gmean(jdk_data)
    median = jdk_data.median()

    summary.append(
        {
            "JDK": jdk,
            "算数平均数": arithmetic_mean,
            "几何平均数": geometric_mean,
            "中位数": median,
        }
    )

summary_data = pd.DataFrame(summary)
print(summary_data.to_string(index=False, na_rep="nan"))

# 标准差
print("\n")
std_dev = []

for jdk in data["JDK"].unique():
    jdk_data = data[data["JDK"] == jdk]["ops/m"]
    std_dev.append({"JDK": jdk, "标准差": jdk_data.std()})

std_dev_data = pd.DataFrame(std_dev)
print(std_dev_data.to_string(index=False, na_rep="nan"))

# 正态性检验(Shapiro-Wilk)
print("\n\n正态性检验(Shapiro-Wilk):")
for jdk in data["JDK"].unique():
    jdk_data = data[data["JDK"] == jdk]["ops/m"]
    stat, p = stats.shapiro(jdk_data)
    result = "服从正态分布" if p > 0.01 else "不服从正态分布"
    print(f"{jdk}: W={stat:.4f}, p={p:.4f} -> {result}")

# 配对T检验
print("\n\n配对T检验:")
baseline = opspm["OpenJDK"]
other_jdks = ["Huawei_Bisheng", "Alibaba_Dragonwell", "Tencent_Kona"]

for jdk in other_jdks:
    t_stat, p_value = stats.ttest_rel(baseline, opspm[jdk])
    # significance = "显著" if p_value < 0.05 else "不显著"
    print(f"\n{jdk} 与 OpenJDK 对比:")
    print(f"t统计量: {t_stat:.4f}")
    print(f"p值: {p_value:.6f} ")


print("\n\n")

# 球形性检验
wide_data = pd.DataFrame(opspm)
wide_data["subject"] = range(1, len(wide_data) + 1)
melted_data = pd.melt(wide_data, id_vars="subject", var_name="JDK", value_name="ops/m")

sphericity_test = pg.sphericity(
    melted_data, dv="ops/m", within="JDK", subject="subject"
)
print("\n球形性检验:")
print(f"Mauchly's W: {sphericity_test[1]:.4f}")
print(f"p值: {sphericity_test[4]:.4f}")

# ANOVA
if sphericity_test[4] > 0.05:
    print("球形性假设满足,使用标准重复测量ANOVA。")
    anova = pg.rm_anova(dv="ops/m", within="JDK", subject="subject", data=melted_data)
else:
    print("球形性假设不满足,使用Greenhouse-Geisser校正。")
    anova = pg.rm_anova(
        dv="ops/m", within="JDK", subject="subject", data=melted_data, correction=True
    )

print("\nANOVA:")
print(anova)

# 事后检验(Holm-Bonferroni校正)
print("\n\n事后检验:")
posthoc = pg.pairwise_tests(
    data=melted_data,
    dv="ops/m",
    within="JDK",
    subject="subject",
    padjust="holm",
    parametric=True,
    # 使用默认的'hedges'
)

print(posthoc[["A", "B", "p-corr", "hedges"]])

# 绘图
plot_data = pd.merge(summary_data, std_dev_data, on="JDK")
plot_data = plot_data.sort_values(by="算数平均数", ascending=False)

plt.figure(figsize=(8, 5))
plt.ylim(3000, 3700)
bars = plt.bar(
    plot_data["JDK"], plot_data["算数平均数"], yerr=plot_data["标准差"], capsize=5
)
plt.ylabel("ops/m")
for bar, mean, std in zip(bars, plot_data["算数平均数"], plot_data["标准差"]):
    height = bar.get_height()
    label = f"{mean:.1f}±{std:.1f}"
    plt.text(
        bar.get_x() + bar.get_width() / 2,
        height + 2,
        label,
        ha="center",
        va="bottom",
        fontsize=9,
    )
plt.ylabel("ops/m", fontsize=12)
plt.title("SPECjvm2008 Compress Performance: Mean ± Std by JDK")
plt.xticks(rotation=15)
plt.tight_layout()
plt.savefig("mean_std_bar.png")
print("Saved bar chart to mean_std_bar.png")


# 事后检验
def compute_score(row):
    g = row["hedges"]
    p = row["p-corr"]
    p = max(p, 1e-10)
    return np.sign(g) * abs(g) * -np.log10(p)


posthoc["score"] = posthoc.apply(compute_score, axis=1)
jdks = sorted(set(posthoc["A"]) | set(posthoc["B"]))
score_matrix = pd.DataFrame(np.nan, index=jdks, columns=jdks)

for _, row in posthoc.iterrows():
    a, b = row["A"], row["B"]
    score = row["score"]
    score_matrix.loc[a, b] = score
    score_matrix.loc[b, a] = -score

plt.figure(figsize=(6.5, 5.5))
sns.heatmap(
    score_matrix,
    annot=True,
    fmt=".2f",
    cmap="coolwarm",
    center=0,
    linewidths=0.5,
    cbar_kws={"label": r"Effect Size x $-\log_{10}(p)$"},
)
plt.title("Post-hoc Comparison Heatmap: Effect Size x -log10(p)")
plt.tight_layout()
plt.savefig("posthoc_heatmap.png")
print("Saved posthoc heatmap to posthoc_heatmap.png")
