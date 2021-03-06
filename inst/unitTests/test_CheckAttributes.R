test_CheckAttributes <- function() {
    # test that CheckAttributes produces an error if not all vertex attributes present on graph
    g <- erdos.renyi.game(10, 0.5)
    g <- set.vertex.attribute(g, name="attr1", value=runif(vcount(g)))
    checkException(res <- SANTA:::CheckAttributes(g, vertex.attr=c("attr1", "attr2")), silent=TRUE)
    g <- remove.vertex.attribute(g, "attr1")
    
    # test that CheckAttributes successfully converts non-numeric vertex weights
    values <- runif(vcount(g))
    values[1] <- "1"
    g <- set.vertex.attribute(g, name="vertex.attr", value=values)
    suppressWarnings(suppressMessages(g <- SANTA:::CheckAttributes(g, vertex.attr="vertex.attr")))
    checkEquals(get.vertex.attribute(g, name="vertex.attr")[1], 1)
    g <- remove.vertex.attribute(g, "vertex.attr")
    
    # test that Check Attributes successfully converts logical vertex weights
    values <- c(TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE)
    g <- set.vertex.attribute(g, name="vertex.attr", value=values)
    suppressWarnings(suppressMessages(g <- SANTA:::CheckAttributes(g, vertex.attr="vertex.attr")))
    checkEquals(get.vertex.attribute(g, name="vertex.attr"), c(1, 1, 1, 1, 0, 0, 0, 0, 1, 1))
    g <- remove.vertex.attribute(g, "vertex.attr")
    
    # test that Check Attributes successfully converts non-numeric "NA"-containing vertex weights
    values <- c("1", "NA", "3", "4", "5", "6", "7", "8", "9", "NA")
    g <- set.vertex.attribute(g, name="vertex.attr", value=values)
    suppressWarnings(suppressMessages(g <- SANTA:::CheckAttributes(g, vertex.attr="vertex.attr")))
    checkEquals(get.vertex.attribute(g, name="vertex.attr"), c(1, NA, 3, 4, 5, 6, 7, 8, 9, NA))
    g <- remove.vertex.attribute(g, "vertex.attr")
    
    # test that CheckAttributes produces an error if it is unable to convert non-numeric vertex weights
    values <- runif(vcount(g))
    values[1] <- "a"
    g <- set.vertex.attribute(g, name="vertex.attr", value=values)
    checkException(SANTA:::CheckAttributes(g, vertex.attr="vertex.attr"), silent=TRUE)
    g <- remove.vertex.attribute(g, "vertex.attr")
    
    # test that CheckAttributes produces an error if not all vertex weights are greater or equal to 0
    values <- runif(vcount(g))
    values[1] <- -1
    g <- set.vertex.attribute(g, name="vertex.attr", value=values)
    checkException(res <- SANTA:::CheckAttributes(g, vertex.attr="vertex.attr"), silent=TRUE)
    g <- remove.vertex.attribute(g, "vertex.attr")
    
    # test that CheckAttributes successfully handles NA-containing vertex weights
    values <- c(1, NA, 3, 4, 5, 6, 7, 8, 9, NA)
    g <- set.vertex.attribute(g, name="vertex.attr", value=values)
    suppressWarnings(suppressMessages(g <- SANTA:::CheckAttributes(g, vertex.attr="vertex.attr")))
    checkEquals(get.vertex.attribute(g, name="vertex.attr"), c(1, NA, 3, 4, 5, 6, 7, 8, 9, NA))
    g <- remove.vertex.attribute(g, "vertex.attr")
    
    # test that CheckAttributes sets missing edge distances to 1
    values <- runif(vcount(g))
    g <- set.vertex.attribute(g, name="vertex.attr", value=values)
    suppressMessages(g <- SANTA:::CheckAttributes(g, vertex.attr="vertex.attr", edge.attr="edge.attr"))
    checkEquals(get.edge.attribute(g, "edge.attr"), rep(1, ecount(g)))
    g <- remove.edge.attribute(g, "edge.attr")
    
    # test that CheckAttributes successfully converts non-numeric edge weights
    values <- runif(ecount(g))
    values[1] <- "1"
    g <- set.edge.attribute(g, name="edge.attr", value=values)
    suppressWarnings(suppressMessages(g <- SANTA:::CheckAttributes(g, vertex.attr="vertex.attr", edge.attr="edge.attr")))
    checkEquals(is.numeric(get.edge.attribute(g, name="edge.attr")[1]), TRUE)
    g <- remove.edge.attribute(g, "edge.attr")
    
    # test that CheckAttributes produces an error if it is unable to convert non-numeric edge weights
    values <- runif(ecount(g))
    values[1] <- "a"
    g <- set.edge.attribute(g, name="edge.attr", value=values)
    suppressWarnings(checkException(res <- SANTA:::CheckAttributes(g, vertex.attr="vertex.attr", edge.attr="edge.attr"), silent=TRUE))
    g <- remove.edge.attribute(g, "edge.attr")
    
    # test that CheckAttributes produces an error if not all edge distances are greater or equal to 0
    values <- runif(ecount(g))
    values[1] <- -1
    g <- set.edge.attribute(g, name="edge.attr", value=values)
    suppressWarnings(checkException(res <- SANTA:::CheckAttributes(g, vertex.attr="vertex.attr", edge.attr="edge.attr"), silent=TRUE))
    g <- remove.edge.attribute(g, "edge.attr")
    
    # test that CheckAttributes ensures all edge.attributes range between 0 and 1 (min != 0 but max == 1)
    values <- runif(ecount(g))
    g <- set.edge.attribute(g, name="edge.attr", value=values)
    g <- SANTA:::CheckAttributes(g, vertex.attr="vertex.attr", edge.attr="edge.attr")
    checkTrue(min(get.edge.attribute(g, "edge.attr")) >= 0)
    checkTrue(max(get.edge.attribute(g, "edge.attr")) == 1)
}
