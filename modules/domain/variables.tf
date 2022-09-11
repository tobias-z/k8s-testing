variable "domain" {
  type = string
}

variable "email" {
  type = string
}

variable "ttl_sec" {
  type = number
}

variable "target_ip" {
  type = string
}

variable "subdomains" {
  type = set(string)
  default = []
}