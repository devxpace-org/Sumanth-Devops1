variable "region" {
  default = "us-east-1"
}

variable "zone" {
  default = "us-east-1a"
}


variable "ami" {
  type = map(any)
  default = {
    us-east-1 = "ami-03a6eaae9938c858c"
    us-east-2 = "ami-0d406e26e5ad4de53"
  }
}
