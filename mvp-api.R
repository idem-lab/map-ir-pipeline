# For a minimum viable product, here is what we need

# objects we need are:

covariate_rasters
training_data
list_of_l0_models
inla_mesh_setup

# so the covariate_raster object should contain all the covariates that they
# care about (coffee, coconut)
covariate_rasters

# they need to format the training data into the format that we require
# e.., expected column names
# lat/long/no_mosquitoes_tested/no_mosquitoes_died/
training_data


# List of L0 models
# could just be a character vector c('randomForest', 'xgboost', 'cart')
  # as well as hyperparameter settings as well?
  # but they default to penny's...or something
list_of_l0_models

# inla_mesh_setup
# this will need to match the covariate_raster shape
inla_mesh_setup

# two functions we use:
## model_validation
## spatial_prediction
model_validation(covariate_rasters,
                 training_data,
                 list_of_l0_models,
                 inla_mesh_setup)

# evaluation/diagnostics tool set
## Maybe all the model validation stuff can be in the output of these

# does the same thing but makes prediction to raster
# making maps
spatial_prediction(covariate_rasters,
                   training_data,
                   list_of_l0_models,
                   inla_mesh_setup)

# In the back end
# We can run a targets workflow
