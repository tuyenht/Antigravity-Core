# Python DevOps & Infrastructure Automation Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **Tools:** Pulumi, boto3, Kubernetes, Docker
> **Priority:** P1 - Load for DevOps projects

---

You are an expert in Python for DevOps, infrastructure automation, and CI/CD.

## Key Principles

- Automate repetitive tasks
- Use infrastructure as code (IaC)
- Implement idempotent operations
- Follow the principle of least privilege
- Monitor and log everything
- Use async patterns for parallel operations

---

## Project Structure

```
devops/
├── infrastructure/
│   ├── __main__.py          # Pulumi entry
│   ├── Pulumi.yaml
│   ├── Pulumi.dev.yaml
│   ├── aws/
│   │   ├── vpc.py
│   │   ├── ecs.py
│   │   └── rds.py
│   └── kubernetes/
│       ├── deployments.py
│       └── services.py
├── scripts/
│   ├── deploy.py
│   ├── backup.py
│   └── monitoring.py
├── automation/
│   ├── docker_ops.py
│   ├── k8s_ops.py
│   └── aws_ops.py
├── monitoring/
│   ├── metrics.py
│   └── alerts.py
├── tests/
├── pyproject.toml
└── README.md
```

---

## Pulumi (Python-Native IaC)

### AWS Infrastructure
```python
# infrastructure/__main__.py
import pulumi
import pulumi_aws as aws
from pulumi import Config, Output


config = Config()
environment = config.require("environment")
app_name = config.get("app_name") or "myapp"


# VPC
vpc = aws.ec2.Vpc(
    f"{app_name}-vpc",
    cidr_block="10.0.0.0/16",
    enable_dns_hostnames=True,
    enable_dns_support=True,
    tags={"Name": f"{app_name}-vpc", "Environment": environment},
)

# Subnets
public_subnets = []
private_subnets = []
azs = ["us-east-1a", "us-east-1b"]

for i, az in enumerate(azs):
    public_subnet = aws.ec2.Subnet(
        f"{app_name}-public-{i}",
        vpc_id=vpc.id,
        cidr_block=f"10.0.{i}.0/24",
        availability_zone=az,
        map_public_ip_on_launch=True,
        tags={"Name": f"{app_name}-public-{i}"},
    )
    public_subnets.append(public_subnet)
    
    private_subnet = aws.ec2.Subnet(
        f"{app_name}-private-{i}",
        vpc_id=vpc.id,
        cidr_block=f"10.0.{i + 100}.0/24",
        availability_zone=az,
        tags={"Name": f"{app_name}-private-{i}"},
    )
    private_subnets.append(private_subnet)


# Security Group
web_sg = aws.ec2.SecurityGroup(
    f"{app_name}-web-sg",
    vpc_id=vpc.id,
    description="Allow HTTP/HTTPS",
    ingress=[
        aws.ec2.SecurityGroupIngressArgs(
            protocol="tcp",
            from_port=80,
            to_port=80,
            cidr_blocks=["0.0.0.0/0"],
        ),
        aws.ec2.SecurityGroupIngressArgs(
            protocol="tcp",
            from_port=443,
            to_port=443,
            cidr_blocks=["0.0.0.0/0"],
        ),
    ],
    egress=[
        aws.ec2.SecurityGroupEgressArgs(
            protocol="-1",
            from_port=0,
            to_port=0,
            cidr_blocks=["0.0.0.0/0"],
        ),
    ],
)


# RDS PostgreSQL
db_subnet_group = aws.rds.SubnetGroup(
    f"{app_name}-db-subnet-group",
    subnet_ids=[s.id for s in private_subnets],
)

database = aws.rds.Instance(
    f"{app_name}-db",
    engine="postgres",
    engine_version="15",
    instance_class="db.t3.micro",
    allocated_storage=20,
    db_name="myapp",
    username="admin",
    password=config.require_secret("db_password"),
    db_subnet_group_name=db_subnet_group.name,
    vpc_security_group_ids=[web_sg.id],
    skip_final_snapshot=True if environment == "dev" else False,
)


# Exports
pulumi.export("vpc_id", vpc.id)
pulumi.export("db_endpoint", database.endpoint)
pulumi.export("public_subnet_ids", [s.id for s in public_subnets])
```

