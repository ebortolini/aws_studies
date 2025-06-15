terraform {
    source = "../../../modules/webserver"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
    instance_type = "t2.nano",
    name = "Web Server"
    vpc_id = "vpc-0a530d837c804ead0"
}