# Deploy a VM in Azure with docker installed using Terraform

So, you want to create a Linux Virtual machine in Azure which you can use as a development environment, for example? You are at the right place.
This terraform deployment is based on a [freecodecamp.org](https://www.youtube.com/watch?v=V53AHWun17s) video. Here we are going to deploy a VM in its own Virtual Network and having 
a public IP address. You would be able to generate ssl keys and connect to the VM remotely. The deployment also installs Docker in the VM.


The good thing with this is that it is easily and consistently deployable. You can deploy and take it down within minutes.

## Prerequisites
Make sure you have the following installed
1. [Terraform](https://community.chocolatey.org/packages/terraform)
2. [Visual Studio Code](https://code.visualstudio.com/)
3. [Azure Cli](https://learn.microsoft.com/en-gb/cli/azure/)
4. [Powershell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4). You could also used a linux bash shell
4. [Have an Azure subscription](https://portal.azure.com)

## More reading
You can watch the video used in making this here on [Youtube](https://www.youtube.com/watch?v=V53AHWun17s)

## Author
Dipl. Ing. Clement Nkamanyi
Find out more about me at [www.clenkasoft.com](https://www.clenkasoft.com)
