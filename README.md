# container-node-pool-module
GCP Terraform Container Node Pool Module Repo

GCP에서 GKE(Google Kubernetes Engine) 노드 풀을 관리하기 위한 Terraform 모듈입니다. <br> 
이 모듈은 노드 풀 생성, 구성, 관리, 그리고 자동 확장을 지원하도록 설계되었습니다.

<br>

## 📑 **목차**
1. [모듈 특징](#모듈-특징)
2. [사용 방법](#사용-방법)
    1. [사전 준비](#1-사전-준비)
    2. [입력 변수](#2-입력-변수)
    3. [모듈 호출 예시](#3-모듈-호출-예시)
    4. [출력값 (Outputs)](#4-출력값-outputs)
    5. [지원 버전](#5-지원-버전)
    6. [모듈 개발 및 관리](#6-모듈-개발-및-관리)
3. [테스트](#terratest를-이용한-테스트)
4. [주요 버전 관리](#주요-버전-관리)
5. [기여](#기여-contributing)
6. [라이선스](#라이선스-license)

---

## 모듈 특징

- GKE 노드 풀 생성 및 관리.
- 다양한 노드 설정 (머신 타입, 디스크 크기, 이미지 유형 등) 지원.
- 자동 확장(Autoscaling) 및 업그레이드(Upgrade) 설정.
- 네트워크 구성 및 Taint 설정 포함.
- 주요 구성 요소의 출력값 제공.

---

## 사용 방법

### 1. 사전 준비

다음 사항을 확인하세요:
1. Google Cloud 프로젝트 준비.
2. 적절한 IAM 권한 필요: `roles/container.admin`, `roles/compute.admin`.

<br>

### 2. 입력 변수

| 변수명                  | 타입             | 필수 여부 | 기본값                      | 설명                                                                 |
|-------------------------|------------------|-----------|-----------------------------|----------------------------------------------------------------------|
| `cluster`              | string           | ✅        | 없음                        | 클러스터 이름                                                       |
| `name`                 | string           | ❌        | null                        | 노드 풀 이름                                                        |
| `name_prefix`          | string           | ❌        | null                        | 노드 풀 이름 접두사                                                 |
| `location`             | string           | ❌        | null                        | 노드 풀이 생성될 지역/영역                                          |
| `project`              | string           | ❌        | null                        | GCP 프로젝트 ID                                                     |
| `initial_node_count`   | number           | ❌        | null                        | 초기 노드 수                                                        |
| `node_count`           | number           | ❌        | null                        | 고정된 노드 수                                                      |
| `management`           | object           | ❌        | `{ auto_repair: true, auto_upgrade: true }` | 노드 자동 관리 옵션                                                 |
| `max_pods_per_node`    | number           | ❌        | null                        | 노드 하나당 최대 Pod 수                                             |
| `node_locations`       | list(string)     | ❌        | 빈 리스트                    | 노드 풀의 노드가 배치될 영역 목록                                   |
| `node_config`          | object           | ❌        | null                        | 노드 구성 설정                                                      |
| `network_config`       | object           | ❌        | null                        | 네트워크 구성 설정                                                  |
| `upgrade_settings`     | object           | ❌        | null                        | 업그레이드 설정                                                     |
| `placement_policy`     | object           | ❌        | null                        | 배치 정책 설정                                                      |
| `autoscaling`          | object           | ❌        | null                        | 자동 확장 설정                                                      |
| `create`               | string           | ❌        | `30m`                       | 노드 풀 생성 시간 제한                                              |
| `update`               | string           | ❌        | `30m`                       | 노드 풀 업데이트 시간 제한                                          |
| `delete`               | string           | ❌        | `30m`                       | 노드 풀 삭제 시간 제한                                              |

#### `node_config` 객체 필드
| 필드명           | 타입             | 필수 여부 | 기본값                     | 설명                                                              |
|------------------|------------------|-----------|----------------------------|-------------------------------------------------------------------|
| `machine_type`  | string           | ❌        | `e2-medium`               | 노드 머신 타입                                                   |
| `disk_size_gb`  | number           | ❌        | `100`                     | 디스크 크기                                                      |
| `disk_type`     | string           | ❌        | `pd-standard`             | 디스크 유형                                                      |
| `image_type`    | string           | ❌        | `COS_CONTAINERD`          | 이미지 유형                                                      |
| `labels`        | map(string)      | ❌        | 빈 맵                      | 노드 레이블                                                      |
| `local_ssd_count`| number           | ❌        | `0`                       | 로컬 SSD 개수                                                   |
| `metadata`      | map(string)      | ❌        | `{ disable-legacy-endpoints = true }` | 노드 메타데이터 설정                                             |
| `min_cpu_platform`| string          | ❌        | null                      | 최소 CPU 플랫폼                                                  |
| `oauth_scopes`  | list(string)     | ❌        | `[\"https://www.googleapis.com/auth/cloud-platform\"]` | OAuth 범위                                                       |
| `preemptible`   | bool             | ❌        | `false`                   | 선점형 노드 여부                                                 |
| `service_account`| string           | ❌        | null                      | 서비스 계정                                                      |
| `tags`          | list(string)     | ❌        | 빈 리스트                   | 네트워크 태그                                                    |
| `taint`         | list(object)     | ❌        | 빈 리스트                   | Taint 설정                                                       |

#### `reservation_affinity` 객체 필드
| 필드명                  | 타입             | 필수 여부 | 기본값                     | 설명                                                               |
|-------------------------|------------------|-----------|----------------------------|--------------------------------------------------------------------|
| `consume_reservation_type` | string        | ❌        | `ANY_RESERVATION`          | 예약 리소스 유형 설정                                              |
| `key`                  | string           | ❌        | null                       | 예약 리소스 키                                                    |
| `values`               | list(string)     | ❌        | 빈 리스트                   | 예약 리소스 값                                                    |

#### `timeouts` 객체 필드
| 필드명   | 타입   | 필수 여부 | 기본값  | 설명                    |
|----------|--------|-----------|---------|-------------------------|
| `create` | string | ❌        | `30m`   | 생성 작업 시간 제한     |
| `update` | string | ❌        | `30m`   | 업데이트 작업 시간 제한 |
| `delete` | string | ❌        | `30m`   | 삭제 작업 시간 제한     |

#### `management` 객체 필드
| 필드명         | 타입 | 필수 여부 | 기본값 | 설명                       |
|----------------|------|-----------|--------|----------------------------|
| `auto_repair`  | bool | ❌        | `true` | 노드 자동 수리 여부        |
| `auto_upgrade` | bool | ❌        | `true` | 노드 자동 업그레이드 여부  |

#### `autoscaling` 객체 필드
| 필드명                 | 타입   | 필수 여부 | 기본값 | 설명                     |
|------------------------|--------|-----------|--------|--------------------------|
| `min_node_count`       | number | ❌        | `1`    | 최소 노드 수             |
| `max_node_count`       | number | ❌        | `5`    | 최대 노드 수             |
| `total_min_node_count` | number | ❌        | null   | 전체 최소 노드 수        |
| `total_max_node_count` | number | ❌        | null   | 전체 최대 노드 수        |

#### `upgrade_settings` 객체 필드
| 필드명           | 타입   | 필수 여부 | 기본값 | 설명                                |
|------------------|--------|-----------|--------|-------------------------------------|
| `max_surge`      | number | ❌        | `1`    | 업그레이드 중 추가 가능한 최대 노드 수 |
| `max_unavailable`| number | ❌        | `0`    | 업그레이드 중 비활성화 가능한 최대 노드 수 |
| `strategy`       | string | ❌        | `SURGE`| 업그레이드 전략 (예: `SURGE`)       |

#### `placement_policy` 객체 필드
| 필드명        | 타입   | 필수 여부 | 기본값   | 설명                             |
|---------------|--------|-----------|----------|----------------------------------|
| `type`        | string | ❌        | `COMPACT`| 배치 정책 유형                   |
| `policy_name` | string | ❌        | null     | 사용자 정의 리소스 정책 이름     |

#### `network_config` 객체 필드
| 필드명               | 타입   | 필수 여부 | 기본값 | 설명                              |
|----------------------|--------|-----------|--------|-----------------------------------|
| `create_pod_range`   | bool   | ❌        | `false`| Pod IP를 위한 새로운 범위 생성 여부 |
| `enable_private_nodes` | bool | ❌        | `false`| 노드가 내부 IP만 사용하도록 설정  |
| `pod_ipv4_cidr_block`| string | ❌        | null   | Pod IP 범위를 CIDR 형식으로 지정  |
| `pod_range`          | string | ❌        | null   | Pod IP에 사용할 기존 보조 범위    |

<br>

### 3. 모듈 호출 예시
```hcl
module "gke_node_pool" {
  source = "git::https://github.com/GCP-Terraform-Module-steamedEggMaster/container-node-pool-module.git?ref=v1.0.0"

  cluster              = "example-cluster"
  name                 = "example-node-pool"
  location             = "us-central1-a"
  project              = "example-project"
  initial_node_count   = 2
  management = {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config = {
    machine_type    = "e2-medium"
    disk_size_gb    = 100
    disk_type       = "pd-standard"
    image_type      = "COS_CONTAINERD"
    labels          = { "env" = "production" }
    local_ssd_count = 0
    metadata        = { "disable-legacy-endpoints" = "true" }
  }

  autoscaling = {
    min_node_count = 1
    max_node_count = 5
  }
}
```

<br>

### 4. 출력값 (Outputs)

| 출력명                | 설명                                                                 |
|-----------------------|----------------------------------------------------------------------|
| `id`                 | 생성된 노드 풀의 ID입니다.                                           |
| `name`               | 노드 풀의 이름입니다.                                               |
| `location`           | 노드 풀이 배치된 위치입니다.                                         |
| `instance_group_urls`| 노드 풀에 연결된 관리 인스턴스 그룹의 URL 목록입니다.                 |
| `node_config`        | 노드 풀 구성 매개변수입니다.                                         |
| `autoscaling`        | 노드 풀의 자동 확장 설정입니다.                                      |
| `management`         | 노드 풀 관리 설정입니다.                                            |

<br>

### 5. 지원 버전

#### a.  Terraform 버전
| 버전 범위 | 설명                              |
|-----------|-----------------------------------|
| `1.10.3`   | 최신 버전, 지원 및 테스트 완료                  |

#### b. Google Provider 버전
| 버전 범위 | 설명                              |
|-----------|-----------------------------------|
| `~> 6.0`  | 최소 지원 버전                   |

<br>

### 6. 모듈 개발 및 관리

- **저장소 구조**:
  ```
  container-node-pool-module/
  ├── .github/workflows/  # github actions 자동화 테스트
  ├── examples/           # 테스트를 위한 루트 모듈 모음 디렉터리
  ├── test/               # 테스트 구성 디렉터리
  ├── main.tf             # 모듈의 핵심 구현
  ├── variables.tf        # 입력 변수 정의
  ├── outputs.tf          # 출력 정의
  ├── versions.tf         # 버전 정의
  ├── README.md           # 문서화 파일
  ```
<br>

---

## Terratest를 이용한 테스트
이 모듈을 테스트하려면 제공된 Go 기반 테스트 프레임워크를 사용하세요. 아래를 확인하세요:

1. Terraform 및 Go 설치.
2. 필요한 환경 변수 설정 (GCP_PROJECT_ID, API_SERVICES 등).
3. 테스트 실행:
```bash
go test -v ./test
```

<br>

## 주요 버전 관리
이 모듈은 [Semantic Versioning](https://semver.org/)을 따릅니다.  
안정된 버전을 사용하려면 `?ref=<version>`을 활용하세요:

```hcl
source = "git::https://github.com/GCP-Terraform-Module-steamedEggMaster/container-node-pool-module.git?ref=v1.0.0"
```

### Module ref 버전
| Major | Minor | Patch |
|-----------|-----------|----------|
| `1.0.0`   |    |   |


<br>

## 기여 (Contributing)
기여를 환영합니다! 버그 제보 및 기능 요청은 GitHub Issues를 통해 제출해주세요.

<br>

## 라이선스 (License)
[MIT License](LICENSE)