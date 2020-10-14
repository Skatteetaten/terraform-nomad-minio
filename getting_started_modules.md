## Getting Started

### Content
1. [Goal of This Guide](#goal-of-this-guide)
2. [Directory Structure](#directory-structure)
3. [The development process](#the-development-process)
  1. [0. Creating A Repository](#0-creating-a-repository)
  1. [1. Building Docker Image](#1-building-docker-image)
  2. [2. Deploying Container With Nomad](#2-deploying-container-with-nomad)
    1. [a. Making image available to Nomad](#a-making-image-available-to-nomad)
    2. [b. Creating a nomad job](#b-creating-a-nomad-job)
  3. [3. Creating the Terraform Module](#3-creating-the-terraform-module)
    1. [main.tf](#maintf)
    2. [variables.tf](#variablestf)
    3. [outputs.tf](#outputstf)
  4. [4. Using a Terraform Module](#4-using-a-terraform-module)
    1. [a. How To Use The Module and Run It Manually](#a-how-to-use-the-module-and-run-it-manually)
    2. [b. Using Ansible To Run the Code in the Previous Step On Startup](#b-using-ansible-to-run-the-code-in-the-previous-step-on-startup)
  5. [5. Making The Nomad Job More Dynamic With Terraform Variables](#5-making-the-nomad-job-more-dynamic-with-terraform-variables)
  6. [6. Integrating The Nomad Job With Vault](#6-integrating-the-nomad-job-with-vault)
  7. [7. CI/CD Pipeline To Continuously Test The Module When Changes Are Made](#7-cicd-pipeline-to-continuously-test-the-module-when-changes-are-made)


### Goal of This Guide

> :warning: Read the section `Description - what & why` in [README.md](/README.md) to get a quick introduction to what this repo is.

The template-repo you found this README in is specifically built to make it as easy and quick as possible to make terraform modules, and then test them inside the [vagrant-hashistack](https://app.vagrantup.com/fredrikhgrelland/boxes/hashistack) box. 

This guide aims to show you how to use this template. 
The steps we are going to walk through are as follows:

0. [Creating A Repository](#0-creating-a-repository)
1. [Building Docker Image](#1-building-docker-image) [Optional]
2. [Deploying Container With Nomad](#2-deploying-container-with-nomad)
3. [Creating The Terraform Module](#3-creating-the-terraform-module)
4. [Using a Terraform Module](#4-using-a-terraform-module)
5. [Making The Nomad Job More Dynamic With Terraform Variables](#5-making-the-nomad-job-more-dynamic-with-terraform-variables)
6. [Integrating The Nomad Job With Vault](#6-integrating-the-nomad-job-with-vault)
7. [CI/CD Pipeline To Continuously Test The Module When Changes Are Made](#7-cicd-pipeline-to-continuously-test-the-module-when-changes-are-made)

### Directory Structure
All directories have their own uses, detailed below:

```text
├── conf
│   └── nomad #----------------------- All nomad job files should go here
├── dev
│   ├── ansible #--------------------- All playbooks
│   └── vagrant #--------------------- All box spesific jobs
├── docker #-------------------------- Dockerfile and docker-image related files
├── example #------------------------- Should include a working example(s) of your module
└── template_example #---------------- An example module for reference
```

### The development process

#### 0. Creating A Repository
Before we begin you need to create your own repository. Do that by pressing [Use this template](https://github.com/fredrikhgrelland/vagrant-hashistack-template/generate).
The rest of the steps for this guide should be done inside your own repository.

#### 1. Building Docker Image

> :warning: This section is only relevant if you want to build your own docker image.

Most of the terraform modules will deploy one or more docker-containers to Nomad. 
If you want to create your own docker-image, put the [`Dockerfile`](https://docs.docker.com/engine/reference/builder/) under [docker/](/docker/).
You can find an example where we build docker image for the module in [template_example](/template_example/docker)
#### 2. Deploying Container With Nomad
At this point you should have a service that will run when you start the docker container. 
Either you've made an image yourself, or you are using some pre-made docker image. 
The next step is then to deploy this container to our hashistack ecosystem. Nomad is running inside our virtual machine, and is used to deploy containers, and register them into Consul. 
It also has a tight integration with Vault that we will use later. 


##### a. Making image available to Nomad

> :warning: Skip this step if you are using a pre-made image from [dockerhub](https://hub.docker.com/), or another registry

The image we built in our first step is now available as an image on our local machine, but nomad inside the virtual machine does not have access to that.
The only way Nomad can use our image is by [fetching it from MinIO](https://github.com/fredrikhgrelland/vagrant-hashistack-template/blob/master/template_example/conf/nomad/countdash.hcl#L35-L36), which means we need to upload it to MinIO somehow.
From [the MinIO section](/getting_started_vagrantbox.md#2-minio) we know that anything inside `/vagrant` will be made available.
[This section](/README.md#pushing-resources-to-minio-with-ansible-docker-image) shows how we can use ansible code to get our image in a subfolder of `/vagrant`:

1. create a tmp folder in `/vagrant/dev` inside the box
2. build and archive our docker image (from inside the box) in that tmp folder


##### b. Creating a Nomad job
Next step is to create the Nomad job that deploys our image. 
This guide will not focus on how to make a Nomad job, but a full example can be found at [template_example/conf/nomad/countdash.hcl](template_example/conf/nomad/countdash.hcl).
Your nomad-job file should go under `conf/nomad/`. If you made your own docker image see [fetching docker image](#fetching-resources-from-minio-with-nomad-docker-image) on how to use that in your Nomad job. 
When the Nomad job-file has been created we can try to run it. 
We can do this in one of two ways:

1. Log on the machine with `vagrant ssh` and run it with the Nomad-cli available on the virtual machine. Remember that all files inside `/vagrant` are shared with the folder of
 this file, meaning you can go to `/vagrant/conf/nomad` to find your hcl-file. Then run it with `nomad job run <nameofhcl.hcl>`.  
2. If you have the nomad-cli on your local machine you can run it from your local machine directly with `nomad job run <nameofhcl.hcl>`. 

After sending the job to Nomad you can check the status by going to `localhost:4646`. If you see your job running you can go to the next step.

#### 3. Creating the Terraform Module
> :bulb: Official documentation - [Creation terraform modules](https://www.terraform.io/docs/modules/index.html)

Now that we know the Nomad-job is working we want to write some terraform code that when imported will take the hcl-file and run the Nomad-job. 
This is our terraform module!

A terraform module normally consists of a minimum of three files, `main.tf`, `variables.tf`, `outputs.tf`. Technically we only need one, but it's customary to separate the code
 into, at least, these three. 
- `main.tf`, contains the [resources](https://www.terraform.io/docs/configuration/resources.html) used.
- `variables.tf`, contains all variables used. 
- `outputs.tf`, defines any output variables (if relevant). 
All files should be put in the root (same as the folder this README is in). 

Below is a more detailed description of what to put in each file.

##### main.tf
In our case the only thing our `main.tf` should contain is a resource that takes our nomad-job file and deploys it to Nomad. Below is an example of such a resource:

```hcl-terraform
resource "nomad_job" "countdash" {
  jobspec = file("${path.module}/conf/nomad/countdash.hcl")
  detach  = false
}
```

`${path.module}` is the path to where our module is. `detach = false` tells terraform to wait for the service to be healthy in Nomad before finishing. 
[Resource documentation](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs/resources/job).


##### variables.tf

> :warning: In the first iteration we don't need any input variables.

In this file you define any variables you would want to be [input variables](https://www.terraform.io/docs/configuration/variables.html) to your module. 
If we are provisioning a postgres service, maybe we'd like a "Name of postgres database" variable as input, or "Number of servers to provision" if you are provisioning a cluster.  
A variable is defined like below:

```hcl-terraform
variable "service_name" {
  type        = string
  description = "Minio service name"
  default     = "minio"
}
```

##### outputs.tf

> :warning: In the first iteration we don't need any output variables.

This files contains variables that will be available as [output variables](https://www.terraform.io/docs/configuration/outputs.html) when you use a module. 
Below is first an example of how to define output-variables, then an example of how to use a module, and access their output variables.
Defining output variables:

 ```hcl-terraform
output "nomad_job" {
  value       = nomad_job.countdash
  description = "The countdash Nomad job object"
}
```

> :bulb: Together inputs and outputs should create a very clear picture of how a module should be used. 
>For example in our hive module we have clearly defined that it needs to have a postgres-address as an input. 
>In our postgres module we have an output that is exactly that. In other words, we might need to import and setup a postgres-module before setting up our hive-module, so that we get a postgres-address to give our hive-module. 
>Or, if we already have a postgres-address available, we could supply that instead. The goal is to clearly define the needs of a module, while at the same time making it flexible and generic (in the example of hive we give the user the ability to use any postgres they'd like). 
>How to use variables and outputs will be shown later in [make the module more dynamic](#5-making-the-nomad-job-more-dynamic-with-terraform-variables).


#### 4. Using a Terraform Module
At this point we have created three files (or one): 

- `main.tf` 
- `variables.tf` 
- `outputs.tf` 

Together they do one thing: Start a nomad job. 
Aren't we done with our goal then? Almost. We still need to verify that it works the way we expect it to. 
Next step is to write some terraform code that runs the module we just made. Then we'll import that code to our virtual machine and run it there. 
There are two steps to this:
1. Write the code that uses the module, and run it manually inside the virtual machine 
2. Write ansible code that'll run the code automatically when you start the box.

Below is an example on how to use a module:

 ```hcl-terraform
module "minio" {
  source = "github.com/fredrikhgrelland/terraform-nomad-minio.git?ref=0.0.3"
}
```

This will fetch the module at the given source. 
In the case above it is a [MinIO module, version 0.0.3](https://github.com/fredrikhgrelland/terraform-nomad-minio/releases/tag/0.0.3) 


##### a. How To Use The Module and Run It Manually
Create a file called `main.tf` under the `example/` directory, and add the code above, change the module's name, and source. 
The source is `../` in this case because that is where our module files are, relative to the `main.tf` you are writing this in. 

Let's log onto our virtual machine and try and run it! Run `vagrant ssh` if needed, and navigate to your `/vagrant/example/` folder. 
Next run 
```shell script
terraform init
``` 
to initialize a terraform-workspace. When that is done you can try 
```shell script
terraform plan
``` 
which will read your terraform code and attempt to make a runtime plan. 
When doing so you will get the error "Error: Missing required argument The argument "address" is required, but was not set.". 
This is because we are using a resource that deploys a nomad job, but nowhere in our terraform files have we defined _ what_ Nomad to use. 
At the moment no Nomad is known. This is where [providers](https://www.terraform.io/docs/providers/index.html) come into the picture. They are providers for the resources we are using, and in our case we need to define a [Nomad provider](https://registry.terraform.io/providers/hashicorp/nomad/latest). 

We could do this in either of our `main.tf` files, but if we do it in our module's `main.tf` it will be very difficult for anyone to use our module, because the Nomad's address is predefined. 
Instead we should include what nomad to use in our example´s `main.tf`, which is simply an example of how to use the module, meaning anyone else wanting to use the module could supply their own nomad when using the module. 
To supply a provider add the lines below to your `example/main.tf` file:

```hcl-terraform
provider "nomad" {
  address = "http://127.0.0.1:4646"
}
```

We have now told terraform what Nomad we want to use. 
Try running your terraform code with `terraform init` (we need to load the nomad provider), `terraform plan` (this time it should succeed), then lastly `terraform apply`, which will execute the plan. 
Go to `localhost:4646` to check if the nomad-job has started running, if it has, congratulations, you have made your first working terraform module!



##### b. Using Ansible To Run the Code in the Previous Step On Startup
In [getting_started_vagrantbox.md](/getting_started_vagrantbox.md) it was mentioned that _all_ ansible tasks put inside `dev/ansible/` will be run when the box starts. 
We can use this to automatically start our module when we run `make up`.
The ansible code for running terraform code is below.
Add this to `run-terraform.yml` or another aptly named file.

```yml
- name: Terraform
  terraform:
    project_path: ../../example
    force_init: true
    state: present
  register: terraform

- name: Terraform stdout
  debug:
    msg: "{{terraform.stdout}}"
```


#### 5. Making The Nomad Job More Dynamic With Terraform Variables
At this point we have a "hardcoded" nomad job. 
In the example there isn't really many variables that will benefit from being more dynamic, but we'll demonstrate using the image-name in this case. 
We want to use this to let the user choose their own image in our module. Create a `variables.tf` in the root-directory, then add the lines below

```hcl-terraform
variable "docker_image" {
  type        = string
  description = "docker image to use in module"
}
```
 
Now try to run this module like you've done earlier. 
At this point you'll get an error along the lines of "docker_image variable is not present". 
This is because there is no code anywhere defining `docker_image `. To define this variable we can expand the file that uses our module, which is the `main.tf` in `examples
/`. You can define `docker_image` from within that file like below
```hcl-terraform
module "minio" {
  source = "github.com/fredrikhgrelland/terraform-nomad-minio.git?ref=0.0.3"
  docker_image = "minio/minio"
}
```


##### Useful Characteristics To Put In Variables

We advise starting simple with doing extraction of potentially dynamic data in nomad job, such as:
- job name
- list of data centers
- namespace (enterprise only)
- properties of [update stanza](https://www.nomadproject.io/docs/job-specification/update)
- [service name stanza](https://www.nomadproject.io/docs/job-specification/service#name)
- env variables in [template stanza](https://www.nomadproject.io/docs/job-specification/template)
- docker image in [task -> config -> image](https://www.nomadproject.io/docs/drivers/docker)
- ...

> Extracting variables is a process, so you do not need to extract all dynamic data at once. Try to prioritize user needs.

##### Conditional Rendering of Nomad Job
You can add a boolean variable in `variables.tf` to define a condition.
This variable can the be used by the hcl-file to create conditional rendering of the file. 

Example:  

`variables.tf`

```hcl
variable "use_canary" {
  type = bool
  description = "Uses canary deployment for Presto"
  default = false
}
```

`nomad-job.hcl`
```hcl
...
update {
  max_parallel      = 1
  health_check      = "checks"
  min_healthy_time  = "10s"
  healthy_deadline  = "12m"
  progress_deadline = "15m"
  %{ if use_canary }
  canary            = 1
  auto_promote      = true
  auto_revert       = true
  %{ endif }
  stagger           = "30s"
}
...
```


#### 6. Integrating The Nomad Job With Vault
When we create modules we often need to provide our service with a key or a secret, and in some cases both. 
However, in either case we can use [Vault](https://www.vaultproject.io/) to store keys and secrets that we can get later in our code. 
> :warning: All communication between `terraform` and `vault` is handled by [terraform-provider-vault](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)

Let's use [Postgres](https://www.postgresql.org/) as an example, and say we need to provide it with a username and password. 
The first thing you want to do is to create and store the username and password in Vault. 
For this purpose we'll be using the Vault binary, but keep in mind that we ultimately want to automate this using [Ansible-playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html). 
See the command below:
```sh
# Create a key 'username' with value 'pguser1' and the key 'password' with value '123456'
vault kv put secret/postgres username=pguser1 password=123456
```
You can go to [localhost:8200](http://localhost:8200/) to verify that your keys got uploaded.

What we can do next, is to use the [template](https://www.nomadproject.io/docs/job-specification/template) stanza inside our `.hcl` file, and use [consul-template syntax](https://github.com/hashicorp/consul-template#secret) to render our keys into to separate environment variables.
```hcl-terraform
template {
    destination = "local/secrets/.envs"
    change_mode = "noop"
    env         = true
    data        = <<EOF
PG_USERNAME={{ with secret "secret/postgres" }}{{ Data.username }}{{ end }}
PG_PASSWORD={{ with secret "secret/postgres" }}{{ Data.password }}{{ end }}
EOF
}
```
When you re-run your code using `terraform apply`, the environment variables created in the template should now be available inside the running task container.

> :bulb: Note that you can use [Vault plugin](https://www.vaultproject.io/docs/internals/plugins) to get more useful functionallity out of Vault.

#### 7. CI/CD Pipeline To Continuously Test The Module When Changes Are Made
To test repositories you can use [github actions](https://github.com/features/actions). 
They are written as workflows, which you can find under [.github/workflows](/.github/workflows).
In this template a `make test` will be run with all permutations of configuration switches provided by the vagrant-hashistack box every time a PR is created or altered. 
Refer to [test configuration](/README.md#test-configuration-and-execution) for details. 
To change what tests are run you can either rewrite the `test` target in the [Makefile](/Makefile), or the workflows directly.  