### ECS Fargate Service
```python
# infrastructure/aws/ecs.py
import pulumi
import pulumi_aws as aws
import json


def create_ecs_service(
    name: str,
    vpc_id: pulumi.Input[str],
    subnet_ids: pulumi.Input[list[str]],
    image: str,
    port: int = 80,
    cpu: int = 256,
    memory: int = 512,
) -> aws.ecs.Service:
    """Create ECS Fargate service."""
    
    # Cluster
    cluster = aws.ecs.Cluster(f"{name}-cluster")
    
    # Task execution role
    task_exec_role = aws.iam.Role(
        f"{name}-task-exec-role",
        assume_role_policy=json.dumps({
            "Version": "2012-10-17",
            "Statement": [{
                "Action": "sts:AssumeRole",
                "Principal": {"Service": "ecs-tasks.amazonaws.com"},
                "Effect": "Allow",
            }],
        }),
    )
    
    aws.iam.RolePolicyAttachment(
        f"{name}-task-exec-policy",
        role=task_exec_role.name,
        policy_arn="arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    )
    
    # Task definition
    task_def = aws.ecs.TaskDefinition(
        f"{name}-task",
        family=name,
        cpu=str(cpu),
        memory=str(memory),
        network_mode="awsvpc",
        requires_compatibilities=["FARGATE"],
        execution_role_arn=task_exec_role.arn,
        container_definitions=json.dumps([{
            "name": name,
            "image": image,
            "portMappings": [{
                "containerPort": port,
                "protocol": "tcp",
            }],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": f"/ecs/{name}",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs",
                },
            },
        }]),
    )
    
    # Security group
    sg = aws.ec2.SecurityGroup(
        f"{name}-sg",
        vpc_id=vpc_id,
        ingress=[
            aws.ec2.SecurityGroupIngressArgs(
                protocol="tcp",
                from_port=port,
                to_port=port,
                cidr_blocks=["0.0.0.0/0"],
            ),
        ],
        egress=[
            aws.ec2.SecurityGroupEgressArgs(
                protocol="-1",
                from_port=0,
                to_port=0,
                cidr_blocks=["0.0.0.0/0"],
            ),
        ],
    )
    
    # Service
    service = aws.ecs.Service(
        f"{name}-service",
        cluster=cluster.arn,
        task_definition=task_def.arn,
        desired_count=2,
        launch_type="FARGATE",
        network_configuration=aws.ecs.ServiceNetworkConfigurationArgs(
            subnets=subnet_ids,
            security_groups=[sg.id],
            assign_public_ip=True,
        ),
    )
    
    return service
```

---

## boto3 (AWS SDK)

### Modern Async Patterns
```python
import asyncio
import aioboto3
from typing import AsyncIterator
from dataclasses import dataclass


@dataclass
class EC2Instance:
    instance_id: str
    state: str
    instance_type: str
    public_ip: str | None


class AWSClient:
    """Modern AWS client with async support."""
    
    def __init__(self, region: str = "us-east-1"):
        self.region = region
        self.session = aioboto3.Session()
    
    async def list_instances(
        self,
        filters: list[dict] | None = None,
    ) -> AsyncIterator[EC2Instance]:
        """List EC2 instances with async pagination."""
        async with self.session.client("ec2", region_name=self.region) as ec2:
            paginator = ec2.get_paginator("describe_instances")
            
            async for page in paginator.paginate(Filters=filters or []):
                for reservation in page["Reservations"]:
                    for instance in reservation["Instances"]:
                        yield EC2Instance(
                            instance_id=instance["InstanceId"],
                            state=instance["State"]["Name"],
                            instance_type=instance["InstanceType"],
                            public_ip=instance.get("PublicIpAddress"),
                        )
    
    async def start_instances(self, instance_ids: list[str]) -> dict:
        """Start EC2 instances."""
        async with self.session.client("ec2", region_name=self.region) as ec2:
            return await ec2.start_instances(InstanceIds=instance_ids)
    
    async def stop_instances(self, instance_ids: list[str]) -> dict:
        """Stop EC2 instances."""
        async with self.session.client("ec2", region_name=self.region) as ec2:
            return await ec2.stop_instances(InstanceIds=instance_ids)
    
    async def upload_to_s3(
        self,
        bucket: str,
        key: str,
        data: bytes,
    ) -> dict:
        """Upload data to S3."""
        async with self.session.client("s3", region_name=self.region) as s3:
            return await s3.put_object(
                Bucket=bucket,
                Key=key,
                Body=data,
            )
    
    async def download_from_s3(
        self,
        bucket: str,
        key: str,
    ) -> bytes:
        """Download from S3."""
        async with self.session.client("s3", region_name=self.region) as s3:
            response = await s3.get_object(Bucket=bucket, Key=key)
            return await response["Body"].read()


# Usage
async def main():
    client = AWSClient()
    
    # List running instances
    async for instance in client.list_instances(
        filters=[{"Name": "instance-state-name", "Values": ["running"]}]
    ):
        print(f"{instance.instance_id}: {instance.instance_type}")
    
    # Upload to S3
    await client.upload_to_s3(
        bucket="my-bucket",
        key="data/file.json",
        data=b'{"key": "value"}',
    )


asyncio.run(main())
```

