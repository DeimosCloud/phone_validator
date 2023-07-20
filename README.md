# Customers' phone number validator API & UI

API & UI to validate and list customers' and their phone numbers validation and countries.
  
---

## Technical specifications

API application was made by Java v8 using Spring boot framework v2.4.5 and UI was made using ReactJS,


---

### Jumia_phone_validator
 
Terraform was used to create the entire infrastructure, including VPC, security groups, and EC2 instances for the servers. I also utilized official AWS modules to set up EKS with private and public subnets. To reduce dependencies on Ansible, I made use of user data on ECS instances to install applications on the EC2 instances. For instance, I installed Ansible on the master node which has a pubic IP address, PostgreSQL on a dedicated EC2 server, Nginx on the load balancer, and Docker on the microservice. Additionally, I changed the default SSH port.

To ensure a production-ready environment, only the load balancer resides in a public subnet accessible from the internet. The microservice is located behind the load balancer, with incoming traffic reaching both the microservice and a PostgreSQL database situated further back.

For configuration management, Ansible played a crucial role in creating users, databases, and privileges on the PostgreSQL server, modifying SSH permissions, and disabling root login on all servers. I also used Ansible to set up iptables, configuring a firewall that allows only specific traffic on ports 80, 443, and 1337. I organized these tasks into Ansible roles, and a playbook named "server.yaml" was created to orchestrate them. Additionally, I used another playbook called "docker-run" to deploy containers into the microservice.

To automate the deployment process, I set up two GitHub Action pipelines. The first action, infra-deploy handles infrastructure deployment, including the Terraform setup. In this action, Ansible files are copied to the Ansible master node through scp and then ssh into the master node before executing the playbook. Since the other servers all ser have private IP addresses and cannot be reached publically within the same VPC, Ansible commands must be executed from there.

The second GitHub Action pipeline is responsible for building Docker images for both the frontend and backend applications and pushing them to an ECR repository created through Terraform. Subsequently, Ansible takes over and deploys the images to the microservice server. Finally the containers in ecr is deployed to kubernetes with 3 nodes in different availability zones.
The frontend application can be reach on kubernetes through a node svc via the loadbalancer public ip http://52.211.167.97/ 
---

