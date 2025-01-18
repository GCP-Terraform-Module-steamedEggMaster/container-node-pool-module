output "id" {
  description = "생성된 노드 풀의 ID입니다."
  value       = google_container_node_pool.node_pool.id
}

output "name" {
  description = "노드 풀의 이름입니다."
  value       = google_container_node_pool.node_pool.name
}

output "location" {
  description = "노드 풀이 배치된 위치입니다."
  value       = google_container_node_pool.node_pool.location
}

output "instance_group_urls" {
  description = "노드 풀에 연결된 관리 인스턴스 그룹의 URL 목록입니다."
  value       = google_container_node_pool.node_pool.instance_group_urls
}

output "node_config" {
  description = "노드 풀 구성 매개변수입니다."
  value = {
    machine_type = try(google_container_node_pool.node_pool.node_config[0].machine_type, null)
    disk_size_gb = try(google_container_node_pool.node_pool.node_config[0].disk_size_gb, null)
  }
}

output "autoscaling" {
  description = "노드 풀의 자동 확장 설정입니다."
  value = {
    min_node_count = try(google_container_node_pool.node_pool.autoscaling[0].min_node_count, null)
    max_node_count = try(google_container_node_pool.node_pool.autoscaling[0].max_node_count, null)
  }
}

output "management" {
  description = "노드 풀 관리 설정입니다."
  value = {
    auto_repair  = google_container_node_pool.node_pool.management.auto_repair
    auto_upgrade = google_container_node_pool.node_pool.management.auto_upgrade
  }
}