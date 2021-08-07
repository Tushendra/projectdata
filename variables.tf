variable "client_id" {
    description =   "Client ID (APP ID) of the application"
    type        =   string
    default     =   "43be2109-9ee5-4a3d-a5fc-b6a1cf77e718"
}

variable "client_secret" {
    description =   "Client Secret (Password) of the application"
    type        =   string
    default     =   "SgH-_t5pwvg-I~.9iDAtX-Vff4frDB9i7~"
}

variable "subscription_id" {
    description =   "Subscription ID"
    type        =   string
    default     =   "dbeba7de-f7df-4c87-9569-7818fad4a018"
}

variable "tenant_id" {
    description =   "Tenant ID"
    type        =   string
    default     =   "d6afcc62-d5b0-4d28-bf06-2f84d732c565"
}

# Prefix and Tags

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "part1"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "West US"
}

variable "node_count" {
type = number
default = 2
}

variable "admin_username" {
 type = string
 default = "tush1"
}

variable "admin_password" {
  type = string
  default = "MishraTush@2021"
}