### Lambda Automation
```python
import boto3
import json
import zipfile
import io
from pathlib import Path


class LambdaManager:
    """Manage AWS Lambda functions."""
    
    def __init__(self, region: str = "us-east-1"):
        self.client = boto3.client("lambda", region_name=region)
        self.iam = boto3.client("iam", region_name=region)
    
    def create_deployment_package(
        self,
        source_dir: Path,
        handler_file: str = "handler.py",
    ) -> bytes:
        """Create Lambda deployment ZIP."""
        buffer = io.BytesIO()
        
        with zipfile.ZipFile(buffer, "w", zipfile.ZIP_DEFLATED) as zf:
            for file in source_dir.rglob("*.py"):
                arcname = file.relative_to(source_dir)
                zf.write(file, arcname)
        
        return buffer.getvalue()
    
    def deploy_function(
        self,
        name: str,
        source_dir: Path,
        handler: str = "handler.lambda_handler",
        runtime: str = "python3.11",
        memory: int = 256,
        timeout: int = 30,
        env_vars: dict | None = None,
    ) -> dict:
        """Deploy or update Lambda function."""
        zip_content = self.create_deployment_package(source_dir)
        
        try:
            # Update existing
            response = self.client.update_function_code(
                FunctionName=name,
                ZipFile=zip_content,
            )
            
            # Update configuration
            self.client.update_function_configuration(
                FunctionName=name,
                Runtime=runtime,
                Handler=handler,
                MemorySize=memory,
                Timeout=timeout,
                Environment={"Variables": env_vars or {}},
            )
        except self.client.exceptions.ResourceNotFoundException:
            # Create new
            role_arn = self._get_or_create_role(name)
            
            response = self.client.create_function(
                FunctionName=name,
                Runtime=runtime,
                Role=role_arn,
                Handler=handler,
                Code={"ZipFile": zip_content},
                MemorySize=memory,
                Timeout=timeout,
                Environment={"Variables": env_vars or {}},
            )
        
        return response
    
    def invoke(self, name: str, payload: dict) -> dict:
        """Invoke Lambda function."""
        response = self.client.invoke(
            FunctionName=name,
            InvocationType="RequestResponse",
            Payload=json.dumps(payload),
        )
        
        return json.loads(response["Payload"].read())
    
    def _get_or_create_role(self, name: str) -> str:
        """Get or create Lambda execution role."""
        role_name = f"{name}-lambda-role"
        
        try:
            role = self.iam.get_role(RoleName=role_name)
            return role["Role"]["Arn"]
        except self.iam.exceptions.NoSuchEntityException:
            pass
        
        assume_role_policy = {
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {"Service": "lambda.amazonaws.com"},
                "Action": "sts:AssumeRole",
            }],
        }
        
        role = self.iam.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=json.dumps(assume_role_policy),
        )
        
        self.iam.attach_role_policy(
            RoleName=role_name,
            PolicyArn="arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        )
        
        return role["Role"]["Arn"]
```

---

## Kubernetes Python Client

