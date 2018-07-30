Terragrunt

DRY (Don't repeat yourself)

#---------------------------------#
#  Keep your Terraform code DRY   #
#---------------------------------#

Suppose we have 3 environment to deploy code (prod, qa, stage).
live
    ├── prod
    │   ├── app
    │   │   └── main.tf
    │   ├── mysql
    │   │   └── main.tf
    │   └── vpc
    │       └── main.tf
    ├── qa
    │   ├── app
    │   │   └── main.tf
    │   ├── mysql
    │   │   └── main.tf
    │   └── vpc
    │       └── main.tf
    └── stage
        ├── app
        │   └── main.tf
        ├── mysql
        │   └── main.tf
        └── vpc
            └── main.tf
--> All 3 prod, qa, stage have the same infrastructure deployment 
--> Repeat your selffffff -> NOT GOOD. Have to change to this (using .tfvars config by terragrunt):

└── live
    ├── prod
    │   ├── app
    │   │   └── terraform.tfvars
    │   ├── mysql
    │   │   └── terraform.tfvars
    │   └── vpc
    │       └── terraform.tfvars
    ├── qa
    │   ├── app
    │   │   └── terraform.tfvars
    │   ├── mysql
    │   │   └── terraform.tfvars
    │   └── vpc
    │       └── terraform.tfvars
    └── stage
        ├── app
        │   └── terraform.tfvars
        ├── mysql
        │   └── terraform.tfvars
        └── vpc
            └── terraform.tfvars
			
Each terraform.tfvars would look like:
---------------
terragrunt = {
  terraform {
    source = "git::git@github.com:foo/modules.git//app?ref=v0.0.3"
  }
}

instance_count = 3					<-- could hard-code or user prompting like below code
instance_type = "t2.micro"			<-- could hard-code or user prompting like below code


---------------
variable "instance_count" {
  description = "How many servers to run"
}

variable "instance_type" {
  description = "What kind of servers to run (e.g. t2.large)"
}
---------------
Running terragrunt :D 
- cd path-to-app-folder
- terragrunt apply
Procedure when running "terragrunt apply":
a) 1st running "terragrunt apply" 
Download the code to tmp folder 
--> this will be kept for future use unless URL is change
--> minimize the up-and-running time (since re-initialize, everything takes minutes to complete)

b) 2nd running "terragrunt apply":
just running with downloaded .tf code in previous time.
In case force to update new .tf >> using --terragrunt-source-update (delete & reinitialize everything)


Bonus point:
1)	terragrunt apply --terragrunt-source [path_to_another_source_terragrunt]//[current_applied_folder]
Ex: terragrunt apply --terragrunt-source ../../modules//app
 --> override the "source" parameter >> local checkout your code & fast change

2)  path-relative is dangerous !! No hard-code
	--> Using Inside .tfvars: use get_tfvars_dir() to get CWD
	--> Using with CLI: 	  terragrunt apply -var-file [path_to_extra.tfvars]	

#--------------------------------------------#
#  Keep your remote STATE configuration DRY  #
#--------------------------------------------#

Default, remote state is stored locally : terraform.tfstate
Disadvantage:
- Working in a team, if stored locally & 2 people push simultenously >> race condition
- Could not storage in GIT (plain text) >> bad security
--> Using remote state storage (built-in function "backends"):
------------
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "frontend-app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}

