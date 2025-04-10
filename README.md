# AWS-Lambda-email-collector

# ☁️ Serverless Email Collection App (AWS Lambda + API Gateway + DynamoDB)

A fully serverless web application that allows users to submit their name and email via a form hosted on an EC2 instance running Apache. Submissions are processed using AWS Lambda and stored securely in DynamoDB, with input validation and duplicate prevention.

---

## 📸 Demo

![Architecture Diagram](./diagram.png)

---

## 🧠 Features

- ✨ Simple HTML form hosted on an EC2 Apache web server
- ⚙️ AWS Lambda function processes form submissions
- 🔐 Validates email format and prevents duplicate entries
- 📦 Stores user data in DynamoDB
- 🌐 API Gateway provides a secure HTTP endpoint
- 🔐 Integrated with AWS KMS for data security
- ☁️ Infrastructure managed with Terraform (IaC)

---

## 🛠️ Tech Stack

- **Frontend**: HTML, CSS, JavaScript
- **Backend**: AWS Lambda (Python)
- **APIs**: AWS API Gateway
- **Database**: Amazon DynamoDB
- **Hosting**: Amazon EC2 (Apache)
- **Security**: AWS KMS, IAM
- **Infrastructure**: Terraform

---

## 🚀 Architecture Overview


---

## ✅ Features & Logic

- **Input Validation**: Ensures `name` and `email` fields are not empty and email format is valid.
- **Duplicate Check**: Uses a `scan` to check if the email is already stored in DynamoDB.
- **Response Messages**: Returns clear and funny messages if the user is already registered.
- **Security**: Data optionally encrypted with KMS; API Gateway secured with IAM roles.

---

## 🚀 Getting Started

### 🧩 Prerequisites
- AWS CLI configured
- Terraform installed
- Access to an AWS account

### ⚙️ Deployment Steps

```bash
# Initialize Terraform
terraform init

# Review and apply resources
terraform apply

# Upload frontend to EC2 instance
scp index.html ec2-user@<ec2-ip>:/var/www/html/
