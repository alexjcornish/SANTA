Knet <- function(
    g, 
    nperm=100, 
    dist.method=c("shortest.paths", "diffusion", "mfpt"), 
    vertex.attr="pheno",
    edge.attr=NULL,
    correct.factor=1,
    nsteps=1000, 
    prob=c(0, 0.05, 0.5, 0.95, 1),
    B=NULL,
    verbose=TRUE
){
    # calculate the Knet function for a graph, along with permutations if required
    
    # check that vertex weights and edge distances are present and suitable. Convert if neccessary
    dist.method <- match.arg(dist.method)
    g <- CheckAttributes(g, vertex.attr, edge.attr, verbose)
    
    # the results are saved in a list with an entry for each vertex.attr. Done even if only 1 vertex.attr supplied
    tmp <- vector("list", 6)
    names(tmp) <- c("K.obs", "AUK.obs", "K.perm", "AUK.perm", "K.quan", "pval")
    class(tmp) <- "Knet"
    res <- rep(list(tmp), length(vertex.attr)) 
    names(res) <- vertex.attr
    nvertices <- as.integer(vcount(g))
    
    if (is.null(B)) {
        # compute B and D
        D <- DistGraph(g, edge.attr=edge.attr, dist.method=dist.method, correct.inf=TRUE, correct.factor=correct.factor, verbose=verbose) 
        B <- BinGraph(D, nsteps=nsteps, verbose=verbose) 
        rm(D)
    } else {
        # check that B is of the correct dimensions
        if (!identical(dim(B), rep(nvertices, 2))) stop("B is not of the correct dimensions")
    }
    
    # convert B to a vector and compute the maximum of B
    Bv <- as.integer(as.vector(B))
    maxB <- as.integer(max(B))
    rm(B)
    
    # run the function for each vertex attribute in vertex.attr
    for (attr in vertex.attr) {
        attr.message <- if (length(vertex.attr) == 1) NULL else paste("(", which(vertex.attr == attr), "/", length(vertex.attr), ") ", sep="")
        if (verbose) message("computing the clustering of the '", attr, "' weights ", attr.message, "using ", nperm, " permutations... ", appendLF=FALSE)
        
        # extract vertex weights 
        vertex.weights <- get.vertex.attribute(g, attr)
        vertex.weights.is.na <- is.na(vertex.weights) # don't permute the NA values
        vertex.weights[vertex.weights.is.na] <- 0
        vertex.weights <- as.double(vertex.weights)
                
        # calculate the observed netK and netAUK
        res[[attr]]$K.obs <- .Call("computenetK_fewzeros", Bv, vertex.weights, nvertices, maxB)
        res[[attr]]$AUK.obs <- sum(res[[attr]]$K.obs) / length(res[[attr]]$K.obs)
       
        # if specified, run the Knet function on permutations of the graph
        if (!is.null(nperm) & nperm > 0) {
 	        # run permutations
            res[[attr]]$K.perm <- list()
            for (i in seq_len(nperm)) {
                vertex.weights.shuffled <- Shuffle(vertex.weights, ignore=vertex.weights.is.na)
                res[[attr]]$K.perm[[i]] <- .Call("computenetK_fewzeros", Bv, vertex.weights.shuffled, nvertices, maxB)
            }
            res[[attr]]$K.perm <- do.call("cbind", res[[attr]]$K.perm)
            
            # calculate the quantiles, AUK and p-values (through the z-score) for the permutations
            res[[attr]]$K.quan <- apply(res[[attr]]$K.perm, 1, function(x) quantile(x, prob=prob))
            res[[attr]]$AUK.perm <- apply(res[[attr]]$K.perm, 2, function(x) sum(x) / length(x))
            res[[attr]]$pval <- pnorm((res[[attr]]$AUK.obs - mean(res[[attr]]$AUK.perm)) / sd(res[[attr]]$AUK.perm), lower.tail=FALSE) 
        } else {
            # if no permutations are run, permutation-related statistics are returns equal to NA
            res[[attr]][c("K.perm", "AUK.perm", "K.quan", "pval")] <- NA
        }
         
        if (verbose) message(" done")
    }
    
    # cleanup and output
    if (length(vertex.attr) == 1) res <- res[[1]] # if only one vertex attribute is input, don't return a list of lists of results
    res
}
