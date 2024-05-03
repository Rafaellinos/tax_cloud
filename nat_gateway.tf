


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "private_subnet_route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.private_subnet_b.id
}

resource "aws_eip" "nat" {
  vpc = true
}
