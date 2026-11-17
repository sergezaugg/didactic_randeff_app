# ---------------------------
# Description : text to be used in pages
# Author : Serge Zaugg
# ---------------------------

ptext <- list(
  
  about_tx_1 = "
    Clustered data are common in real-world applications, such as repeated measurements, 
    cluster-randomized trials, or ecological data collected across regions.
    A widely used statistical approach for analysing such data is the 
    linear mixed-effects model (LMM). However, its underlying principles can be difficult to grasp, 
    particularly for those without a statistical background.  
    This app aims to bridge that gap by providing an intuitive, interactive way to explore 
    clustered data, experiment with different data structures, and understand how 
    LMMs behave. It also allows users to compare their results with those from simple 
    linear models (SLM), which do not account for clustering and are 
    generally inappropriate for this type of data. They are 
    included for educational purposes, to illustrate why accounting for clustering matters.
    ",
  
  about_tx_2 = "
    We first simulate clustered data using predefined true parameters. Users can specify the 
    between-cluster variance, residual variance, 
    and the true difference in means between groups A and B.
    For simplicity, the number of observations per cluster is fixed and equal across all clusters.
    The simulated data are then analysed using both a linear mixed-effects model (LMM) and a 
    simple linear model (SLM). The results are compared in terms of estimated group differences, 
    p-values, and confidence intervals.
    "
)

