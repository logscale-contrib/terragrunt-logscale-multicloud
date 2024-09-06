# data "aws_s3_bucket" "bucket_blue" {
#   bucket = var.logscale_storage_bucket_id_blue
# }
# data "aws_s3_bucket" "bucket_green" {
#   bucket = var.logscale_storage_bucket_id_green
# }
data "aws_s3_bucket" "ls_export" {
  bucket = var.logscale_export_bucket_id
}
data "aws_s3_bucket" "ls_archive" {
  bucket = var.logscale_archive_bucket_id
}
