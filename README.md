# quickSave

快速、简洁的 R 绘图保存工具包。简化 ggplot2 和 Seurat 绘图的保存流程。

## 安装

```r
devtools::install_local("path/to/quickSave")
```

## 快速开始

### 基础用法

```r
library(quickSave)
library(ggplot2)

# 创建一个图
p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()

# 一行代码保存
qsave(p, "scatter.pdf", "./results")
```

### 保存为多种格式

```r
# 同时保存为 PDF 和 PNG
qsave_multi(p, "scatter", "./results", formats = c("pdf", "png"))
```

### 批量保存多个图

```r
plots <- list(
  dimplot = DimPlot(obj, label = T),
  featureplot = FeaturePlot(obj, features = "CD4"),
  vlnplot = VlnPlot(obj, features = "nFeature_RNA")
)

qbatch_save(plots, "./results", prefix = "fig")
# 自动生成: 01.dimplot.pdf, 02.featureplot.pdf, 03.vlnplot.pdf
```

### 使用 PlotSaver 对象

```r
saver <- plot_saver("./results")

saver$save(plot1, "dimplot.pdf")
saver$save(plot2)  # 自动编号: 02.plot.pdf
saver$save(plot3, width = 6, height = 4)

# 查看保存信息
saver$get_count()  # 返回已保存的图数
```

## 函数列表

| 函数 | 功能 |
|------|------|
| `qsave()` | 保存单个图为 PDF |
| `qsave_multi()` | 保存单个图为多种格式 |
| `qbatch_save()` | 批量保存多个图 |
| `plot_saver()` | 创建 PlotSaver 对象 |

## 使用场景

### 场景 1：单细胞分析流程

```r
library(Seurat)
library(quickSave)

saveloc <- "./analysis/results"

# 创建多个可视化
p1 <- DimPlot(obj, label = T, repel = T) + NoLegend()
p2 <- FeaturePlot(obj, features = c("CD4", "CD8A"))
p3 <- VlnPlot(obj, features = "nFeature_RNA")

# 快速保存
qsave(p1, "01.dimplot.pdf", saveloc, width = 5, height = 5)
qsave(p2, "02.featureplot.pdf", saveloc, width = 8, height = 6)
qsave(p3, "03.vlnplot.pdf", saveloc, width = 6, height = 4)
```

### 场景 2：使用 PlotSaver 简化代码

```r
library(Seurat)
library(quickSave)

saver <- plot_saver("./analysis/results")

saver$save(DimPlot(obj, label = T, repel = T) + NoLegend())
saver$save(FeaturePlot(obj, features = c("CD4", "CD8A")))
saver$save(VlnPlot(obj, features = "nFeature_RNA"))

# 输出:
# ✓ [01] ./analysis/results/01.plot.pdf
# ✓ [02] ./analysis/results/02.plot.pdf
# ✓ [03] ./analysis/results/03.plot.pdf
```

### 场景 3：多格式同时保存

```r
library(quickSave)

saver <- plot_saver("./results")

qsave_multi(
  plot,
  "dimplot",
  saver$get_dir(),
  formats = c("pdf", "png", "jpg"),
  width = 5,
  height = 5
)
```

## 与 analysisDir 包结合

结合 `analysisDir` 包创建完美的工作流：

```r
library(analysisDir)
library(quickSave)

# 创建带时间戳的目录
saveloc <- mkdir("C610", "cell_annotation")

# 使用 PlotSaver 快速保存
saver <- plot_saver(saveloc)

saver$save(DimPlot(qc_obj, label = T, repel = T) + NoLegend())
saver$save(FeaturePlot(qc_obj, features = "CD4"))
saver$save(VlnPlot(qc_obj, features = "nFeature_RNA"))

# 所有文件自动保存到: C610_2024_01_14_cell_annotation/
```

## 参数说明

### qsave()

- `plot`: ggplot 对象
- `filename`: 文件名（可不含 .pdf 扩展名）
- `savedir`: 保存目录
- `width`: 图宽（英寸，默认 4）
- `height`: 图高（英寸，默认 4）
- `verbose`: 是否打印保存信息（默认 TRUE）

### qsave_multi()

- `formats`: 保存格式向量，可选: "pdf", "png", "jpg", "jpeg", "tiff"
- `dpi`: 栅格格式的分辨率（默认 300）
- 其他参数同 qsave()

### qbatch_save()

- `plots`: 绘图对象列表（可命名）
- `prefix`: 文件名前缀（默认 "plot"）
- 其他参数同 qsave_multi()

### PlotSaver 对象

方法：
- `save(plot, filename = NULL, width = 4, height = 4, dpi = 300)`: 保存图
- `reset()`: 重置计数器
- `get_dir()`: 获取保存目录
- `get_count()`: 获取当前计数

## 常见问题

**Q: 为什么要用 qsave 而不是 ggsave？**

A: qsave 更简洁，自动处理路径和文件名，支持 verbose 输出，更符合生物信息学分析的习惯。

**Q: 支持 base R 图吗？**

A: 目前主要针对 ggplot2。Base R 图可以使用传统的 pdf() 和 dev.off()。

**Q: 文件会被覆盖吗？**

A: 会。如果需要避免覆盖，建议使用 analysisDir 生成带时间戳的目录。

**Q: 为什么保存的图看起来变形了？**

A: 调整 `width` 和 `height` 参数。不同图类型可能需要不同的宽高比。

## 版本历史

### v0.1.0 (2024-01)
- 初始版本
- qsave(), qsave_multi(), qbatch_save() 基础函数
- PlotSaver R6 类

---

**作者**: Zhijun Feng  
**邮箱**: fengzhj18@sina.com  
**ORCID**: 0000-0003-1813-1669  
**许可证**: MIT
