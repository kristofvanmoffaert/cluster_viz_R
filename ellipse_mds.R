ellipse_MDS <- function(datas, predictions, centroids=NULL) {
  
  # get unique labels
  unique_predictions = unique(predictions)
  num_clusters = length(unique_predictions)
  num_features = ncol(datas)
  
  # possibilty to calculate centroids yourself
  if (is.null(centroids)) {
    all_mean_values = matrix(nrow= num_clusters, ncol=num_features)
    
    for (cl in unique_predictions) {
      mean_values = colMeans(datas[predictions == cl, ])
      all_mean_values[cl, ] = mean_values
    }
    centroids = data.frame(all_mean_values)
    colnames(centroids) = colnames(datas)
  }

  # Some cluster properties:
  # amount of members for each cluster
  cluster_sizes = as.vector(table(predictions))
  # same but procentually
  cluster_procentual_sizes = cluster_sizes/sum(cluster_sizes)
  # silhouette score
  sil = silhouette(predictions, dist(datas))
  # average silhouette score per cluster
  withinss = sapply(unique_predictions, function(cl) {mean(sil[pred==cl, 'sil_width'])})
  # scale the centroids (for visualisation)
  centroids = scale(centroids)
  # calculate distances between centroids
  d <- dist(centroids) # euclidean distances between the rows
  # normalize distances
  d <- d / max(d)

  # Use multi-deimensional scaling (MDS) to calculate 2-d coordinates that
  # approximate the (multi-dimensional) distances as best as possible in 2-d
  #fit2 <- cmdscale(d,eig=TRUE, k=2) # k is the number of dim
  fit <- smacofSym(d, ndim = 2)
  
  # get coordinates in 2-d
  x_coord <- fit$conf[, 1]
  y_coord <- fit$conf[, 2]
  
  # some string arithmic
  feature_names = dimnames(datas)[[2]][1:columns-1]
  std_feature_names = sapply(feature_names, function(x) { paste0("std_", x) })
  skew_feature_names = sapply(feature_names, function(x) { paste0("skew_", x) })
  mean_feature_names = sapply(feature_names, function(x) { paste0("mean_", x) })
  
  # store standard deviation data per feature per cluster
  std_data = matrix(, nrow=num_clusters, ncol = columns-1, dimnames=list(seq(1, num_clusters), std_feature_names))
  # store mean data per feature per cluster
  mean_data = matrix(, nrow=num_clusters, ncol = columns-1, dimnames=list(seq(1, num_clusters), mean_feature_names))
  
  # fill them!
  for (feature_i in seq(1,columns-1)) { 
    stds = sapply(seq(1:num_clusters), function(cls) {sd(datas[pred == cls, feature_i])})
    means = sapply(seq(1:num_clusters), function(cls) {mean(datas[pred == cls, feature_i])})
    for (cl in seq(1,num_clusters)) {
      min_std = min(stds)
      max_std = max(stds)
      norm_std = 1 - ((stds[cl] - min_std) / (max_std - min_std))
      # normalize and store std data
      std_data[cl, feature_i] =  norm_std
      
      
      min_mean = min(means)
      max_mean = max(means)
      norm_mean = 1 - ((means[cl] - min_mean) / (max_mean - min_mean))
      # normalize and store mean data
      mean_data[cl, feature_i] =  norm_mean
    }
  }
  
  # store in object
  plot_data = data.frame('x_coord' = x_coord, 'y_coord' = y_coord, size = cluster_sizes, procentual_sizes = cluster_procentual_sizes, ss=withinss)
  # add all 
  plot_data_medium = cbind(plot_data, std_data)
  plot_data_full = cbind(plot_data_medium, mean_data)
  

  mar <- par("mar"); #mar[c(2, 4)] <- 0
  par(mfrow=c(1,1), mar = c(0.1,4.1,4.1,2.1)) 
  
  
  # determine locations for radar plot
  loc = data.frame(x = plot_data_full$x_coord, y=plot_data_full$y_coord)
  # max length of segments of radar plot
  max_size = 1
  # scale sizes per cluster
  sizes = plot_data_full$procentual_size * max_size
  palette.name = palette(rainbow(12, s = 0.6, v = 0.75))
  # draw star plot
  stars(centroids, locations =loc, len = sizes, main = "Cluster visualization", draw.segments = TRUE)
  # hold on
  par(new=T)
  # draw ellipses at the same location where the size mimics the number of members per cluster
  # and the shape mimics the average silhouette score per cluster.
  # more circular : more stability in the cluster
  draw.ellipse(plot_data_full$x_coord, plot_data_full$y_coord, plot_data_full$procentual_sizes*max_size, 
               plot_data_full$procentual_sizes*max_size*plot_data_full$ss*1, 
               angle=runif(num_clusters)*360, arc.only=TRUE, lwd = 2)
  # add cluster label
  text(plot_data_full$x_coord, plot_data_full$y_coord, seq(1, num_clusters), font=2)
  # and legend
  legend("right", fill=1:ncol(X), legend = colnames(X), bty="o", ncol=1) 
  
  
  
  # prepare colors for inidividual feature plot
  colfunc<-colorRampPalette(c("white","royalblue"))
  colors = colfunc(100)
  # new plot
  mar <- par("mar"); mar[c(2, 4)] <- 0
  par(mfrow=c(1,1), mar = c(0.1,2.1,2.1,2.1)) 
  
  # per feature, draw ellipse at same locations of cluster
  # color : normalized mean value per feature per cluster
  # shape: standard deviation per feature per cluster
  for (feature_i in seq(1, columns-1)) {
    # prepare plot
    plot(xlab='', 0,  xlim=c(-1.5,1.5), ylim=c(-1.5,1.5), axes=FALSE, type="n",  ylab='', main=colnames(mydata)[feature_i])
    # indexers
    std_string = std_feature_names[feature_i]
    mean_string = mean_feature_names[feature_i]
    par(new=T)
    # draw the ellipse with all of its properties
    draw.ellipse(plot_data_full$x_coord, plot_data_full$y_coord, 0.3, 
                 (0.3-plot_data_full[[std_string]]+0.1)*1.0, 
                 angle=runif(num_clusters)*360, arc.only=TRUE, lwd = 2, col=colors[floor(plot_data_full[[mean_string]] * 99 + 1)])
    # add color bar
    image.plot(legend.only=T, zlim=range(plot_data_full[std_string]), col=colors)
    #  color.legend(200,0,220,100,legend=c("min","max"), 
    #               rect.col=c("darkviolet","deepskyblue4","green","yellow","red")) 
    par(new=T)
    # and text
    text(plot_data_full$x_coord, plot_data_full$y_coord, seq(1, num_clusters), font=2)
  }

  # return data object
  return(plot_data_full)
  
}