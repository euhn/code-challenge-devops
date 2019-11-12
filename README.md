# Code Challenge: DevOps

This represents my submission for the DevOps code challenge.
* [Source: Webserver Challenge](https://github.com/ByteCubed/code-challenges/blob/master/devops/README.md)

Assumptions:
- Terraform is installed
- AWS credentials are set (eg. via "$HOME/.aws/credentials" or Environment Variables)
- Default VPC of AWS account used
- Default region is "us-east-1".  To change, adjust the value in "variables.tf" or append "-var=\<region>" to terraform commands.

## Instructions

From the repo directory root:

Inititialize terraform:
```
terraform init
```

Optional: Generate terraform plan and review:
```
terraform plan
```

Deploy server cluster: (respond yes after review)
```
terraform apply
```

Upon completion of infrastructure provisioning:

Verify output:
```
curl $(terraform output elb_dns_name)
```

Alternatively, at the end of execution terraform will report the public DNS name of the Elastic Load Balancer.  This can be put in a browser to view the output.
