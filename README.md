# terraform_eks
Create EKS cluster with terraform
-- PROJECT-DIRECTORY/
   -- modules/
      -- <service1-name>/
         -- main.tf
         -- variables.tf
         -- outputs.tf
         -- provider.tf
         -- README
      -- <service2-name>/
         -- main.tf
         -- variables.tf
         -- outputs.tf
         -- provider.tf
         -- README
      -- ...other…

   -- environments/
      -- dev/
         -- backend.tf
         -- main.tf
         -- outputs.tf
         -- variables.tf
         -- terraform.tfvars

      -- qa/
         -- backend.tf
         -- main.tf
         -- outputs.tf
         -- variables.tf
         -- terraform.tfvars

      -- stage/
         -- backend.tf
         -- main.tf
         -- outputs.tf
         -- variables.tf
         -- terraform.tfvars

      -- prod/
         -- backend.tf
         -- main.tf
         -- outputs.tf
         -- variables.tf
         -- terraform.tfvars
