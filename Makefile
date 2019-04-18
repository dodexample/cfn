REGION="us-west-2" 
TEST_STACK_NAME="asg-test"

do: check-templates cook-parameters apply-templates

check-templates:
	aws cloudformation --region $(REGION) validate-template --template-body file://asg.json

cook-parameters:
	cp test-parameters.json cooked-test-parameters.json && sed -i "" -e "s/SUBNETS/$$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$$(aws ec2 describe-vpcs --region us-west-2 --filters Name=tag:Name,Values=legacy-prod --query Vpcs[0].[VpcId] --output text) --region us-west-2 --query Subnets[*].SubnetId --output text | sed -e 's/[[:space:]]\{1,\}subnet/,subnet/g' -e 's/[[:space:]]\{1,\}$$//g')/" cooked-test-parameters.json

apply-templates:
	if aws cloudformation --region $(REGION) describe-stacks --stack-name $(TEST_STACK_NAME) 2>&1 | grep -iF 'does not exist' ; then \
		aws cloudformation --region $(REGION) create-stack --template-body file://asg.json --stack-name $(TEST_STACK_NAME) --parameters file://cooked-test-parameters.json --capabilities CAPABILITY_IAM ;  \
	else \
		aws cloudformation update-stack ; \
	fi