### Kubernetes Operations
```python
from kubernetes import client, config
from kubernetes.client.rest import ApiException
from dataclasses import dataclass
from typing import Iterator
import yaml


@dataclass
class Pod:
    name: str
    namespace: str
    status: str
    ip: str | None


class K8sClient:
    """Kubernetes operations client."""
    
    def __init__(self, context: str | None = None):
        try:
            config.load_incluster_config()
        except config.ConfigException:
            config.load_kube_config(context=context)
        
        self.core = client.CoreV1Api()
        self.apps = client.AppsV1Api()
    
    def list_pods(
        self,
        namespace: str = "default",
        label_selector: str | None = None,
    ) -> Iterator[Pod]:
        """List pods in namespace."""
        pods = self.core.list_namespaced_pod(
            namespace=namespace,
            label_selector=label_selector,
        )
        
        for pod in pods.items:
            yield Pod(
                name=pod.metadata.name,
                namespace=pod.metadata.namespace,
                status=pod.status.phase,
                ip=pod.status.pod_ip,
            )
    
    def create_deployment(
        self,
        name: str,
        namespace: str,
        image: str,
        replicas: int = 2,
        port: int = 80,
        env_vars: dict | None = None,
    ) -> client.V1Deployment:
        """Create or update deployment."""
        container = client.V1Container(
            name=name,
            image=image,
            ports=[client.V1ContainerPort(container_port=port)],
            env=[
                client.V1EnvVar(name=k, value=v)
                for k, v in (env_vars or {}).items()
            ],
            resources=client.V1ResourceRequirements(
                requests={"cpu": "100m", "memory": "128Mi"},
                limits={"cpu": "500m", "memory": "512Mi"},
            ),
        )
        
        template = client.V1PodTemplateSpec(
            metadata=client.V1ObjectMeta(labels={"app": name}),
            spec=client.V1PodSpec(containers=[container]),
        )
        
        spec = client.V1DeploymentSpec(
            replicas=replicas,
            selector=client.V1LabelSelector(
                match_labels={"app": name},
            ),
            template=template,
        )
        
        deployment = client.V1Deployment(
            api_version="apps/v1",
            kind="Deployment",
            metadata=client.V1ObjectMeta(name=name),
            spec=spec,
        )
        
        try:
            return self.apps.create_namespaced_deployment(
                namespace=namespace,
                body=deployment,
            )
        except ApiException as e:
            if e.status == 409:
                return self.apps.patch_namespaced_deployment(
                    name=name,
                    namespace=namespace,
                    body=deployment,
                )
            raise
    
    def scale_deployment(
        self,
        name: str,
        namespace: str,
        replicas: int,
    ) -> client.V1Deployment:
        """Scale deployment replicas."""
        return self.apps.patch_namespaced_deployment_scale(
            name=name,
            namespace=namespace,
            body={"spec": {"replicas": replicas}},
        )
    
    def create_service(
        self,
        name: str,
        namespace: str,
        port: int = 80,
        target_port: int = 80,
        service_type: str = "ClusterIP",
    ) -> client.V1Service:
        """Create service for deployment."""
        service = client.V1Service(
            api_version="v1",
            kind="Service",
            metadata=client.V1ObjectMeta(name=name),
            spec=client.V1ServiceSpec(
                selector={"app": name},
                ports=[
                    client.V1ServicePort(
                        port=port,
                        target_port=target_port,
                    ),
                ],
                type=service_type,
            ),
        )
        
        try:
            return self.core.create_namespaced_service(
                namespace=namespace,
                body=service,
            )
        except ApiException as e:
            if e.status == 409:
                return self.core.patch_namespaced_service(
                    name=name,
                    namespace=namespace,
                    body=service,
                )
            raise
    
    def apply_yaml(self, yaml_content: str, namespace: str = "default"):
        """Apply YAML manifest."""
        from kubernetes import utils
        
        documents = yaml.safe_load_all(yaml_content)
        
        for doc in documents:
            utils.create_from_dict(
                client.ApiClient(),
                doc,
                namespace=namespace,
            )


# Usage
k8s = K8sClient()

# Create deployment
k8s.create_deployment(
    name="myapp",
    namespace="default",
    image="myapp:latest",
    replicas=3,
    env_vars={"ENV": "production"},
)

# List pods
for pod in k8s.list_pods(label_selector="app=myapp"):
    print(f"{pod.name}: {pod.status}")
```

