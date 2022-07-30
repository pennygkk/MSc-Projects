#   PROJECT 2: From raw data to temporal graph structure exploration
#   COURSE: Social Network Analysis
#   NAME: Panagiota Gkourioti - P2822109

################################## TASK 1 #####################################


# Load necessary packages
library(igraph)
library(data.table)
library(sjPlot)
library(RColorBrewer)

# Read csv files for each year
authors_2016 <- read.csv(file.choose(), sep = ',', header = TRUE)
authors_2017 <- read.csv(file.choose(), sep = ',', header = TRUE)
authors_2018 <- read.csv(file.choose(), sep = ',', header = TRUE)
authors_2019 <- read.csv(file.choose(), sep = ',', header = TRUE)
authors_2020 <- read.csv(file.choose(), sep = ',', header = TRUE)

# Create the networks for each year
graph_2016 <- graph_from_data_frame(authors_2016, directed=FALSE)
graph_2017 <- graph_from_data_frame(authors_2017, directed=FALSE)
graph_2018 <- graph_from_data_frame(authors_2018, directed=FALSE)
graph_2019 <- graph_from_data_frame(authors_2019, directed=FALSE)
graph_2020 <- graph_from_data_frame(authors_2020, directed=FALSE)

# Print the graphs and check whether they are weighted and undirected
print(graph_2016, e=TRUE, v=TRUE)
is.directed(graph_2016)
is.weighted(graph_2016)

print(graph_2017, e=TRUE, v=TRUE)
is.directed(graph_2017)
is.weighted(graph_2017)

print(graph_2018, e=TRUE, v=TRUE)
is.directed(graph_2018)
is.weighted(graph_2018)

print(graph_2019, e=TRUE, v=TRUE)
is.directed(graph_2019)
is.weighted(graph_2019)

print(graph_2020, e=TRUE, v=TRUE)
is.directed(graph_2020)
is.weighted(graph_2020)


################################## TASK 2 #####################################

# Create plots that visualize the 5-year evolution of diﬀerent metrics for the graph
# Number of vertices
vertices <- data.frame("year" = c("2016","2017", "2018", "2019", "2020"),
                       "vertices_number"=c(vcount(graph_2016), vcount(graph_2017), 
                                           vcount(graph_2018), vcount(graph_2019), vcount(graph_2020)))

# Number of edges
edges <- data.frame("year" = c("2016","2017", "2018", "2019", "2020"),
                       "edges_number"=c(ecount(graph_2016), ecount(graph_2017), 
                                        ecount(graph_2018), ecount(graph_2019), ecount(graph_2020)))

# Diameter of the graph
diameters <- data.frame("year" = c("2016","2017", "2018", "2019", "2020"),
                       "diameter"=c(diameter(graph_2016), diameter(graph_2017), 
                                    diameter(graph_2018), diameter(graph_2019), diameter(graph_2020)))

# Average degree
avg_degrees <- data.frame("year" = c("2016","2017", "2018", "2019", "2020"),
                        "avg_degree"=c(mean(degree(graph_2016, mode = "all")), mean(degree(graph_2017, mode = "all")), 
                                       mean(degree(graph_2018, mode = "all")), mean(degree(graph_2019, mode = "all")), mean(degree(graph_2020, mode = "all"))))

# Plots for each metric's evolution over the years
par(mfrow=c(2,2))
plot(vertices$year, vertices$vertices_number, pch=16, col="violet", xlab="year", ylab="vertices", main="Evolution of Vertices")
lines(vertices$year,vertices$vertices_number,col = "black")

plot(edges$year, edges$edges_number, pch=16, col="steelblue", xlab="year", ylab="edges", main="Evolution of Edges")
lines(edges$year, edges$edges_number, col = "black")

plot(diameters$year, diameters$diameter, pch=16, col="red", xlab="year", ylab="diameter", main="Evolution of Diameters")
lines(diameters$year, diameters$diameter, col = "black")

plot(avg_degrees$year, avg_degrees$avg_degree, pch=16, col="orange", xlab="year", ylab="average degrees", main="Evolution of Average Degrees")
lines(avg_degrees$year, avg_degrees$avg_degree, col = "black")


################################## TASK 3 #####################################

# Create and print data frames for the 5-year evolution of the top-10 authors with regard to Degree
top_degrees_2016 <- head(sort(degree(graph_2016, mode="all"), decreasing=TRUE), 10)
tab_df(data.table(names=names(top_degrees_2016),top_degrees_2016))

