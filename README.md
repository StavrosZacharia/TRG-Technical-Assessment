# TRG-Technical-Assessment
# Flask Application deployment with Jenkins, ArgoCD and Traefik

## Overview
This document outlines my approach towards the Technical Assessment for my interview with TRG. The assessment showcases the use of various tools and technologies in order to deploy a simple "Hello World" application securely, while also ensuring risk recovery and elasticity.

## Tools and Technologies
The assessment brief dictates the use of specific tools to accomplish these tasks. These tools are listed below.

<b>Jenkins</b>: Automation of repeated tasks and processes.
<b>ArgoCD</b>: Application deployment management and synchronization.
<b>Helm</b>: Application resource manager, flexible configurations.
<b>Traefik</b>: Acts as ingress controller, manages routing.

## Principles

### Jenkins
<li> <b>Automation</b>: Handles the full Ci/CD lifecycle, builds Docker images, pushes them to remote repository, and updates the Kubernetes deployment with Helm.
<li> <b>Continuous Delivery</b>: The pipeline configuration is set to detect any changes in the codebase and triggers a build, which is also applied to the Kubernetes environment.
<li> <b>Reproducibility</b>: By updating specific images and using Helm to deploy the application, the pipeline ascertains the application version can be reproduced consistently.

### GitOps with ArgoCD

<li> <b>Declarative Deployments</b>: Utilizing Infrastructure as Code, ArgoCD syncs application configuration storewd in Git automatically.

### Helm Chart

<li> <b>Reusability</b>: The Helm chart can be used for other environments as well, by simply adjusting some values.

### Traffic Management with Traefik

<li> <b>Whitelisting IP</b>: IP ranges are whitelisted to ensure that the traffic accessing the application is trusted.

## Decisions

The assessment brief has already made most of the process, tool and technology decisions. Below are listed some of my personal decisions.

<li> <b>Deployment of the infrastructure</b>: All of the instance deployments required by each tool, have been deployed on my local machine. This was chosen in place of using Amazon EC2 due to the potential costs in the scenario of exceeding free tier resources. This decision was <b>NOT</b> the correct decision due to the fact that my local machine has major differences in comparison to other systems, whereas an EC2 instance with predefined configurations will always be mostly identical to any new instances needed in the future. However, as this is just an assessment, I did not want to risk unwanted costs.

<li> <b>User authentication</b>: The various tools used in this project require authentication. For this challenge, I used Jenkins' built-in credential provider which encrypts the provided secrets and then uses a generated ID to access them in the builds.

## Envisioned infrastructure

GitHub terraform repository which will create the infrastructure on AWS.

GitHub project-specific repository with 3 separate branches equivalent to the required environment (production, staging, development) with a webhook configured to trigger a build on Jenkins.

Jenkins starts the build, builds the image with the new changes, and pushes the image to Amazon ECR, then triggers changes which are utilized by Helm to trigger an update on Amazon EKS.

Amazon Web Services:
<li> VPC with correctly configured networking resources.
<li> EC2 instance which will serve as the Jenkins host.
<li> ECR repository for the project.
<li> EKS cluster for each environment.

Traefik Proxy (though this can be replaced with AWS ALB for a more AWS-native solution) will be responsible for load balancing, routing traffic, dynamic scaling and help with downtime.

## Envisioned process

Developer Pushes Code to GitHub

Jenkins Webhook Detects Code Changes

Jenkins Selects the Environment Based on Branch

Jenkins Creates Docker Image

Jenkins Pushes Docker Image to ECR

Jenkins Deploys with Helm to EKS

## Recommendations for Future Work
<b>Integrate Let's Encrypt for SSL</b>: Allows for trusted, automatic SSL certificates.
<b>Implement Logging and Monitoring</b>: Set up monitoring through tools like Grafana and Prometheus.
<b>Security Enhancements</b>: Apply RBAC in Kubernetes and Jenkins to limit access on sensitive tasks.