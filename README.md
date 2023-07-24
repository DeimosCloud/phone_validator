# Customers' phone number validator API & UI

API & UI to validate and list customers' and their phone numbers validation and countries.
  
---

## Technical specifications

API application was made by Java v8 using Spring boot framework v2.4.5 and UI was made using ReactJS,


---

### Jumia_phone_validator


## AWS Infrastructure
- VPC with subnets
- Security groups
- EC2 instance as Ansible master node, that acts as a jumpbox for other servers
- EC2 instance for postgresql server
- EC2 instance for Microservice server
- EC2 instance for Loadbalancer server with nginx installed
- ECR repositories for front end and backend application
- EKS cluster with a managed node group having nodes that spans across 3 availability zones.

## Overview of the deployment
- Terrfaorm was used to deploy the infrastructure, and the various applications were deployed using terraform userdata, to remove that dependency from Ansible.
- The Ansible master node has a public ip address where only permitted users can connect to it.
- The microservice and database servers are in a private subnet.
- The loadbalancer server is in a public subnet with elastic ip enabled.
- ECR repositories for the applications were created using terraform
- Github Action was used for automating the deployment process.
- The applications were deployed to kubernetes with 3 replicas across 3 nodes in 3 availability zones
- Ansible was used for the configuration management, applying iptables firewall rules, changing default ssh ports etc
- Checkov was added to github pipeline to check for code misconfigurations.

## Recommendations
- use AWS system manager for login to remove the need for management of ssh keys
- use AWS RDS database for postgresql deployment


The application can be reached on kubernetes through a node svc via the loadbalancer public ip http://52.211.167.97/ 


 




