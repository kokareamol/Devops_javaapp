provider "aws"{
    region = "ap-south-1"
}

resource "aws_instance" "web"{
    instance_type = "t2.micro"
    ami = "ami-03f4878755434977f"
    key_name = "kp_latest"
    subnet_id = aws_subnet.dpw-public_subent_01.id
    for_each = toset (["jenkins-master", "jenkins-slave", "ansible"])
  tags = {
    Name = "${each.key}"
  }
}

resource "aws_vpc" "dpw-vpc" {
    cidr_block = "10.1.0.0/16"
   tags = {
    Name = "dpw-vpc"
  }
}
//Create a Subnet 
resource "aws_subnet" "dpw-public_subent_01" {
    vpc_id = aws_vpc.dpw-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-south-1a"
    tags = {
      Name = "dpw-public_subent_01"
    }
}

resource "aws_subnet" "dpw-public-subnet-02" {
  vpc_id = aws_vpc.dpw-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "dpw-public-subent-02"
  }
}


//Creating an Internet Gateway 
resource "aws_internet_gateway" "dpw-igw" {
    vpc_id = aws_vpc.dpw-vpc.id
    tags = {
      Name = "dpw-igw"
    }
}

// Create a route table 
resource "aws_route_table" "dpw-public-rt" {
    vpc_id = aws_vpc.dpw-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dpw-igw.id
    }
    tags = {
      Name = "dpw-public-rt"
    }
}
// Associate subnet with route table

resource "aws_route_table_association" "dpw-rta-public-subent-1" {
    subnet_id = aws_subnet.dpw-public_subent_01.id
    route_table_id = aws_route_table.dpw-public-rt.id
}

resource "aws_route_table_association" "dpw-rta-public-subnet-02" {
  subnet_id = aws_subnet.dpw-public-subnet-02.id 
  route_table_id = aws_route_table.dpw-public-rt.id   
}


  module "sgs" {
    source = "../sg_eks"
    vpc_id     =     aws_vpc.dpw-vpc.id
 }

  module "eks" {
       source = "../eks"
       vpc_id     =     aws_vpc.dpw-vpc.id
       subnet_ids = [aws_subnet.dpw-public-subnet-01.id,aws_subnet.dpw-public-subnet-02.id]
       sg_ids = module.sgs.security_group_public
 }