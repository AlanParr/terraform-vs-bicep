variable "appname" {
    type = string
    description = "Name of the application"
}

variable "environment"{
    type = string
    description = "Name of the environment (int,qa,uat,prod)"
}

variable "primaryregion"{
    type = string
    default = "ukwest"
    description = "Region in which to deploy resources."
}