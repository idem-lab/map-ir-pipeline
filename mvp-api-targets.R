# model_validation <- function(covariate_rasters,
#                              training_data,
#                              list_of_l0_models,
#                              inla_mesh_setup){
#   create_data_paths(covariate_rasters,
#                     training_data,
#                     list_of_l0_models,
#                     inla_mesh_setup)
#   tar_make(
#       # the final objects that we care about
#       oos_diagnostics
#   )
#
#   tar_load(
#       oos_diagnostics
#   )
# }
#
# spatial_prediction <- function(covariate_rasters,
#                              training_data,
#                              list_of_l0_models,
#                              inla_mesh_setup){
#   create_data_paths(covariate_rasters,
#                     training_data,
#                     list_of_l0_models,
#                     inla_mesh_setup)
#   tar_make(
#     predicted_raster
#   )
#
#   tar_load(
#     predicted_raster
#   )
# }
#
#
# run_targets <- function(specific_arg){
#   # this is basically containing _targets.R
#   tar_script(
#     code = {
#     heaps_of_targets,
#     heaps_of_targets,
#     heaps_of_targets,
#     tar_target(
#       specific_target = specific_arg
#     ),
#     heaps_of_targets,
#     heaps_of_targets,
#     heaps_of_targets,
#     },
#     script = "user_asked_directory"
#   ),
#
# }
#
# # handle writing these as RDS objects to the right spot
# # so the user does this step
# create_data_paths(
#   covariates = covariate_object,
#   training_data = training_data
# )
#
# ## tar_plan supports drake-style targets and also tar_target()
# tar_plan(
#   # read in example infection resistance data
#   tar_target(
#     file_rds_set,
#     read_rds("dir/to/rds_paths_specified_by_user.rds")
#   ),
#   tar_target(
#     training_data,
#     file_rds_set(file_rds_set, "training_data"),
#   ),
#   tar_target(
#     training_data,
#     file_rds_set(file_rds_set, "training_data"),
#   ),
# )
# )
