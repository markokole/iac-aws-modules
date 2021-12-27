variable policy_name {
    type    = string
    default = ""
}

variable policy_description {
    type    = string
    default = ""
}

variable policy_action {
    type    = list(string)
    default = []
}

variable policy_resource {
    type    = list(string)
    default = ""
}

variable user {
    type    = string
    default = ""
}

variable role_name {
    type    = string
    default = ""
}

variable principal_service {
    type    = string
    default = ""
}