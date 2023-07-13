appname = "nginx" # Change to your nginxname
prefix = "development"
# profile = "example" 
region = "us-west-2"

subnet_id = "subnet-0a6e3ab9e4bcd1034" 
vpc_id = "vpc-0229547a7d384aa08" 

identity_location = "/mnt/c/Users/Admin/Documents/nginx/.ssh/id_rsa" # Change to your key location
allowed_ip = ["58.187.188.129/32", "14.161.17.5/32"]
ec2_ami_id = "ami-03f65b8614a860c29"
ec2_instance_size = "t2.micro"
ec2_instance_count = 1