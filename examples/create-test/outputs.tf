output "node_pool_details" {
  description = "노드 풀의 주요 세부 정보입니다."
  value = {
    id                  = module.node_pool.id
    name                = module.node_pool.name
    version             = module.node_pool.version
    location            = module.node_pool.location
    instance_group_urls = module.node_pool.instance_group_urls
    node_config = {
      machine_type = try(module.node_pool.node_config[0].machine_type, null)
      disk_size_gb = try(module.node_pool.node_config[0].disk_size_gb, null)
    }
    autoscaling = {
      min_node_count = try(module.node_pool.autoscaling[0].min_node_count, null)
      max_node_count = try(module.node_pool.autoscaling[0].max_node_count, null)
    }
    management = {
      auto_repair  = try(module.node_pool.management[0].auto_repair, null)
      auto_upgrade = try(module.node_pool.management[0].auto_upgrade, null)
    }
  }
}