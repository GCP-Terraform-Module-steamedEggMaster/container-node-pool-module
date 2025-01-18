variable "cluster" {
  description = "클러스터 이름을 지정합니다. 클러스터는 반드시 지정된 위치에 존재해야 합니다."
  type        = string
}

variable "name" {
  description = "노드 풀의 이름을 지정합니다. 지정하지 않을 경우 Terraform이 자동으로 이름을 생성합니다."
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "노드 풀 이름의 접두사를 설정합니다. name과 함께 사용할 수 없습니다."
  type        = string
  default     = null
}

variable "location" {
  description = "클러스터의 지역(region) 또는 영역(zone)을 설정합니다."
  type        = string
  default     = null
}

variable "project" {
  description = "노드 풀을 생성할 프로젝트 ID를 지정합니다."
  type        = string
  default     = null
}

variable "version" {
  description = "노드 풀에서 사용할 Kubernetes 버전을 지정합니다."
  type        = string
  default     = null
}

variable "initial_node_count" {
  description = "초기 노드 수를 설정합니다. 이 값은 영역별 노드 수를 나타냅니다."
  type        = number
  default     = null
}

variable "node_count" {
  description = "노드 풀의 노드 수를 지정합니다. 자동 확장과 함께 사용하지 않는 것이 좋습니다."
  type        = number
  default     = null
}

variable "management" {
  description = "노드 관리 설정입니다. auto_repair 및 auto_upgrade 값을 포함합니다."
  type = object({
    auto_repair  = bool # 노드 자동 수리 여부, 기본값은 true
    auto_upgrade = bool # 노드 자동 업그레이드 여부, 기본값은 true
  })
  default = {
    auto_repair  = true
    auto_upgrade = true
  }
}

variable "max_pods_per_node" {
  description = "노드 하나당 배포 가능한 최대 Pod 수를 지정합니다."
  type        = number
  default     = null
}

variable "node_locations" {
  description = "노드 풀의 노드가 배치될 영역(zone) 목록을 설정합니다."
  type        = list(string)
  default     = []
}

variable "node_config" {
  description = "노드 구성 설정"
  type = object({
    machine_type     = optional(string, "e2-medium")                                              # 노드에 사용할 머신 유형 (기본값: e2-medium)
    disk_size_gb     = optional(number, 100)                                                      # 노드 디스크 크기 (기본값: 100GB)
    disk_type        = optional(string, "pd-standard")                                            # 디스크 유형 (기본값: pd-standard)
    image_type       = optional(string, "COS_CONTAINERD")                                         # 컨테이너 이미지 유형 (기본값: COS_CONTAINERD)
    labels           = optional(map(string), {})                                                  # 노드에 적용할 레이블 (기본값: 빈 맵)
    local_ssd_count  = optional(number, 0)                                                        # 로컬 SSD 개수 (기본값: 0)
    metadata         = optional(map(string), { "disable-legacy-endpoints" = "true" })             # 메타데이터 설정 (기본값: disable-legacy-endpoints 설정 포함)
    min_cpu_platform = optional(string, null)                                                     # 최소 CPU 플랫폼 (기본값: null)
    oauth_scopes     = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"]) # OAuth 범위 (기본값: cloud-platform)
    preemptible      = optional(bool, false)                                                      # 선점형 노드 설정 여부 (기본값: false)
    service_account  = optional(string, null)                                                     # 서비스 계정 이메일 (기본값: null)
    tags             = optional(list(string), [])                                                 # 네트워크 태그 (기본값: 빈 리스트)
    accelerators = optional(list(object({
      accelerator_count = number # GPU 가속기 개수
      accelerator_type  = string # GPU 가속기 유형
    })), [])                     # 가속기 설정 (기본값: 빈 리스트)
    taint = optional(list(object({
      key    = string # Taint의 키 값
      value  = string # Taint의 값
      effect = string # Taint의 효과 (예: NO_SCHEDULE)
    })), [])          # Taint 설정 (기본값: 빈 리스트)
  })
  default = null # 기본값은 null
}

variable "network_config" {
  description = "네트워크 구성 설정입니다. create_pod_range, enable_private_nodes, pod_ipv4_cidr_block, pod_range 값을 포함합니다."
  type = object({
    create_pod_range     = optional(bool, false)  # Pod IP를 위한 범위 생성 여부, 기본값 false
    enable_private_nodes = optional(bool, false)  # 내부 IP만 사용 여부, 기본값 false
    pod_ipv4_cidr_block  = optional(string, null) # Pod IP 범위, 기본값 null
    pod_range            = optional(string, null) # Pod IP 보조 범위, 기본값 null
  })
  default = null
}

variable "upgrade_settings" {
  description = "노드 업그레이드 설정입니다. max_surge, max_unavailable, strategy 값을 포함합니다."
  type = object({
    max_surge       = optional(number, 1)       # 동시에 추가 가능한 노드 수, 기본값 1
    max_unavailable = optional(number, 0)       # 동시에 사용할 수 없는 노드 수, 기본값 0
    strategy        = optional(string, "SURGE") # 업그레이드 전략, 기본값 "SURGE"
  })
  default = null
}

variable "placement_policy" {
  description = "배치 정책 설정입니다. type 및 policy_name 값을 포함합니다."
  type = object({
    type        = optional(string, "COMPACT") # 배치 정책 유형, 기본값 "COMPACT"
    policy_name = optional(string, null)      # 사용자 지정 리소스 정책 이름, 기본값 null
  })
  default = null
}

variable "autoscaling" {
  description = "자동 확장 설정입니다. min_node_count, max_node_count, total_min_node_count, total_max_node_count 값을 포함합니다."
  type = object({
    min_node_count       = optional(number, 1)    # 최소 노드 수, 기본값 1
    max_node_count       = optional(number, 5)    # 최대 노드 수, 기본값 5
    total_min_node_count = optional(number, null) # 총 최소 노드 수, 기본값 null
    total_max_node_count = optional(number, null) # 총 최대 노드 수, 기본값 null
  })
  default = null
}

variable "reservation_affinity" {
  description = "예약 설정입니다. consume_reservation_type, key, values 값을 포함합니다."
  type = object({
    consume_reservation_type = optional(string, "ANY_RESERVATION") # 예약 소비 유형, 기본값 "ANY_RESERVATION"
    key                      = optional(string, null)              # 특정 예약 리소스 키, 기본값 null
    values                   = optional(list(string), [])          # 예약 리소스 값 목록, 기본값 빈 리스트
  })
  default = null
}

variable "create" {
  description = "클러스터 생성 시 최대 대기 시간"
  type        = string
  default     = "30m"
}

variable "update" {
  description = "클러스터 업데이트 시 최대 대기 시간"
  type        = string
  default     = "30m"
}

variable "delete" {
  description = "클러스터 삭제 시 최대 대기 시간"
  type        = string
  default     = "30m"
}