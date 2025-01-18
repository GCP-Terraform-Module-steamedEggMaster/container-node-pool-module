package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformCreate(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/create-test", // Terraform 루트 모듈 경로
	}

	// Terraform Init 및 Apply 실행
	defer terraform.Destroy(t, terraformOptions) // 테스트 종료 후 리소스 정리
	terraform.InitAndApply(t, terraformOptions)
}