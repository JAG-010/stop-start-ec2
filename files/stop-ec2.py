import boto3
region = 'us-east-2'
instances = ['i-04e9e4f06beebcc8c']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.stop_instances(InstanceIds=instances)
    print('stopped your instances: ' + str(instances))