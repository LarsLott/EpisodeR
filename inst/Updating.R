
# this script is about the yearly updating process of the package
# (vdem, codebook)

# PREP: fork the package / update your fork on your personal rep
# pull latest package version to your local RStudio/git (version control set up)
# do the following updates

# load the new vdem dataset and save it as RData in the package folder "data"
# vdem

vdem <- readRDS("C:/Users/ba72loko/projects/data/V-Dem 13 Final/V-Dem-CY-FullOthers_R_v13/V-Dem-CY-Full+Others-v13.rds")

save("vdem", file = "data/vdem.RData", compress = "xz")

# document and check new package version
devtools::document()
devtools::check()

