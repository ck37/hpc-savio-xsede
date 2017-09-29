# Run manually if needed.
# spark_version = "2.2.0"
# 2.1.0 is available as a module on Savio (SL7), which can make things easier.
spark_version = "2.1.0"

if (F) {

  # 1. Install sparklyr by RStudio - R interface to Apache Spark.
  # https://spark.rstudio.com/
  install.packages("sparklyr")

  # 2. Review available Spark versions.
  sparklyr::spark_available_versions()

  # 3. Install a certain version of spark (if not already installed).
  # (Not needed on Savio, but can be used on local computer.)
  sparklyr::spark_install(version = spark_version)

  # Install a recent version of h2o.
  # This release of h2o is compatible with both spark 2.2.0 and 2.1.0.
  #install.packages("h2o", type = "source",
  #      repos = "https://h2o-release.s3.amazonaws.com/h2o/rel-weierstrass/2/R")

  # 4. Install rsparklying by h2o.ai (provides "Sparkling Water" system).
  # NOTE: this will also install h2o automatically.
  # devtools::install_github("h2oai/rsparkling", ref = "master")
  # Or stable CRAN version (will install h2o automatically if not yet installed):
  install.packages("rsparkling")
}

library(sparklyr)

if (Sys.getenv("SPARK_URL") != "") {
  # Savio slurm version:
  # NOTE: can probably ignore warning about downgrading to h2o 3.14.0.2
  sc <- spark_connect(master = Sys.getenv("SPARK_URL"))
  print(connection_is_open(sc))
} else {
  # Local computer version, need to specify version.
  sc <- spark_connect(master = "local", version = spark_version)
}

print(sc)

library(dplyr)

# Via https://spark.rstudio.com/#using-h2o
# Doesn't seem to work on savio sl7 :/
mtcars_tbl <- copy_to(sc, mtcars, "mtcars")

library(rsparkling)
library(h2o)

mtcars_h2o <- as_h2o_frame(sc, mtcars_tbl, strict_version_check = FALSE)

outcome_name = "mpg"
x_names = setdiff(colnames(mtcars), outcome_name)
x_names

mtcars_glm <- h2o.glm(x = x_names,
                      y = outcome_name,
                      nfolds = 4,
                      training_frame = mtcars_h2o,
                      lambda_search = TRUE)

mtcars_glm

spark_disconnect(sc)
