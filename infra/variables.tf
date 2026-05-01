variable "bucket_name" {
  description = "Nome do bucket S3 para hospedagem do site"
  type        = string
  default     = "nas-nuvens-website-aws-2026" # S3 exige nomes globais únicos
}