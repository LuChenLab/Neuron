---
title: "Untitled"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

```{r}
nanop <- as.data.frame(t(openxlsx::read.xlsx("/mnt/data5/xumengying/proj/NSC_yan_2020_10_30/analysis/00.QC/01.NanoComp/qc.xlsx",sheet = 1, rowNames = T)))
nanop$stage <- factor(rownames(nanop), levels = c("E15.5" ,"E7.5",  "P1.5",  "P8" ,   "Adult"),
                      labels = c("E15.5" ,"E17.5"  ,"P1.5",  "P8" ,   "Adult"))
colnames(nanop) <- gsub(" ", "_", colnames(nanop))
```


## read quality

```{r  fig.width=5, fig.height=3}
library(data.table)
library(ggplot2)
nano1 <- fread("/mnt/data5/xumengying/proj/NSC_yan_2020_10_30/analysis/00.QC/01.NanoComp/NanoComp-data.tsv")
nano1$dataset <- factor(nano1$dataset, levels = c("E15.5" ,"E7.5",  "P1.5",  "P8" ,   "Adult"),
                      labels = c("E15.5" ,"E17.5"  ,"P1.5",  "P8" ,   "Adult"))
cairo_pdf("./Reads_quality.pdf", 5,3)
ggplot(nano1, aes(dataset, quals, fill = dataset)) +
  geom_violin(width = 0.7)+
  stat_summary(fun.y = "mean",geom = "point",shape = 23, size = 2,fill = "white") +
  labs(y = "Read quality")+
  theme_classic() + 
  theme(axis.title = element_text(size = 14,family = "Arial"),
        axis.title.x=element_blank(),
        axis.text = element_text(size = 10,family = "Arial"), 
        axis.text.x = element_text(),
        legend.text=element_text(size=10,family = "Arial"),
        legend.title= element_blank())+
    geom_hline(yintercept=7, size= 0.5, linetype="dashed", color="black")

dev.off()
```
## random_length
```{r fig.width=6, fig.height=3.5}
#random_length <- sample_n(nano1[nano1$lengths <100000, ],50000)
#saveRDS(random_length, file = "/mnt/data5/xumengying/proj/NSC_yan_2020_10_30/analysis/00.QC/01.NanoComp/random_length.Rds")
random_length <- readRDS("/mnt/data5/xumengying/proj/NSC_yan_2020_10_30/analysis/00.QC/01.NanoComp/random_length.Rds")
bins = round(100000 / 500)
library(plyr)
cdat <- ddply(random_length, "dataset", summarise, rating.mean=mean(lengths))

cairo_pdf("./Reads_length.pdf", 5,3)
ggplot(random_length, aes(x=log2(lengths),  fill=dataset)) +
    geom_density(position="identity", alpha=.5) +
 #   labs(x = "Length") +
    labs(x = "Read length", y= "Density")+
    geom_vline(data=cdat, 
               aes(xintercept=log2(rating.mean), 
                   colour= dataset),
               linetype="dashed", 
               size=0.5, show.legend = F)+
    theme_classic()+
    theme(axis.title = element_text(size = 14,family = "Arial"),
       # axis.title.x=element_blank(),
        axis.text = element_text(size = 10,family = "Arial"), 
        axis.text.x = element_text(),
        legend.text=element_text(size=10,family = "Arial"),
        legend.title= element_blank())+
  scale_x_continuous(breaks=c(6,8,10,12),labels=c(2^6,2^8,2^10,2^12))
dev.off()
```



