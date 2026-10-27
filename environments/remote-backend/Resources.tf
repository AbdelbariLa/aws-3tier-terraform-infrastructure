
locals {
  Compagne_Name = "ABDELBARI"
  Environment   = "dev"
}


resource "aws_s3_bucket" "Backend" {
  bucket = "remote-backend-iauskhdfuiewhfiuksheefiuhefuk"
  tags = {
    Compagne_Name = local.Compagne_Name
    Environment = local.Environment
  }
}

resource "aws_kms_key" "Backend-key" {
  description             = "This key is used to encrypt bucket objects (remote-backend)"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt-backend" {
  bucket = aws_s3_bucket.Backend.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.Backend-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}