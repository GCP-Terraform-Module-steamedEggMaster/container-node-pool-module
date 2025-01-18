output "node_pool_details" {
  description = "노드 풀의 주요 세부 정보입니다."
  value = {
    id                   = google_container_node_pool.node_pool.id
    name                 = google_container_node_pool.node_pool.name
    version              = google_container_node_pool.node_pool.version
    location             = google_container_node_pool.node_pool.location
    instance_group_urls  = google_container_node_pool.node_pool.instance_group_urls
    node_config = {
      machine_type = try(google_container_node_pool.node_pool.node_config[0].machine_type, null)
      disk_size_gb = try(google_container_node_pool.node_pool.node_config[0].disk_size_gb, null)
    }
    autoscaling = {
      min_node_count = try(google_container_node_pool.node_pool.autoscaling[0].min_node_count, null)
      max_node_count = try(google_container_node_pool.node_pool.autoscaling[0].max_node_count, null)
    }
    management = {
      auto_repair  = google_container_node_pool.node_pool.management.auto_repair
      auto_upgrade = google_container_node_pool.node_pool.management.auto_upgrade
    }
  }
}