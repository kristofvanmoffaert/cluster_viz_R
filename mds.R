# Author: Kristof Van Moffaert
# E-mail: kristof.van.moffaert_AT_gmail.com

source("ellipse_mds.R")

library(ggplot2)
library(plotrix)
library(cluster)
library(e1071)   
library(MASS)
library(smacof)
library(kohonen)
library(fields)

# Load dataset for testing purposes
data(wines)
mydata <- wines
rows = nrow(mydata)
# Determine properties
columns = ncol(mydata)
X = mydata[, 1:columns]

# Run clustering algorithm
num_clusters = 6
# In this case, K-means
kmean = pam(X, num_clusters)
# get predictions 
pred = kmean$clustering
centroids2 = kmean$medoids
#sizes = kmean$clusinfo[, 1]
#procentual_sizes = sizes/sum(sizes)
#withinss = kmean$silinfo$clus.avg.widths

# visualize clusters using radar plot, ellipses and multi-dimensional scaling (MDS)
result= ellipse_MDS(X, pred, centroids2)
