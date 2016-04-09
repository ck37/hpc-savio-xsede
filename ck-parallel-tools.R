# Setup parallel processing, either multinode or multicore.
# By default it uses a multinode cluster if available, otherwise sets up multicore via doMC.
# Libraries required: parallel, doParallel, doMC, RhpcBLASctl, foreach
setup_parallelism = function(conf = NULL, type="either", allow_multinode = T, outfile = "") {
  # Indicator for multi-node parallelism.
  multinode = F
  
  # Check if we are on SLURM with multiple machine access.
  if (allow_multinode) {
    machines = strsplit(Sys.getenv("SLURM_NODELIST"), ",")[[1]]
    if (length(machines) > 1) {
      cat("Have multi-node access for parallelism with", length(machines), "machines:", machines, "\n")
      # NOTE: this may be a bad config if the nodes have different core counts.
      cores = rep(machines, each = as.numeric(Sys.getenv("SLURM_CPUS_ON_NODE")) )
      multinode = T
    }
  }

  if (!multinode) { 
    # Count of physical cores, unlike parallel:detectCores() which is logical cores (threads).
    cores = RhpcBLASctl::get_num_cores()
    cat("Local physical cores detected:", cores, "\n")
  
    if (exists("conf") && !is.null(conf) && "num_cores" %in% names(conf)) {
      cores = conf$num_cores
      cat("Using", cores, " local cores due to conf settings.\n")
    }
  }
  
  if (multinode || type %in% c("cluster", "doParallel")) {
    # Outfile = "" allows output from within foreach to be displayed while in RStudio.
    # TODO: figure out how to suppress the output from makeCluster()
    capture.output({ cl = parallel::makeCluster(cores, outfile = outfile) })
    registerDoParallel(cl)
    setDefaultCluster(cl)
  } else {
    # doMC only supports multicore parallelism, not multi-node.
    registerDoMC(cores)
    cl = NA
  }
  cat("Workers enabled:", getDoParWorkers(), "\n")
  return(cl)
}

# Stop the cluster if parallel:makeCluster() was used, but nothing needed if doMC was used.
stop_cluster = function(cluster_obj) {
  # Check if this cluster was created using parallel:makeCluster
  if (inherits(cluster_obj, "cluster")) {
    stop_cluster(cluster_obj)
  } else {
    cat("No cluster shutdown required.\n")
  }
}
