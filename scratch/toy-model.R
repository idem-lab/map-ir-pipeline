# Regarding how many L1 models are fit, and the specifics of tis

# L1 model will be fit seperately
# one species (gambaie)
# only phenotypic
# one insecticide type at a time

# So in Penny's example, we will end up with one L1 model per insecticide type

# Here is an example from Nick Golding showing How L0 models would be fit
# In the model, `m`
# and then the inputs that are fed into the L1 model, in the predict step,
# with one prediction per insecticide

n <- 1000
n_insecticide <- 5
all_insecticide <- letters[seq_len(n_insecticide)]
all_types <- rep(c("phenotypic", "genotypic"))
df_phenotypic <- data.frame(
  y = rnorm(n),
  insecticide = all_insecticide[sample.int(n_insecticide, n, replace = TRUE)],
  cov_1 = rnorm(n),
  cov_2 = rnorm(n)
)

df_genotypic <- data.frame(
  y = rnorm(n),
  insecticide = "none",
  cov_1 = rnorm(n),
  cov_2 = rnorm(n)
)

df <- bind_rows(
  phenotypic = df_phenotypic,
  genotypic = df_genotypic,
  .id = "type"
) %>%
  as_tibble()

# fit model for all insecticide simultaneously
m <- lm(y ~ cov_1 + cov_2 + factor(insecticide) + factor(type),
  data = df
)

# predictions to new covariates
n_pred <- 100
df_new <- data.frame(
  cov_1 = rnorm(n_pred),
  cov_2 = rnorm(n_pred)
)

# but predict for a single insecticide
this_insecticide <- all_insecticide[2]
df_new_insecticide <- cbind(df_new,
  insecticide = this_insecticide,
  type = "phenotypic"
)
pred <- predict(m, newdata = df_new_insecticide)

this_insecticide <- all_insecticide[1]
df_new_insecticide <- cbind(df_new,
  insecticide = this_insecticide,
  type = "phenotypic"
)
pred <- predict(m, newdata = df_new_insecticide)

# these "pred" outputs are then fed as the covariate inputs for the L1 model
