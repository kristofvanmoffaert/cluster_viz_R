# cluster_viz_R

A while ago I was investigating visualization techniques for clusters. When the dimensionality is high, often the means to visually present and interpret the results are limited. Usually, researchers then limit the visualisation to plot a subset of two or three dimensions to investigate whether the clusters are representative and meaningful. Other techniques are included at https://www.quora.com/Whats-the-best-way-to-visualize-high-dimensional-data. 

What I thought is missing is an alternative visualization technique where one could have more insights in the clusters at a global and local level. At a global level, the distance between the clusters in important to obtain a clear segmentation of the search space. At a local level, it is of crucial importance that the variation of the members within a cluster remains limited, since we want our cluster to be a general but compact representation of a subset of the feature space. Additionally, we also want to know which features are more or less important for which cluster and we want to grasp this information fast and intuitively.

In this package, I created an alternative visualization technique that tries to overcome these limitations. This code shows:
- The centroids of each of the clusters
- Distributed the (multi-dimensional) clusters on a 2D grid using multi-dimensional scaling
- A radar plot of the values for each feature for each cluster
- Scales the sizes of each radar plot based on the amount of members of each clusters
- Draws an ellipse around the radar plot indicating the average silhouette score of each cluster

An example figure can be found below:

->![alt text](https://raw.githubusercontent.com/kristofvanmoffaert/cluster_viz_R/master/viz.png)<-

In this figure, we visualize the k-means clustering algorithm with k=6 on the wines dataset, publicly available in R. From this visualisation, we can distil multiple properties:
- Clusters 2 and 4 are easily distinguishable since they are displayed at a large distance from each other
- Clusters 3 and 6 are relatively similar. Hence, it is possible that the predictions of these clusters might be faulty on unseen instances.
- Also taking into account the shape of clusters 3 and 6, i.e., both being oval, the average silhouette score is indicating significant amounts of variation within the cluster itself. Therefore, both their distance and shape indicate it could be fruitful to run the clustering algorithm again with k=5 since both clusters could be merged.
- Also, we see the (normalized) value of each feature for each cluster. For instance, in cluster 5, the 'non-flav phenols' feature has, on average, a high value.
- The angles of the ellipses are assigned randomly

Additionally, we also provide plots that investigate the clusters based on local features as well. Some examples from the same dataset can be found below:

->![alt text](https://raw.githubusercontent.com/kristofvanmoffaert/cluster_viz_R/master/ash.png)<-
->![alt text](https://raw.githubusercontent.com/kristofvanmoffaert/cluster_viz_R/master/alcohol.png)<-
->![alt text](https://raw.githubusercontent.com/kristofvanmoffaert/cluster_viz_R/master/malic.png)<-
->![alt text](https://raw.githubusercontent.com/kristofvanmoffaert/cluster_viz_R/master/magnesium.png)<-

Some other properties (other than cluster distances which is also shown) that can be retained from these plots are:
- Considering the 'ash' feature, cluster 6 contains, on average, the highest mean values but the variation is huge as well (since it is very flat). The same feature is very stable in cluster 5 (circular shape) while having medium-scale values, so we can say that feature 'ash' is a feature that is prominent and distinguishable in cluster 5.
- The alcohol feature does not seem to be a very prominent feature over all clusters since each cluster's shape is oval
- On the other hand, the 'malic acid' feature is relatively stable for clusters 2, 3, 5 and 6. In clusters 1 and 4 it is of less importance.
- The feature 'magnesium' has very low values in cluster 6 while also being very wide-spread. The spread in cluster 3 is also remarkable. Another indication that both clusters should be merged?