top_degrees_2017 <- head(sort(degree(graph_2017, mode="all"), decreasing=TRUE), 10)
tab_df(data.table(names=names(top_degrees_2017),top_degrees_2017))

top_degrees_2018 <- head(sort(degree(graph_2018, mode="all"), decreasing=TRUE), 10)
tab_df(data.table(names=names(top_degrees_2018),top_degrees_2018))

top_degrees_2019 <- head(sort(degree(graph_2019, mode="all"), decreasing=TRUE), 10)
tab_df(data.table(names=names(top_degrees_2019),top_degrees_2019))

top_degrees_2020 <- head(sort(degree(graph_2020, mode="all"), decreasing=TRUE), 10)
tab_df(data.table(names=names(top_degrees_2020),top_degrees_2020))

# Create and print data frames for the 5-year evolution of the top-10 authors with regard to PageRank 
rank_2016 <- page_rank(graph_2016, algo="prpack", directed=FALSE)$vector
page_rank_2016 <- head(sort(rank_2016, decreasing=TRUE),10)
tab_df(data.table(names=names(page_rank_2016),page_rank_2016), digits = 6)

rank_2017 <- page_rank(graph_2017, algo="prpack", directed=FALSE)$vector
page_rank_2017 <- head(sort(rank_2017, decreasing=TRUE),10)
tab_df(data.table(names=names(page_rank_2017),page_rank_2017), digits = 6)

rank_2018 <- page_rank(graph_2018, algo="prpack", directed=FALSE)$vector
page_rank_2018 <- head(sort(rank_2018, decreasing=TRUE),10)
tab_df(data.table(names=names(page_rank_2018),page_rank_2018), digits = 6)

rank_2019 <- page_rank(graph_2019, algo="prpack", directed=FALSE)$vector
page_rank_2019 <- head(sort(rank_2019, decreasing=TRUE),10)
tab_df(data.table(names=names(page_rank_2019),page_rank_2019), digits = 6)

rank_2020 <- page_rank(graph_2020, algo="prpack", directed=FALSE)$vector
page_rank_2020 <- head(sort(rank_2020, decreasing=TRUE),10)
tab_df(data.table(names=names(page_rank_2020),page_rank_2020), digits = 6)


################################## TASK 4 #####################################

# Perform community detection on the mention graphs
# Apply fast greedy clustering algorithm
fast_greedy_2016 <- cluster_fast_greedy(graph_2016)
fast_greedy_2017 <- cluster_fast_greedy(graph_2017)
fast_greedy_2018 <- cluster_fast_greedy(graph_2018)
fast_greedy_2019 <- cluster_fast_greedy(graph_2019)
fast_greedy_2020 <- cluster_fast_greedy(graph_2020)

# Apply infomap clustering algorithm
infomap_2016 <- cluster_infomap(graph_2016)
infomap_2017 <- cluster_infomap(graph_2017)
infomap_2018 <- cluster_infomap(graph_2018)
infomap_2019 <- cluster_infomap(graph_2019)
infomap_2020 <- cluster_infomap(graph_2020)

# Apply louvain clustering algorithm
louvain_2016 <- cluster_louvain(graph_2016)
louvain_2017 <- cluster_louvain(graph_2017)
louvain_2018 <- cluster_louvain(graph_2018)
louvain_2019 <- cluster_louvain(graph_2019)
louvain_2020 <- cluster_louvain(graph_2020)

# Calculate system time for each fast greedy clustering algorithm run
system.time(cluster_fast_greedy(graph_2016))
system.time(cluster_fast_greedy(graph_2017))
system.time(cluster_fast_greedy(graph_2018))
system.time(cluster_fast_greedy(graph_2019))
system.time(cluster_fast_greedy(graph_2020))

# Calculate system time for each infomap clustering algorithm run
system.time(cluster_infomap(graph_2016))
system.time(cluster_infomap(graph_2017))
system.time(cluster_infomap(graph_2018))
system.time(cluster_infomap(graph_2019))
system.time(cluster_infomap(graph_2020))

# Calculate system time for each louvain clustering algorithm run
system.time(cluster_louvain(graph_2016))
system.time(cluster_louvain(graph_2017))
system.time(cluster_louvain(graph_2018))
system.time(cluster_louvain(graph_2019))
system.time(cluster_louvain(graph_2020))

