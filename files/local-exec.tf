// zip files for lambda
resource "null_resource" "start-ec2-zip" {
  provisioner "local-exec" {
    command = "zip ./start-ec2.zip ./start-ec2.py"
  }
}

resource "null_resource" "stop-ec2-zip" {
  provisioner "local-exec" {
    command = "zip ./stop-ec2.zip ./stop-ec2.py"
  }
}
