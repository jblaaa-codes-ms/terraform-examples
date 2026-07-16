# modules

This directory contains reusable Terraform modules that can be referenced by the examples in this repository or by external configurations.

## Structure

Each module lives in its own subdirectory and follows the standard Terraform module layout:

```
modules/
└── <module-name>/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    └── README.md
```

## Usage

Reference a module from an example or an external configuration using a relative path:

```hcl
module "example" {
  source = "../../modules/<module-name>"

  # module inputs
}
```