# Calculate modularity scores for each clustering algorithm 
mod <- data.frame(fast_greedy = c(modularity(fast_greedy_2016), modularity(fast_greedy_2017), modularity(fast_greedy_2018),
                                  modularity(fast_greedy_2019), modularity(fast_greedy_2020)),
                  infomap = c(modularity(infomap_2016), modularity(infomap_2017), modularity(infomap_2018),
                              modularity(infomap_2019), modularity(infomap_2020)),
                  louvain = c(modularity(louvain_2016), modularity(louvain_2017), modularity(louvain_2018),
                              modularity(louvain_2019), modularity(louvain_2020)))

# Print table in order to compare methods
tab_df(mod, digits = 3) # Choose louvain clustering algorithm based on performance and high modularity

# Find authors that appear every year
common_authors <- Reduce(intersect, list(louvain_2016$names, louvain_2017$names, 
                                         louvain_2018$names, louvain_2019$names,louvain_2020$names))

# Create membership data frames for each year
membership_2016 <- as.matrix(membership(louvain_2016))
m2016 <- data.frame(Author = rownames(membership_2016), ID = membership_2016, 
                    row.names = 1:length(membership_2016))
membership_2017 <- as.matrix(membership(louvain_2017))
m2017 <- data.frame(Author = rownames(membership_2017), ID = membership_2017, 
                    row.names = 1:length(membership_2017))
membership_2018 <- as.matrix(membership(louvain_2018))
m2018 <- data.frame(Author = rownames(membership_2018), ID = membership_2018, 
                    row.names = 1:length(membership_2018))
membership_2019 <- as.matrix(membership(louvain_2019))
m2019 <- data.frame(Author = rownames(membership_2019), ID = membership_2019, 
                    row.names = 1:length(membership_2019))
membership_2020 <- as.matrix(membership(louvain_2020))
m2020 <- data.frame(Author = rownames(membership_2020), ID = membership_2020, 
                    row.names = 1:length(membership_2020))

# Pick a random author from common authors ("Dawei Yin")
# Find the community to which this author belonged each year
s1<-subset(m2016, Author==common_authors[25])
s2<-subset(m2017, Author==common_authors[25])
s3<-subset(m2018, Author==common_authors[25])
s4<-subset(m2019, Author==common_authors[25])
s5<-subset(m2020, Author==common_authors[25])


# Plot the evolution of the size of the communities to which the author belonged
community_vertices <- data.frame("vertices_number"=c(length(which(louvain_2016$membership==s1$ID)), 
                                                     length(which(louvain_2017$membership==s2$ID)), 
                                                     length(which(louvain_2018$membership==s3$ID)), 
                                                     length(which(louvain_2019$membership==s4$ID)),
                                                     length(which(louvain_2020$membership==s5$ID))), 
                                "year" = c("2016","2017", "2018", "2019", "2020"))

plot(community_vertices$year, community_vertices$vertices_number, pch=16, col="violet", xlab="year", ylab="vertices", main="Evolution of Community Vertices")
lines(community_vertices$year, community_vertices$vertices_number, col = "black")

# Create subsets to find similarity of authors among communities
cs1 <- subset(m2016, ID == s1$ID) 
cs2 <- subset(m2017, ID == s2$ID) 
cs3 <- subset(m2018, ID == s3$ID) 
cs4 <- subset(m2019, ID == s4$ID) 
cs5 <- subset(m2020, ID == s5$ID) 

similarities <- Reduce(intersect, list(cs1$Author, cs2$Author, cs3$Author, cs4$Author, cs5$Author))
similarities # the common authors are “Dawei Yin” and “Jiliang Tang”  

# Plot the mid-sized communities for each year
# Color of each community
V(graph_2016)$color <- factor(membership(louvain_2016))
V(graph_2017)$color <- factor(membership(louvain_2017))
V(graph_2018)$color <- factor(membership(louvain_2018))
V(graph_2019)$color <- factor(membership(louvain_2019))
V(graph_2020)$color <- factor(membership(louvain_2020))

# Size of each community
community_s2016 <- sizes(louvain_2016)
community_s2017 <- sizes(louvain_2017)
community_s2018 <- sizes(louvain_2018)
community_s2019 <- sizes(louvain_2019)
community_s2020 <- sizes(louvain_2020)

