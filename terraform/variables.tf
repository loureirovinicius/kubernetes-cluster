variable "aws_keys" {
  type = object({
    access_key = string,
    secret_key = string
  })
}

variable "region" {
  type    = string
  default = "us-east-1"
}