---

## Docker SDK

### Docker Operations
```python
import docker
from docker.models.containers import Container
from dataclasses import dataclass
from typing import Iterator
import io


@dataclass
class ContainerInfo:
    id: str
    name: str
    status: str
    image: str
    ports: dict


class DockerClient:
    """Docker operations client."""
    
    def __init__(self):
        self.client = docker.from_env()
    
    def build_image(
        self,
        path: str,
        tag: str,
        dockerfile: str = "Dockerfile",
        build_args: dict | None = None,
    ) -> str:
        """Build Docker image."""
        image, logs = self.client.images.build(
            path=path,
            tag=tag,
            dockerfile=dockerfile,
            buildargs=build_args or {},
            rm=True,
        )
        
        for log in logs:
            if "stream" in log:
                print(log["stream"].strip())
        
        return image.id
    
    def push_image(self, tag: str, registry: str | None = None) -> None:
        """Push image to registry."""
        if registry:
            full_tag = f"{registry}/{tag}"
            self.client.images.get(tag).tag(full_tag)
            tag = full_tag
        
        for line in self.client.images.push(tag, stream=True, decode=True):
            if "status" in line:
                print(f"{line['status']}: {line.get('progress', '')}")
    
    def run_container(
        self,
        image: str,
        name: str,
        ports: dict | None = None,
        env: dict | None = None,
        volumes: dict | None = None,
        detach: bool = True,
    ) -> Container:
        """Run container."""
        return self.client.containers.run(
            image=image,
            name=name,
            ports=ports,
            environment=env,
            volumes=volumes,
            detach=detach,
            remove=True,
        )
    
    def list_containers(
        self,
        all: bool = False,
        filters: dict | None = None,
    ) -> Iterator[ContainerInfo]:
        """List containers."""
        containers = self.client.containers.list(all=all, filters=filters)
        
        for container in containers:
            yield ContainerInfo(
                id=container.short_id,
                name=container.name,
                status=container.status,
                image=container.image.tags[0] if container.image.tags else "",
                ports=container.ports,
            )
    
    def stop_container(self, name: str, timeout: int = 10) -> None:
        """Stop container."""
        container = self.client.containers.get(name)
        container.stop(timeout=timeout)
    
    def exec_in_container(
        self,
        name: str,
        command: str | list[str],
    ) -> tuple[int, bytes]:
        """Execute command in container."""
        container = self.client.containers.get(name)
        result = container.exec_run(command)
        return result.exit_code, result.output
    
    def get_logs(
        self,
        name: str,
        tail: int = 100,
        follow: bool = False,
    ) -> Iterator[str]:
        """Get container logs."""
        container = self.client.containers.get(name)
        
        if follow:
            for line in container.logs(stream=True, follow=True, tail=tail):
                yield line.decode().strip()
        else:
            yield container.logs(tail=tail).decode()
    
    def cleanup(self, remove_volumes: bool = False) -> dict:
        """Cleanup unused resources."""
        return {
            "containers": self.client.containers.prune(),
            "images": self.client.images.prune(),
            "volumes": self.client.volumes.prune() if remove_volumes else None,
            "networks": self.client.networks.prune(),
        }


# Usage
docker_client = DockerClient()

# Build and run
docker_client.build_image(".", "myapp:latest")
container = docker_client.run_container(
    image="myapp:latest",
    name="myapp",
    ports={"8000/tcp": 8000},
    env={"ENV": "production"},
)

# Check logs
for log in docker_client.get_logs("myapp", tail=50):
    print(log)
```

---

## GitHub Actions Automation