# Filter out all nodes that belong to very small or very large communities
community_m2016 <- unlist(louvain_2016[community_s2016 > 40 & community_s2016 < 90])
community_m2017 <- unlist(louvain_2017[community_s2017 > 40 & community_s2017 < 90])
community_m2018 <- unlist(louvain_2018[community_s2018 > 40 & community_s2018 < 90])
community_m2019 <- unlist(louvain_2019[community_s2019 > 40 & community_s2019 < 90])
community_m2020 <- unlist(louvain_2020[community_s2020 > 40 & community_s2020 < 90])

# Induce a subgraph of graph
subgraph_2016 <- induced.subgraph(graph_2016, community_m2016)
subgraph_2017 <- induced.subgraph(graph_2017, community_m2017)
subgraph_2018 <- induced.subgraph(graph_2018, community_m2018)
subgraph_2019 <- induced.subgraph(graph_2019, community_m2019)
subgraph_2020 <- induced.subgraph(graph_2020, community_m2020)

# Check edge crossing between communities
crossing_2016 <- crossing(graph_2016, communities = louvain_2016)
crossing_2017 <- crossing(graph_2017, communities = louvain_2017)
crossing_2018 <- crossing(graph_2018, communities = louvain_2018)
crossing_2019 <- crossing(graph_2019, communities = louvain_2019)
crossing_2020 <- crossing(graph_2020, communities = louvain_2020)

# Set edge line type, solid for crossings, dotted otherwise 
E(graph_2016)$lty <- ifelse(crossing_2016, "solid", "dotted")
E(graph_2017)$lty <- ifelse(crossing_2017, "solid", "dotted")
E(graph_2018)$lty <- ifelse(crossing_2018, "solid", "dotted")
E(graph_2019)$lty <- ifelse(crossing_2019, "solid", "dotted")
E(graph_2020)$lty <- ifelse(crossing_2020, "solid", "dotted")

# Run louvain algorithm for subgraphs
louvain_subgraph_2016 <- cluster_louvain(subgraph_2016)
louvain_subgraph_2017 <- cluster_louvain(subgraph_2017)
louvain_subgraph_2018 <- cluster_louvain(subgraph_2018)
louvain_subgraph_2019 <- cluster_louvain(subgraph_2019)
louvain_subgraph_2020 <- cluster_louvain(subgraph_2020)

# Plots
plot(subgraph_2016, vertex.color=rainbow(16, alpha=1)[louvain_subgraph_2016$membership], vertex.label=NA, edge.arrow.size=.2, 
     vertex.size=10, margin = 0, coords = layout_with_fr(subgraph_2016), edge.arrow.width = 0.8, edge.arrow.size = 0.2, 
     lty=E(graph_2016)$lty, main="Communities of 2016")

plot(subgraph_2017, vertex.color=rainbow(16, alpha=1)[louvain_subgraph_2017$membership], vertex.label=NA, edge.arrow.size=.2, 
     vertex.size=10, margin = 0, coords = layout_with_fr(subgraph_2017), edge.arrow.width = 0.8, edge.arrow.size = 0.2, 
     lty=E(graph_2017)$lty, main="Communities of 2017")

plot(subgraph_2018, vertex.color=rainbow(16, alpha=1)[louvain_subgraph_2018$membership], vertex.label=NA, edge.arrow.size=.2, 
     vertex.size=10, margin = 0, coords = layout_with_fr(subgraph_2018), edge.arrow.width = 0.8, edge.arrow.size = 0.2, 
     lty=E(graph_2018)$lty, main="Communities of 2018") 

plot(subgraph_2019, vertex.color=rainbow(16, alpha=1)[louvain_subgraph_2019$membership], vertex.label=NA, edge.arrow.size=.2, 
     vertex.size=10, margin = 0, coords = layout_with_fr(subgraph_2019), edge.arrow.width = 0.8, edge.arrow.size = 0.2, 
     lty=E(graph_2019)$lty, main="Communities of 2019")

plot(subgraph_2020, vertex.color=rainbow(16, alpha=1)[louvain_subgraph_2020$membership], vertex.label=NA, edge.arrow.size=.2, 
     vertex.size=10, margin = 0, coords = layout_with_fr(subgraph_2020), edge.arrow.width = 0.8, edge.arrow.size = 0.2, 
     lty=E(graph_2020)$lty, main="Communities of 2020")

