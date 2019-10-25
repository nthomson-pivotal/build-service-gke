# Pivotal Build Service GKE Quickstart

Quickly set up Pivotal Build Service on GKE for experimentation.

## Terraform Resources

Go in to `build-service-gke/terraform` and create a file called `terraform.tfvars`, using `terraform.tfvars.tmpl` as an example.

Now initialize Terraform:

```
terraform init
```

And apply:

```
terraform apply
```

This should take about 5 minutes to deploy. You will then get outputs similar to the following:

```
TODO
```

## Install Pivotal Build Service

(Note: This currently require dockerhub account)

Go to the root of `build-service-gke` and run:

```
./install-pbs.sh <your pivnet token> <your dockerhub username> <your dockerhub password>
```