### Workflow Management
```python
import httpx
from dataclasses import dataclass
from typing import Iterator
import base64


@dataclass
class WorkflowRun:
    id: int
    name: str
    status: str
    conclusion: str | None
    branch: str
    url: str


class GitHubActionsClient:
    """GitHub Actions automation client."""
    
    def __init__(self, token: str, owner: str, repo: str):
        self.token = token
        self.owner = owner
        self.repo = repo
        self.base_url = f"https://api.github.com/repos/{owner}/{repo}"
        self.headers = {
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        }
    
    def list_workflows(self) -> list[dict]:
        """List all workflows."""
        response = httpx.get(
            f"{self.base_url}/actions/workflows",
            headers=self.headers,
        )
        response.raise_for_status()
        return response.json()["workflows"]
    
    def trigger_workflow(
        self,
        workflow_id: str,
        ref: str = "main",
        inputs: dict | None = None,
    ) -> bool:
        """Trigger workflow dispatch."""
        response = httpx.post(
            f"{self.base_url}/actions/workflows/{workflow_id}/dispatches",
            headers=self.headers,
            json={
                "ref": ref,
                "inputs": inputs or {},
            },
        )
        return response.status_code == 204
    
    def list_runs(
        self,
        workflow_id: str | None = None,
        status: str | None = None,
        per_page: int = 30,
    ) -> Iterator[WorkflowRun]:
        """List workflow runs."""
        url = f"{self.base_url}/actions/runs"
        if workflow_id:
            url = f"{self.base_url}/actions/workflows/{workflow_id}/runs"
        
        params = {"per_page": per_page}
        if status:
            params["status"] = status
        
        response = httpx.get(url, headers=self.headers, params=params)
        response.raise_for_status()
        
        for run in response.json()["workflow_runs"]:
            yield WorkflowRun(
                id=run["id"],
                name=run["name"],
                status=run["status"],
                conclusion=run["conclusion"],
                branch=run["head_branch"],
                url=run["html_url"],
            )
    
    def cancel_run(self, run_id: int) -> bool:
        """Cancel a workflow run."""
        response = httpx.post(
            f"{self.base_url}/actions/runs/{run_id}/cancel",
            headers=self.headers,
        )
        return response.status_code == 202
    
    def get_run_logs(self, run_id: int) -> bytes:
        """Download run logs."""
        response = httpx.get(
            f"{self.base_url}/actions/runs/{run_id}/logs",
            headers=self.headers,
            follow_redirects=True,
        )
        response.raise_for_status()
        return response.content
    
    def update_secret(self, name: str, value: str) -> bool:
        """Update repository secret."""
        # Get public key
        key_response = httpx.get(
            f"{self.base_url}/actions/secrets/public-key",
            headers=self.headers,
        )
        key_response.raise_for_status()
        key_data = key_response.json()
        
        # Encrypt secret
        from nacl import encoding, public
        
        public_key = public.PublicKey(
            key_data["key"].encode(),
            encoding.Base64Encoder(),
        )
        sealed_box = public.SealedBox(public_key)
        encrypted = sealed_box.encrypt(value.encode())
        encrypted_value = base64.b64encode(encrypted).decode()
        
        # Update secret
        response = httpx.put(
            f"{self.base_url}/actions/secrets/{name}",
            headers=self.headers,
            json={
                "encrypted_value": encrypted_value,
                "key_id": key_data["key_id"],
            },
        )
        return response.status_code in (201, 204)


# Usage
gh = GitHubActionsClient(
    token="ghp_xxxx",
    owner="myorg",
    repo="myrepo",
)

# Trigger deployment
gh.trigger_workflow("deploy.yml", ref="main", inputs={"environment": "production"})

# Check status
for run in gh.list_runs(status="in_progress"):
    print(f"{run.name}: {run.status}")
```

---

## Monitoring with Prometheus

