---
title: "Untitled"
author: "xumengying"
date: "2020/11/27"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# 1. load data
```{r}
files <- list.files("/mnt/data5/xumengying/proj/NSC_yan_2020_10_30/analysis/04.AS_events/02.SUPP2/minimap/v2", full.names = T,  pattern = ".ioe")

supp2 <- lapply(1:length(files), function(x){
   a <- read.table(
        files[x], 
        header = T, 
        sep = "\t", 
        stringsAsFactors = F)
   a$type <- unlist(strsplit(basename(files[x]), "_"))[2]
   a$stage <- unlist(strsplit(basename(files[x]), "_"))[1]
   return(a)
} )

supp <- do.call(rbind ,supp2)

supp$stage <- factor(supp$stage,  
                     levels = c(paste0("barcode0", rep(1:5)), "TGS"), 
                     labels  = c("E15.5", "È17.5", "P1.5", "P8", "Adult", "Complex"))
```

# 2. find overlap

```{r fig.width=8.5,fig.height=5}
sample <- unique(supp$stage)

veen_list <- lapply(1:5, function(x){
    do.call(rbind ,strsplit(supp[supp$stage == sample[x],]$event_id, ";"))[,2]
})
names(veen_list) <- sample[1:5]
library(UpSetR)
pdf("./upset.pdf",8,5)
upset(fromList(veen_list), nsets = 9, order.by = "freq")
dev.off()
```

## 2.1 veen plot

```{r }
futile.logger::flog.threshold(futile.logger::ERROR, name = "VennDiagramLogger")

library(VennDiagram)

g = venn.diagram(
          x = list( E15_5 = veen_list[[1]],
                    E17_5 = veen_list[[2]],
                    P1_5  = veen_list[[3]],
                    P8    = veen_list[[4]],
                    P60   = veen_list[[5]]),
          category.names = c("E15.5", "E17.5", "P1.5","P8", "Adult"),
          filename = NULL,
          output=FALSE,
                
          # Circles
          lwd = 2,
          lty = 'blank',
          fill = c("#F8766D", "#A3A500", "#00BF7D", "#00B0F6", "#E76BF3"),#c("dodgerblue", "goldenrod1", "darkorange1", "seagreen3", "orchid3"),  
          # 
          # # Numbers
           cex = .5,
           fontface = "bold",
          # fontfamily = "sans",
          # 
          # # Set names
           cat.cex = 1,
           cat.fontface = "bold",
           cat.default.pos = "outer",
          # cat.pos = c(-27, 27, 135),
          # cat.dist = c(0.055, 0.055, 0.085),
          # cat.fontfamily = "sans",
          # rotation = 1,
          # 
           margin = 0.07,
           print.mode=c("percent")
)

pdf("./veen.pdf",width = 4, height = 4)
grid::grid.draw(g)
dev.off()
```

# 3. sum as events

```{r}
supp_anno <- supp
supp_anno %>% dplyr::group_by(stage) %>% mutate(total_event = length(unique(event_id)))-> supp_anno
supp_anno %>% dplyr::group_by(stage,type) %>% mutate(Events.1 = length(unique(event_id)), Events = round(length(unique(event_id))/total_event *100 , 2)) -> supp_anno

plot.events <- unique(supp_anno[,c("type", "stage","Events.1","Events","total_event")])
plot.events <- plot.events[plot.events$stage != "Complex", ]
```

```{r fig.width=10, fig.height=4}
color <- "Dark2"

pdf("./supp2_as_events.pdf", 10,5)
ggplot(plot.events, aes(stage, Events.1, fill = type)) +
  geom_col(position=position_dodge())+
  labs(x = "Stage", y = "Number")+
  theme_classic() + 
  scale_fill_brewer(palette=color)+
#  scale_fill_brewer()+
  geom_text(aes(label =round(Events,0), y = Events.1+ 25), position=position_dodge(0.9), vjust = 0.1, size = 4)+
  theme(axis.title = element_text(size = 16), 
        axis.text = element_text(size = 12))
dev.off()
```
