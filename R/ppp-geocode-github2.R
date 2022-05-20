library(tidyverse)
library(tidygeocoder)
library(parallel)
library(data.table)
library(tictoc)

low_accuracy2 <- read_csv("./addresses_to_geocode.csv")
output2 <- read_csv("./geocodio_ppp_fixed_addresses2.csv")
#output2 <- tibble()

#which(low_accuracy2$address=="6318 Hamilton Way, Eastampton Township, NJ, 08060-1679")
chunk <- 100
n <- nrow(low_accuracy2)
r  <- rep(1:ceiling(n/chunk),each=chunk)[1:n]
addresses4 <- split(low_accuracy2,r)

arc_code <- function (y){
  result <- geocode(y,
                    #(as.data.frame(y)%>%
                    #magrittr::set_colnames("address")),
                    address = address,
                    method = "arcgis",
                    full_results = TRUE)
}

#break down and save every 500
#addresses4 <- addresses4[301:length(addresses4)] #remove 300 sets of 100 already done

for (i in 6:7){ #Skipped 782-783 because 783 is short, only 72 addresses NEED TO DO LATER!
  #i <- 783
  tic()
  start <- i * 10 - 9
  end <- i * 10
  print (paste0 ("Iteration:", i, "; start=", start, "; end=", end))

  addresses5 <- addresses4[start:end]
  #addresses5 <- addresses4[201:200]

  system.time(
    addresses6 <- mclapply (addresses5, arc_code)
  )
  addresses7 <- rbindlist(addresses6, fill = TRUE, idcol = F)

  output2 <- bind_rows (output2, addresses7)
  write_csv (output2, "./geocodio_ppp_fixed_addresses2.csv")
  toc()
  print (paste ("Finished", i, "of 783 sets of 1000 addresses.", Sys.time()))
}
