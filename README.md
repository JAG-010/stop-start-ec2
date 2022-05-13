# Start and Stop EC2 instances using Lambda and Eventbridge
Terraform code to Start and Stop EC2 instances automatically using Lambda and Eventbridge services


### Step 1: Clone repo

```
git clone git@github.com:JAG-010/stop-start-ec2.git

cd stop-start-ec2
```

### Step 2: Edit EC2 instance ID on python scripts

`cd files`

open `start-ec2.py` and `stop-ec2.py` in you preffered editor

update line `#2` with region and line `#3` with EC2 instance id's, make sure list instace ID's as a python list type. 

```
import boto3
region = 'us-east-2'
instances = ['i-04e9e4f06beebcc8c','i-723e4f4f06uiehdr5a']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.stop_instances(InstanceIds=instances)
    print('stopped your instances: ' + str(instances))
```

### Step 3: Let's use terraform to zip this files for lambda

> NOTE: This step will work only in linux/macos. For windows, zip the file manually.
> 
> make sure you are in `files` folder

```
terraform init 

terraform apply -auto-approve
```

two zip files will be created.

```
-rwxrwxrwx 1 jagan jagan  352 May 12 22:49 start-ec2.zip

-rwxrwxrwx 1 jagan jagan  349 May 12 22:49 stop-ec2.zip
```

### Step 4: Apply the main.tf file

`cd ..`

```
terraform init

terraform apply

terraform apply
```
