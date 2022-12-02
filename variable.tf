variable "devs" {
  type = object({
    email  = string
    prefix = list(string)
  })
}

variable "my_task_name" {
  type        = string
  description = "task_name"
}

variable "Y_image_id" {
  type = object({
    Ubuntu20 = string
    CentOS8  = string
  })
  description = "Yandex image_id"
}

variable "Y_folder_id" {
  type        = string
  description = "Yandex folder_id"
}

variable "Y_cloud_id" {
  type        = string
  description = "Yandex cloud_id"
}

variable "Y_zone" {
  type        = string
  description = "Yandex zone"
}

variable "passwd" {
  type        = string
  description = "root passwd for VPS"
}

variable "pub_ssh" {
  type        = string
  description = "REBRAIN.SSH.PUB.KEY"
}
variable "module" {
  type        = string
  description = "Name of module"
  default     = "devops"
}
variable "ssh_path" {
  type        = string
  description = "ssh public key path"
}

variable "email" {
  type        = string
  description = "My Email"
  default     = "al-glop-at-mail-ru"
}

variable "my_pub_ssh" {
  type        = string
  description = "My PUB SSH"
}

variable "aws_ak" {
  type        = string
  description = "My AWS Access key"
}

variable "aws_sk" {
  type        = string
  description = "My AWS secret key"
}

variable "aws_dns_devops" {
  type        = string
  description = "AWS dns root name"
  default     = "devops.rebrain.srwx.net"
}
