# this function copied from Penny Hancock's code:
# https://doi.org/10.5281/zenodo.3751786 (ll.to.xyz.r) and has been edited lightly
# to style/consistency with the rest of the repo
ll_to_xyz <- function(ll) {
  if (is.null(colnames(ll))) {
    colnames(ll) <- c("longitude", "latitude")
  }
  if (colnames(ll)[1] == "x" & colnames(ll)[2] == "y"){
    colnames(ll) <- c("longitude", "latitude")
  }
  if (colnames(ll)[1] == "lon" & colnames(ll)[2] == "lat"){
    colnames(ll) <- c("longitude", "latitude")
  }
  ll$longitude <- ll$longitude * (pi / 180)
  ll$latitude <- ll$latitude * (pi / 180)
  x <- cos(ll$latitude) * cos(ll$longitude)
  y <- cos(ll$latitude) * sin(ll$longitude)
  z <- sin(ll$latitude)
  cbind(x = x, y = y, z = z)
}
