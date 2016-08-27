variable "region" {
        default = "ap-southeast-2" 
}

variable "profile" {
          default = "default"
}

variable "key_name" {
          default = "terraform_key"
}

variable "public_key_path" {
          default = "/home/nair/.ssh/aws/nair_aws_rsa.pub"          
}
