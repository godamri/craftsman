# Infrastructure as Code (IaC) & Terraform Safety

Terraform and IaC state files represent the authoritative state of cloud infrastructure. State corruption or unchecked destructive plans can destroy entire production clusters.

---

## 1. Protecting Stateful Resources

Always configure `lifecycle { prevent_destroy = true }` on production databases, VPCs, and storage buckets:

```hcl
resource "aws_db_instance" "primary" {
  identifier        = "prod-db-primary"
  engine            = "postgres"
  instance_class    = "db.r6g.xlarge"
  allocated_storage = 500

  lifecycle {
    prevent_destroy = true
  }
}
```

---

## 2. Remote State Locking & Encryption

- Enable state locking via DynamoDB or GCS to prevent race conditions during concurrent `terraform apply` operations.
- Enable server-side encryption and versioning on the state bucket to allow recovery from accidental state corruption or deletion.
