terraform {
    source = "../../../modules/alb"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
    instance_type = "t2.nano",
    name = "WebServerWithALB"
    vpc_id = "vpc-0a530d837c804ead0"
    number_of_instances = 2
    subnets = ["subnet-00d926f2e6119ff58", "subnet-0d5396a51e11e74eb", "subnet-069d6ebbdd9e07a8a"]
}