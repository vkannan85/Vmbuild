# Azure Marketplace VM - Terraform

Deploys a single Azure VM from an Azure Marketplace image (Linux or Windows), along with
a resource group, VNet/subnet, NSG, NIC, and optional public IP.

All deployment-specific values (name, region, SKU, image, credentials, networking) are
supplied through a parameters file (`terraform.tfvars`) instead of being hardcoded, so you
can enter them manually per deployment.

## Files

| File                        | Purpose                                              |
|------------------------------|-------------------------------------------------------|
| `versions.tf`                | Provider requirements                                 |
| `variables.tf`               | All input variable declarations                       |
| `main.tf`                    | Marketplace terms, Linux/Windows VM resources         |
| `network.tf`                 | Resource group, VNet, subnet, NSG, NIC, public IP      |
| `outputs.tf`                 | IPs, VM id, generated password, etc.                   |
| `terraform.tfvars.example`   | **Parameters file template** — copy and fill in       |

## Usage

1. Log in to Azure and select your subscription:
   ```bash
   az login
   az account set --subscription "<subscription-id>"
   ```

2. Copy the parameters template and fill in your values:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   Edit `terraform.tfvars` and set at minimum:
   - `resource_group_name`, `location`
   - `vm_name`, `vm_size`
   - `image_publisher`, `image_offer`, `image_sku`, `image_version`
   - `admin_username`, and either `ssh_public_key` (Linux) or `admin_password` (Windows / password-auth Linux)

   Find marketplace image values with:
   ```bash
   az vm image list --all --publisher <publisher> --offer <offer> --output table
   ```

3. Initialize and deploy:
   ```bash
   terraform init
   terraform plan -var-file="terraform.tfvars"
   terraform apply -var-file="terraform.tfvars"
   ```

4. Get connection details:
   ```bash
   terraform output public_ip_address
   terraform output -raw admin_password   # only if you left admin_password blank / are using Windows
   ```

## Notes

- `terraform.tfvars` is gitignored (it may contain credentials) — only the `.example` template is committed.
- Set `accept_marketplace_terms = true` for third-party/BYOL marketplace images that require accepting legal
  terms before first deployment; leave `false` for standard first-party images (e.g. Canonical Ubuntu, most
  Microsoft-published images).
- Some third-party images also require a `plan` block — set `plan_name`, `plan_publisher`, `plan_product` if
  the marketplace listing specifies one (usually shown in the Azure Portal's "Programmatic Deployment" tab
  for that offer).
- Default NSG rule opens `open_inbound_ports` (default `[22]`) from `open_inbound_source_ranges` (default
  `0.0.0.0/0`). Restrict the source ranges to your own IP before deploying anything real.
- `terraform destroy -var-file="terraform.tfvars"` tears everything down.
