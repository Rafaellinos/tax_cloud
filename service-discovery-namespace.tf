
resource "aws_service_discovery_private_dns_namespace" "otel_namespace" {
  name = "otel_namespace.local"
  vpc  = aws_vpc.my_vpc.id
}

resource "aws_service_discovery_service" "otel_discovery_service" {
  name             = "otel-service"
  namespace_id     = aws_service_discovery_private_dns_namespace.otel_namespace.id
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.otel_namespace.id
    dns_records {
      ttl  = 300
      type = "A"
    }
  }
}
