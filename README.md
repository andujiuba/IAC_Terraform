# Infastructure as Code Using Terraform 

![](img\terraform_icon.webp)

Recommended to learn both Terraform and Anisible as companues may prefer one ver the other.
Terraform is a much more simple program to use, and Anisible requires more resources.
Terraform is lightwieght but not agentless

## Installation of Terraform and Chocolaty

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

## Main Commands
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

## Terraform Orchestration
## What is Terraform
## Why Terraform
## Setting Up Terraform
## Securing the AWS Keys for Terraform


Infrastructure Code
- terraform plan
- terraform apply
- terraform destroy


**Tasks:**
- create env variable to secure AWS keys
- Restart the terminal
- Create file called main.tf
- Add the Code to initialise terraform with provider AWS

```
provider "aws" {

    region = "eu-west-1"
}
```
- Run this code with `terraform init`
