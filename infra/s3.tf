# Criação do Bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

# Configuração do Bucket para Hospedagem de Site Estático
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Desabilitar bloqueios de acesso público (Necessário para sites públicos)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Política do Bucket para permitir leitura pública
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

# Upload dos arquivos locais para o S3
# Utilizando module/recurso para iterar sobre os arquivos na pasta application
resource "aws_s3_object" "site_files" {
  for_each = fileset("${path.module}/../application", "**/*")

  bucket = aws_s3_bucket.website_bucket.id
  key    = each.value
  source = "${path.module}/../application/${each.value}"

  # Calculando etag para que o Terraform saiba quando o arquivo mudou
  etag = filemd5("${path.module}/../application/${each.value}")

  # Definindo o Content-Type corretamente baseado na extensão
  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "svg"  = "image/svg+xml"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}

output "website_url" {
  description = "A URL do site hospedado no S3"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

