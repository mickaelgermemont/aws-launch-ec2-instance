# pip install awscli

# https://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-launch.html#launching-instances
# t2.micro
# ami-afd15ed0

export securityGroupName="my-sg--from-cli"
# https://aws.amazon.com/amazon-linux-ami/
# https://aws.amazon.com/amazon-linux-ami/instance-type-matrix/
export amiId="ami-97785bed"
export myIp="11.22.333.40/32"

# ec2-launch-user
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="yyy"

# ec2-launch-group

# aws ec2 describe-regions

# need jq tool in order to parse json ouput

#
# need permission ec2:CreateSecurityGroup, ec2:DescribeSecurityGroups, ec2:AuthorizeSecurityGroupIngress, ec2:DescribeRegions, ec2:DeleteSecurityGroup, ec2:RunInstances, ec2:TerminateInstances, ec2:CreateKeyPair, ec2:DescribeInstances, ec2:DescribeInstanceStatus
#
# see sample policy.txt



# https://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-keypairs.html
aws ec2 create-key-pair --key-name MyKeyPair10 --query 'KeyMaterial' --output text > MyKeyPair10.pem
chmod 400 MyKeyPair10.pem



export groupId=`aws ec2 create-security-group --group-name $securityGroupName --description "My security group"  | jq -r '.GroupId'`
echo $groupId
# aws ec2 describe-security-groups --group-names $securityGroupName

# The following command adds a rule for SSH to the security group
aws ec2 authorize-security-group-ingress --group-name $securityGroupName --protocol tcp --port 22 --cidr $myIp
# aws ec2 describe-security-groups --group-names $securityGroupName

# if you want to delete your security group
# aws ec2 delete-security-group --group-id $groupId
# aws ec2 delete-security-group --group-name $securityGroupName

aws ec2 run-instances --key-name MyKeyPair10 --image-id $amiId --count 1 --instance-type t2.micro --security-group-ids $groupId --block-device-mappings "[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"VolumeSize\":30,\"DeleteOnTermination\":false,\"VolumeType\":\"standard\"}}]" > createdEc2Instance.json
export instanceId=`cat createdEc2Instance.json | jq -r '.Instances[0].InstanceId'`
echo $instanceId
# aws ec2 terminate-instances --instance-ids $(instanceId)

# aws ec2 describe-instances --filters "Name=image-id,Values=ami-x0123456,ami-y0123456,ami-z0123456"
aws ec2 describe-instance-status --instance-ids $instanceId

aws ec2 describe-instances --instance-ids $instanceId > describeInstance.json
export publicDnsName=`cat describeInstance.json | jq -r '.Reservations[0].Instances[0].PublicDnsName'`
echo $publicDnsName

ssh -i MyKeyPair10.pem ec2-user@$publicDnsName
