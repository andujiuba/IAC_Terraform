# Infastructure as Code Using Terraform 

![](img\terraform_icon.webp)

# Terraform Orchestration
## What is Terraform
## Why Terraform

Recommended to learn both Terraform and Anisible as companues may prefer one ver the other.
Terraform is a much more simple program to use, and Anisible requires more resources.
Terraform is lightwieght but not agentless

## Setting Up Terraform

### Installation of Terraform and Chocolaty

You can download the binary from the following link:
https://www.terraform.io/downloads.html When you have unzipped the binary file, there's no installer.

should move the file to /usr/local/bin directory and set the Path as env var if necessary.

For Windows, install Chocolaty
https://chocolatey.org/install

we can also install it using chocolatey package managers
`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`

Open power shell in Admin mode

Paste the copied text into your shell and press Enter.

Wait a few seconds for the command to complete.

If you don't see any errors, you are ready to use Chocolatey! Type choco or choco -? now, or see 
Getting Started for usage instructions.

Install Terraform `choco install terraform`

Check installation `terraform --version`

Should see below outcome if everything went well
`Terraform v1.0.4`

<br>

### Main Commands
```bash
Main commands:
  init          Prepare your working directory for other commands
  validate      Check whether the configuration is valid
  plan          Show changes required by the current configuration
  apply         Create or update infrastructure
  destroy       Destroy previously-created infrastructure

All other commands:
  console       Try Terraform expressions at an interactive command prompt
  fmt           Reformat your configuration in the standard style
  force-unlock  Release a stuck lock on the current workspace
  get           Install or upgrade remote Terraform modules
  graph         Generate a Graphviz graph of the steps in an operation
  import        Associate existing infrastructure with a Terraform resource
  login         Obtain and save credentials for a remote host
  logout        Remove locally-stored credentials for a remote host
  output        Show output values from your root module
  providers     Show the providers required for this configuration
  refresh       Update the state to match remote systems
  show          Show the current state or a saved plan
  state         Advanced state management
  taint         Mark a resource instance as not fully functional
  test          Experimental support for module integration testing
  untaint       Remove the 'tainted' state from a resource instance
  version       Show the current Terraform version
  workspace     Workspace management

Global options (use these before the subcommand, if any):
  -chdir=DIR    Switch to a different working directory before executing the
                given subcommand.
  -help         Show this help output, or the help for a specified subcommand.
  -version      An alias for the "version" subcommand.
  ```

## Securing the AWS Keys for Terraform

### Ceating an Env Variable

1. 
![](img\env_step1.png)

2. 
![](img\env_step2.png)

3. 
![](img\env_step3.png)

4. 
![](img\env_step4.png)


Repeat for the AWS secret key

## Creating Resources on AWS

### Setting Up App Instance using Terraform

- env vars just created
- restart the terminal
- Create file called main.tf
- Add the Code to initialise terraform with provider AWS

```
provider "aws" {

    region = "eu-west-1"
}
```
- Run this code with `terraform init`

Let's start with launching an EC2 instance using the app AMI.
We will need:
- AMI ID
- `sre_key.pem` file
- AWS keys setup is already done
- Public IP
- Type of instance `t2.micro`

Add to the main.tf file the information from the AMI:

```
resource "aws_instance" "app_instance" {
    ami = "ami-IDNUMBER"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    tags = {
        Name = "sre_akunma_terraform_app"
    }
}
```

## Creating and Setting Up a VPC (SCRIPTING)

**(image)**
Infrastructure Code
- terraform plan
- terraform apply
- terraform destroy

We are creating a new VPC from AWS using Terraform. The steps are nearly identical to the ones in the `AWS_VPC_Networking` repo.

1.  Create a VPC with CIDR block
```
resource "aws_vpc" "sre_akunma_vpc_tf" {
    cidr_block = "10.101.0.0/16"
    tags = {
        Name = "sre_akunma_vpc_tf"
    }
}
```

2. Run `terraform plan` then `terraform apply` - the VPC should now be running

3. Create a `variable.tf` file and place in the VPC ID 
  - Get VPC ID from AWS **or** from terraform logs
```
variable "vpc_id" {
    default = "vpc-IDNUMBER"
}
```

4. Create internet gateway and attach the IG to the VPC
```
resource "aws_internet_gateway" "sre_akunma_tf_ig" {
    vpc_id = var.vpc_id
    tags = {
        Name = "sre_akunma_tf_ig"
    }
}
```
  - Create a variable for the internet gateway ID, for future use
```
variable "ig_id" {
    default = "igw-IDNUMBER"
}
```

5. Create public subnet for `10.101.1.0/24`:
```
resource "aws_subnet" "sre_akunma_tf_sub" {
    vpc_id = var.vpc_id
    cidr_block = "10.101.1.0/24"
    tags = {
        Name = "sre_akunma_tf_sub"
    }
}
```
And make a variable:
```
variable "aws_pub_subnet" {
    default = "subnet-IDNUMBER"
}
```

6. Create route table
```
resource "aws_route_table" "sre_akunma_tf_rt" {
    vpc_id = var.vpc_id
    route = []
    tags = {
        Name = "sre_akunma_tf_rt"
    }
}
```
Edit route and insert your IG
```
resource "aws_route" "r" {
    route_table_id = var.rt_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = var.ig_id
}
```
Associate public subnet with route table
```
resource "aws_route_table_association" "pub" {
    subnet_id = var.aws_pub_subnet
    route_table_id = var.rt_id
}
```
Add to `variable.tf` for the route table
```
variable "rt_id"{
    default = "rtb-IDNUMBER"
}
```

7. Create a Security Group for our app
```
resource "aws_security_group" "app_group" {
    name = "sre_akunma_tf_sg"
    description = "Security group for app"
    vpc_id = var.vpc_id
    # Inbound rules
    ingress {
        description = "From my IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["YOUR IP"]
    }
    ingress {
        description = "Allow Port 3000"
        from_port = 3000
        to_port = 3000
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        description = "Public Access"
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    # Outbound rules
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "sre_akunma_tf_sg"
    }
}
```
8. In `variable.tf`, add the name and path of the key used to set up the app
```
variable "aws_key_name" {
    default = "NAME"
}

variable "aws_key_path" {
    default = "~/.ssh/NAME.pem"
}
```