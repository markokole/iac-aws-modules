# AWS with Terraform

## Access to AWS

### User

You need an AWS user with full access to policies:

- AmazonVPCFullAccess
- AmazonECS_FullAccess

and the access key and the secret access key.

### Credentials file

Create a folder *aws* and prepare a credentials file in the folder with the following key-value structure

```bash
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=
```

### Create work environment

The repository's folder *terraform* will map to the Docker's volume called *local-git*. Change <CONTAINER_NAME> with meaningful name in the below command before executing it.

Run the following command

```bash
docker run -itd --name <CONTAINER_NAME> --env-file "aws/credentials" --volume $PWD/terraform:/local-git markokole/terraformer:1.0.3
```

This will start the container. Now step into the container with the following command:

```bash
docker exec -it terraformer-aws /bin/sh
```

## Usage

The home directory is *local-git* - it is advised to enter it right away.

Terraform commands such as *init*, *plan*, *apply* and *destroy* are used once in the module directories.

Module directories available:

- vpc (Virtual Private Cloud)
- sg (Security Groups)
- ec2 (Elastic Compute Cloud)
- ecs (Elastic Container Service)
- redshift (Amazon's Datawarehouse)
- rds (Relational Database Service)

### VPC

Enter directory $HOME/vpc.

Provisioning from this folder creates a VPC with basic resources in it.

![alt text](diagrams/aws-vpc.png "VPC infrastructure")

### EC2

Enter directory $HOME/ec2.

Provisioning from this folder executes VPC module (located in vpc) and EC2 module. The following infrastructure is built:

![alt text](diagrams/aws-ec2.png "VPC infrastructure with EC2 instances")
