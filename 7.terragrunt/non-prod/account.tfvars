# Root level variables that all modules can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.

tfstate_global_bucket        = "terragrunt-state-bucket"
tfstate_global_bucket_region = "us-west-2"
aws_profile                  = "terragrunt-profile"
