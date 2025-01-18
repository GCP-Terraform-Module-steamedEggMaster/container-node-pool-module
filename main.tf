resource "google_container_node_pool" "node_pool" {
  # 필수 인자
  cluster = var.cluster # 클러스터 이름을 지정합니다. 클러스터는 반드시 지정된 위치에 존재해야 합니다.

  # 선택적 인자
  name               = var.name               # 노드 풀의 이름을 지정합니다. 지정하지 않을 경우 Terraform이 자동으로 이름을 생성합니다.
  name_prefix        = var.name_prefix        # 노드 풀 이름의 접두사를 설정합니다. name과 함께 사용할 수 없습니다.
  location           = var.location           # 클러스터의 지역(region) 또는 영역(zone)을 설정합니다.
  project            = var.project            # 노드 풀을 생성할 프로젝트 ID를 지정합니다.
  version            = var.version            # 노드 풀에서 사용할 Kubernetes 버전을 지정합니다.
  initial_node_count = var.initial_node_count # 초기 노드 수를 설정합니다. 이 값은 영역별 노드 수를 나타냅니다.
  node_count         = var.node_count         # 노드 풀의 노드 수를 지정합니다. 자동 확장과 함께 사용하지 않는 것이 좋습니다.

  dynamic "management" {
    for_each = var.management != null ? [var.management] : []
    content {
      auto_repair  = management.value.auto_repair  # 노드 자동 수리 여부를 설정합니다.
      auto_upgrade = management.value.auto_upgrade # 노드 자동 업그레이드 여부를 설정합니다.
    }
  }

  max_pods_per_node = var.max_pods_per_node # 노드 하나당 배포 가능한 최대 Pod 수를 지정합니다.
  node_locations    = var.node_locations    # 노드 풀의 노드가 배치될 영역(zone) 목록을 설정합니다.

  dynamic "node_config" {
    for_each = var.node_config != null ? [var.node_config] : []
    content {
      machine_type     = node_config.value.machine_type      # 노드에서 사용할 머신 타입 (예: e2-medium, n1-standard-1)
      disk_size_gb     = node_config.value.disk_size_gb      # 노드의 부트 디스크 크기 (GB 단위, 기본값은 100GB)
      disk_type        = node_config.value.disk_type         # 디스크 유형 (예: pd-standard, pd-ssd)
      image_type       = node_config.value.image_type        # 노드에서 사용할 이미지 유형 (예: COS, COS_CONTAINERD 등)
      labels           = node_config.value.labels            # 노드에 추가할 key-value 형태의 사용자 정의 라벨
      local_ssd_count  = node_config.value.local_ssd_count   # 노드당 로컬 SSD의 수량
      metadata         = node_config.value.metadata          # 노드에 추가할 메타데이터 (key-value 형태)
      min_cpu_platform = node_config.value.min_cpu_platform  # 노드의 최소 CPU 플랫폼 (예: Intel Skylake)
      oauth_scopes     = node_config.value.oauth_scopes      # 노드에서 사용할 OAuth 스코프 목록
      preemptible      = node_config.value.preemptible       # 프리엠티블(preemptible) 노드 설정 여부 (true/false)
      service_account  = node_config.value.service_account   # 노드가 사용할 서비스 계정 (GCP IAM)
      tags             = node_config.value.tags              # 노드 네트워크에서 사용할 태그 (예: 방화벽 규칙 적용용)
      accelerators     = node_config.value.accelerators      # 노드에 추가할 하드웨어 가속기 설정 (예: GPU)
      taint            = node_config.value.taint             # 노드에 적용할 Taint 설정 (스케줄링 제한에 사용)
    }
  }

  dynamic "network_config" {
    for_each = var.network_config != null ? [var.network_config] : []
    content {
      create_pod_range     = network_config.value.create_pod_range     # Pod IP를 위한 새로운 범위를 생성할지 여부를 설정합니다.
      enable_private_nodes = network_config.value.enable_private_nodes # 노드가 내부 IP만 사용하도록 설정합니다.
      pod_ipv4_cidr_block  = network_config.value.pod_ipv4_cidr_block  # Pod IP 범위를 CIDR 형식으로 지정합니다.
      pod_range            = network_config.value.pod_range            # Pod IP에 사용할 기존 보조 범위를 지정합니다.
    }
  }

  dynamic "upgrade_settings" {
    for_each = var.upgrade_settings != null ? [var.upgrade_settings] : []
    content {
      max_surge       = upgrade_settings.value.max_surge       # 업그레이드 중 동시에 추가될 수 있는 노드 수를 설정합니다.
      max_unavailable = upgrade_settings.value.max_unavailable # 업그레이드 중 동시에 사용할 수 없는 노드 수를 설정합니다.
      strategy        = upgrade_settings.value.strategy        # 노드 업그레이드 전략을 설정합니다. 기본값은 SURGE입니다.
    }
  }

  dynamic "placement_policy" {
    for_each = var.placement_policy != null ? [var.placement_policy] : []
    content {
      type        = placement_policy.value.type        # 배치 정책 유형을 설정합니다. COMPACT는 노드 간 네트워크 지연 시간을 줄이는 데 사용됩니다.
      policy_name = placement_policy.value.policy_name # 사용자 지정 리소스 정책 이름을 지정합니다.
    }
  }

  dynamic "autoscaling" {
    for_each = var.autoscaling != null ? [var.autoscaling] : []
    content {
      min_node_count       = autoscaling.value.min_node_count       # 영역당 최소 노드 수를 설정합니다.
      max_node_count       = autoscaling.value.max_node_count       # 영역당 최대 노드 수를 설정합니다.
      total_min_node_count = autoscaling.value.total_min_node_count # 노드 풀의 총 최소 노드 수를 설정합니다.
      total_max_node_count = autoscaling.value.total_max_node_count # 노드 풀의 총 최대 노드 수를 설정합니다.
    }
  }

  dynamic "reservation_affinity" {
    for_each = var.reservation_affinity != null ? [var.reservation_affinity] : []
    content {
      consume_reservation_type = reservation_affinity.value.consume_reservation_type # 예약 소비 유형을 설정합니다. 예: ANY_RESERVATION
      key                      = reservation_affinity.value.key                      # 특정 예약 리소스를 지정하는 키를 설정합니다.
      values                   = reservation_affinity.value.values                   # 예약 리소스의 값을 설정합니다.
    }
  }

  timeouts {
    create = var.create # 클러스터 생성 시 최대 대기 시간
    update = var.update # 클러스터 업데이트 시 최대 대기 시간
    delete = var.delete # 클러스터 삭제 시 최대 대기 시간
  }
}
