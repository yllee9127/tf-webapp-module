module "web_app" {
  source = "./modules/web_app"

  name_prefix = "yl-webapp"

  instance_type = "t2.micro"
  #instance_type = data.instance_type.this

  instance_count = 2

  #vpc_id = "vpc-0f02d959e8f400a7e"
  vpc_id = "vpc-0a45d078c6a5528a8"
  #public_subnet = true
  public_subnet = false
  #alb_listener_arn = "arn:aws:elasticloadbalancing:ap-southeast-1:255945442255:loadbalancer/app/shared-alb/781df24a664ff5db"
  alb_listener_arn = "arn:aws:elasticloadbalancing:ap-southeast-1:255945442255:loadbalancer/app/shared-alb/a61cdec9ce1fb283"
}