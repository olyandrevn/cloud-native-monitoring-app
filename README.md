# **Cloud Native Resource Monitoring Python App on K8s!**

## Things you will Learn 🤯

1. Python and How to create Monitoring Application in Python using Flask and psutil
2. How to run a Python App locally.
3. Learn Docker and How to containerize a Python application
    1. Creating Dockerfile
    2. Building DockerImage
    3. Running Docker Container
    4. Docker Commands
4. Create ECR repository using Python Boto3 and pushing Docker Image to ECR
5. Learn Kubernetes and Create EKS cluster and Nodegroups
6. Create Kubernetes Deployments and Services using Python!

# **Youtube Video for step by step Demonstration!**

[![Video Tutorial](https://img.youtube.com/vi/kBWCsHEcWnc/0.jpg)](https://youtu.be/kBWCsHEcWnc)


## **Prerequisites** !

(Things to have before starting the projects)

- [x]  AWS Account.
- [x]  Programmatic access and AWS configured with CLI.
- [x]  Python3 Installed.
- [x]  Docker and Kubectl installed.

# ✨Let’s Start the Project ✨

## **Part 1: Deploying the Flask application locally**

### **Step 1: Clone the code**

Clone the code from the repository:

```
git clone <repository_url>
```

### **Step 2: Install dependencies**

The application uses the **`psutil`** and **`Flask`, Plotly, boto3** libraries. Install them using pip:

```
pip3 install -r requirements.txt
```

### **Step 3: Run the application**

To run the application, navigate to the root directory of the project and execute the following command:

```
python3 app.py
```

This will start the Flask server on **`localhost:8000`**. Navigate to [http://localhost:8000/](http://localhost:8000/) on your browser to access the application.

## **Part 2: Dockerizing the Flask application**

### **Step 1: Create a Dockerfile**

Create a **`Dockerfile`** in the root directory of the project with the following contents:

```
# Use the official Python image as the base image
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file to the working directory
COPY requirements.txt .

RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the application code to the working directory
COPY . .

# setups params for flask app
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=8000

# only for documentation
EXPOSE 8000

# Start the Flask app when the container is run
CMD ["flask", "run"]
```

### **Step 2: Build the Docker image**

To build the Docker image, execute the following command:

```
docker build -t <image_name> .
```

### **Step 3: Run the Docker container**

To run the Docker container, execute the following command:

```
docker run -p 8000:8000 <image_name>
```

This will start the Flask server in a Docker container on **`localhost:8000`**. Navigate to [http://localhost:8000/](http://localhost:5000/) on your browser to access the application.

## **Part 3: Pushing the Docker image to ECR**

### **Step 1: Create an ECR repository**

Create an ECR repository using Python:

```
import boto3

# Create an ECR client
ecr_client = boto3.client('ecr')

# Create a new ECR repository
repository_name = 'cloud-naitive-repo'
response = ecr_client.create_repository(repositoryName=repository_name)

# Print the repository URI
repository_uri = response['repository']['repositoryUri']
print(repository_uri)
```

### **Step 2: Push the Docker image to ECR**

1. Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:
```
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <ecr_repo_uri>
```

2. Build your Docker image using the following command. For information on building a Docker file from scratch, see the instructions here . You can skip this step if your image has already been built:
```
docker build -t cloud-naitive-repo .
```
In case if you want to specify the platform run:
```
docker build --platform linux/amd64 -t cloud-naitive-repo .
```
3. After the build is completed, tag your image so you can push the image to this repository:

```
docker tag cloud-naitive-repo:<tag> <ecr_repo_uri>:<tag>
```
4. Run the following command to push this image to your newly created AWS repository:

```
docker push <ecr_repo_uri>:<tag>
```

## **Part 4: Creating an EKS cluster and deploying the app using Python**

### **Step 1: Create an EKS cluster**

Create an EKS cluster and add node group

```
eksctl create cluster --name cloud-naitive-cluster --region <region> --nodes 2 --node-type t3.micro
eksctl utils associate-iam-oidc-provider --region <region> --cluster cloud-naitive-cluster --approve
```

### **Step 2: Create deployment and service**

```jsx
from kubernetes import client, config

# Load Kubernetes configuration
config.load_kube_config()

# Create a Kubernetes API client
api_client = client.ApiClient()

# Define the deployment
deployment = client.V1Deployment(
    metadata=client.V1ObjectMeta(name="my-flask-app"),
    spec=client.V1DeploymentSpec(
        replicas=1,
        selector=client.V1LabelSelector(
            match_labels={"app": "my-flask-app"}
        ),
        template=client.V1PodTemplateSpec(
            metadata=client.V1ObjectMeta(
                labels={"app": "my-flask-app"}
            ),
            spec=client.V1PodSpec(
                containers=[
                    client.V1Container(
                        name="my-flask-container",
                        image=<ecr_repo_uri>,
                        ports=[client.V1ContainerPort(container_port=8000)]
                    )
                ]
            )
        )
    )
)

# Create the deployment
api_instance = client.AppsV1Api(api_client)
api_instance.create_namespaced_deployment(
    namespace="default",
    body=deployment
)

# Define the service
service = client.V1Service(
    metadata=client.V1ObjectMeta(name="my-flask-service"),
    spec=client.V1ServiceSpec(
        selector={"app": "my-flask-app"},
        ports=[client.V1ServicePort(port=8000)]
    )
)

# Create the service
api_instance = client.CoreV1Api(api_client)
api_instance.create_namespaced_service(
    namespace="default",
    body=service
)
```

make sure to edit the name of the image on line 25 with your <ecr_repo_uri>.

- Once you run this file by running 
```python3 eks.py```
deployment and service will be created.
- Check by running following commands:

```jsx
kubectl get deployment -n default (check deployments)
kubectl get service -n default (check service)
kubectl get pods -n default (to check the pods)
```

Once your pod is up and running, run the port-forward to expose the service

```bash
kubectl port-forward service/<service_name> 8000:8000
```

## **Future work: Expose the Service to External Traffic**


Now that you can access it locally via ```kubectl port-forward```, the next steps involve ensuring that your app is properly exposed, accessible, and ready for production.
You can expose your service using an Elastic Load Balancer (ELB), which AWS manages for you.