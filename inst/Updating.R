## copied and adapted from ERT package ##

# this script is about the yearly updating process of the package
# (vdem, codebook)

# PREP: fork the package / update your fork on your personal rep
# pull latest package version to your local RStudio/git (version control set up)
# do the following updates

# load the new vdem dataset and save it as RData in the package folder "data"
# vdem

vdem <- readRDS("P:/PIPM/7. VWS Projekt Academic Freedom Index/Annual Updates/Annual Update 2025 files/V-Dem-CY-Full+Others-v15.rds")

save("vdem", file = "data/vdem.RData", compress = "xz")

# document and check new package version
devtools::document()
devtools::check()