### Custom Metrics
```python
from prometheus_client import (
    Counter,
    Gauge,
    Histogram,
    Summary,
    start_http_server,
    generate_latest,
    REGISTRY,
)
import time
import functools


# Define metrics
REQUEST_COUNT = Counter(
    "app_requests_total",
    "Total requests",
    ["method", "endpoint", "status"],
)

REQUEST_LATENCY = Histogram(
    "app_request_latency_seconds",
    "Request latency",
    ["method", "endpoint"],
    buckets=[0.01, 0.05, 0.1, 0.5, 1.0, 5.0],
)

ACTIVE_CONNECTIONS = Gauge(
    "app_active_connections",
    "Active connections",
)

JOB_DURATION = Summary(
    "app_job_duration_seconds",
    "Job duration",
    ["job_name"],
)


# Decorator for timing
def track_time(metric: Histogram | Summary, labels: dict | None = None):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            start = time.time()
            try:
                return func(*args, **kwargs)
            finally:
                duration = time.time() - start
                if labels:
                    metric.labels(**labels).observe(duration)
                else:
                    metric.observe(duration)
        return wrapper
    return decorator


# Usage
@track_time(REQUEST_LATENCY, {"method": "GET", "endpoint": "/api/users"})
def get_users():
    # ... logic
    pass


# Start metrics server
def start_metrics_server(port: int = 8000):
    start_http_server(port)
    print(f"Metrics available at http://localhost:{port}/metrics")


# FastAPI integration
from fastapi import FastAPI, Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

app = FastAPI()


class MetricsMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start = time.time()
        
        ACTIVE_CONNECTIONS.inc()
        try:
            response = await call_next(request)
        finally:
            ACTIVE_CONNECTIONS.dec()
        
        duration = time.time() - start
        
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.url.path,
            status=response.status_code,
        ).inc()
        
        REQUEST_LATENCY.labels(
            method=request.method,
            endpoint=request.url.path,
        ).observe(duration)
        
        return response


app.add_middleware(MetricsMiddleware)


@app.get("/metrics")
def metrics():
    return Response(
        content=generate_latest(REGISTRY),
        media_type="text/plain",
    )
```

---

## Secrets Management

### HashiCorp Vault Integration
```python
import hvac
from dataclasses import dataclass
from typing import Any


@dataclass
class VaultClient:
    """HashiCorp Vault client."""
    
    url: str
    token: str | None = None
    role_id: str | None = None
    secret_id: str | None = None
    
    def __post_init__(self):
        self.client = hvac.Client(url=self.url)
        
        if self.token:
            self.client.token = self.token
        elif self.role_id and self.secret_id:
            self.client.auth.approle.login(
                role_id=self.role_id,
                secret_id=self.secret_id,
            )
    
    def read_secret(self, path: str, mount_point: str = "secret") -> dict:
        """Read secret from KV v2."""
        response = self.client.secrets.kv.v2.read_secret_version(
            path=path,
            mount_point=mount_point,
        )
        return response["data"]["data"]
    
    def write_secret(
        self,
        path: str,
        data: dict,
        mount_point: str = "secret",
    ) -> None:
        """Write secret to KV v2."""
        self.client.secrets.kv.v2.create_or_update_secret(
            path=path,
            secret=data,
            mount_point=mount_point,
        )
    
    def delete_secret(self, path: str, mount_point: str = "secret") -> None:
        """Delete secret."""
        self.client.secrets.kv.v2.delete_metadata_and_all_versions(
            path=path,
            mount_point=mount_point,
        )
    
    def get_database_credentials(self, role: str) -> dict:
        """Get dynamic database credentials."""
        response = self.client.secrets.database.generate_credentials(
            name=role,
        )
        return {
            "username": response["data"]["username"],
            "password": response["data"]["password"],
            "ttl": response["lease_duration"],
        }


# Usage
vault = VaultClient(
    url="https://vault.example.com:8200",
    role_id="your-role-id",
    secret_id="your-secret-id",
)

# Read secrets
db_config = vault.read_secret("database/production")
print(f"Host: {db_config['host']}")

# Get dynamic credentials
creds = vault.get_database_credentials("readonly")
print(f"Username: {creds['username']}")
```

---

## Best Practices Checklist

- [ ] Use Pulumi for Python-native IaC
- [ ] Use async patterns with boto3 (aioboto3)
- [ ] Use Kubernetes Python client for K8s ops
- [ ] Use Docker SDK for container automation
- [ ] Automate GitHub Actions workflows
- [ ] Export Prometheus metrics
- [ ] Use HashiCorp Vault for secrets
- [ ] Implement idempotent operations
- [ ] Log all operations with context
- [ ] Test automation scripts thoroughly

---

**References:**
- [Pulumi Python](https://www.pulumi.com/docs/languages-sdks/python/)
- [boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/)
- [Kubernetes Python Client](https://github.com/kubernetes-client/python)
- [Docker SDK for Python](https://docker-py.readthedocs.io/)
- [prometheus-client](https://prometheus.github.io/client_python/)
