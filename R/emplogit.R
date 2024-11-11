# empirical logit number
emplogit <- function(Y, N) {
  top <- Y * N + 0.5
  bottom <- N * (1 - Y) + 0.5
  return(log(top / bottom))
}

# empirical logit two numbers
emplogit2 <- function(Y, N) {
  top <- Y + 0.5
  bottom <- N - Y + 0.5
  return(log(top / bottom))
}

emplogit3 <- function(Y, N) {
  top <- Y + 1.5
  bottom <- N - Y + 1.5
  return(log(top / bottom))
}

emplogit4 <- function(p) {
  top <- p + 0.015
  bottom <- 1 - p + 0.015
  return(log(top / bottom))
}

invelogit <- function(L, N) {
  top <- exp(L) * (N + 0.5) - 0.5
  bottom <- N * (1 + exp(L))
  return(top / bottom)
}

inv_emplogit2 <- function(emp_logit, N) {
  L <- exp(emp_logit)
  top <- (L * N + 0.5 * L - 0.5)
  bottom <- (1 + L)

  top / bottom
}

# vec <- runif(10)
# vec
# emplogit2(vec, 10)
# res <- emplogit2(vec, 10) |> inv_emplogit2(10)
# dplyr::near(vec, res)

# IHS transformation
IHS <- function(x, theta) {
  (1 / theta) * asinh(theta * x)
}

# Inverse IHS transformation
Inv.IHS <- function(x, theta) {
  (1 / theta) * sinh(theta * x)
}

IHS.loglik <- function(theta, x) {
  n <- length(x)
  xt <- IHS(x, theta)
  log.lik <-
    -n * log(sum((xt - mean(xt))^2)) - sum(log(1 + theta^2 * x^2))
  return(log.lik)
}
