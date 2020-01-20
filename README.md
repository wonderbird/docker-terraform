# Docker Terraform

[![Docker Status](https://img.shields.io/docker/status/boos/terraform.svg)](https://hub.docker.com/repository/docker/boos/terraform)

Docker image containing Terraform, AWS CLI, Azure CLI and Helm

## Quick Reference

-   **Where to get help**:
    [Stefan Boos](mailto:kontakt@boos.systems)

-   **Where to file issues**:
    [GitHub issue tracker for this container](https://github.com/wonderbird/docker-terraform/issues)

-   **Maintained by**:
    [Stefan Boos](mailto:kontakt@boos.systems)

-   **Supported architectures**:
    only tested on i386 (macOS Mojave on Intel Core i7), others may work; see base image [hashicorp/terraform](https://hub.docker.com/r/hashicorp/terraform)

-   **Source of this description**:
    [GitHub README.md for this container](https://github.com/wonderbird/docker-terraform/blob/master/README.md)

## Getting Started

To get a docker image containing terraform, the aws cli, the azure cli and helm build the docker image:

```sh
docker build -t boos/terraform .

docker login
docker push boos/terraform
```

## Running the Container

### ... With AWS CLI Support

**Please be aware** that by running the terraform configuration on a non-free account will result costs.

You can create a [free aws account here](https://aws.amazon.com/free/).

In order for the setup to work you need to provide a valid Access Key ID and Secret Access Key to the container in the form of environment variables. You can obtain these values from [your aws identity management page](https://console.aws.amazon.com/iam/home?region=eu-central-1#/security_credentials).

```sh
# Use the following two commands to store AWS secrets in environment variables
# without showing them to others watching your screen
echo -n "AWS access key id: " && read -s AWS_ACCESS_KEY_ID
echo -n "AWS secret access key: " && read -s AWS_SECRET_ACCESS_KEY

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

# Run the container. We assume that /your/working/directory contains your terraform configuration
docker run -it --rm --name terra \
           -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
           -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
           -v /your/working/directory:/root/work
           boos/terraform

# Inside the container cd to the directory containing your terraform configuration
cd /root/work

# ... if this is the first time you run terraform, initialize terraform. Do this only, if you don't have a terraform.tfstate file in the current directory.
terraform init

# ... check the planned changes
terraform plan

# ... if you like the changes, then apply them
terraform apply

# ... check the results on the amazon aws console:
# https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#Instances:sort=instanceId
# ... and using terraform
terraform show
```

### ... With Azure CLI Support

```sh
# Use the following two commands to store AWS secrets in environment variables
# without showing them to others watching your screen
echo -n "Azure client id: " && read -s ARM_CLIENT_ID && echo
echo -n "Azure client secret: " && read -s ARM_CLIENT_SECRET && echo
echo -n "Azure subscription id: " && read -s ARM_SUBSCRIPTION_ID && echo
echo -n "Azure tenant id: " && read -s ARM_TENANT_ID && echo

export ARM_CLIENT_ID
export ARM_CLIENT_SECRET
export ARM_SUBSCRIPTION_ID
export ARM_TENANT_ID

# Run the container
docker run -it --rm --name terra \
           -e "ARM_CLIENT_ID=$ARM_CLIENT_ID" \
           -e "ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID" \
           -e "ARM_TENANT_ID=$ARM_TENANT_ID" \
           -e "ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET" \
           -v /your/working/directory:/root/work \
           boos/terraform

# Inside the container cd to the directory containing your terraform configuration
cd /root/work

# ... if this is the first time you run terraform, initialize terraform. Do this only,
# if you don't have a terraform.tfstate file in the current directory.
terraform init

# ... check the planned changes
terraform plan -var client_id="$ARM_CLIENT_ID" -var client_secret="$ARM_CLIENT_SECRET" --out localplan

# ... if you like the changes, then apply them
terraform apply localplan

# ... check the results on the azure portal:
# https://portal.azure.com/#home
# ... and using terraform
terraform show
```

## References

* HashiCorp: [Learn about provisioning infrastructure with HashiCorp Terraform](https://learn.hashicorp.com/terraform), last visited on Jan. 12, 2020.
* HashiCorp: [terraform Docker Container](https://hub.docker.com/r/hashicorp/terraform), Docker Hub, last visited on Jan. 11, 2020.
* HashiCorp: [Terraform Configuration Language](https://www.terraform.io/docs/configuration/index.html), last visited on Jan. 11, 2020.
* HashiCorp: [Learn about provisioning infrastructure with HashiCorp Terraform](https://learn.hashicorp.com/terraform), last visited on Jan. 12, 2020.
* Microsoft: [Azure Portal](https://portal.azure.com/?quickstart=true#blade/Microsoft_Azure_Resources/QuickstartCenterBlade), last visited on Jan. 12, 2020.
* Microsoft: [Install Azure CLI](https://docs.microsoft.com/de-de/cli/azure/install-azure-cli?view=azure-cli-latest), last visited on Jan. 16, 2020.
* Kubernetes: [Web UI (Dashboard)](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/), last visited on Jan. 16, 2020.
* Canonical: [Amazon EC2 AMI Locator](https://cloud-images.ubuntu.com/locator/ec2/), last visited on Jan. 12, 2020.