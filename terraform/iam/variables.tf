variable policy_name {
    type = string
}

variable policy_description {
    type    = string
    default = ""
}

variable policy_action {
    type = list(string)
}

variable policy_resource {
    type = list(string)
}

variable user {
    type = string
}

variable role_name {
    type = string
}

variable principal_service {
    type = string
}