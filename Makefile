REGION="us-west-2" 

do: check-templates cook-parameters apply-templates

check-templates:
	for tpl in $${tpl:-asg alb} ; do \
	aws cloudformation --region $(REGION) validate-template --template-body file://$${tpl}.json ; \
	done

cook-parameters:
	cp asg-parameters.json cooked-asg-parameters.json && \
	cp alb-parameters.json cooked-alb-parameters.json && \
	vpcid="$$(aws ec2 describe-vpcs --region $(REGION)  --filters Name=tag:Name,Values=legacy-prod --query Vpcs[0].[VpcId] --output text | sed -e 's/[[:space:]]\{1,\}$$//g' )"; \
	subnetids="$$(aws ec2 describe-subnets --region $(REGION) --filters Name=vpc-id,Values=$${vpcid} --query Subnets[*].SubnetId --output text| sed -e 's/[[:space:]]\{1,\}subnet/,subnet/g' | sed -e 's/[[:space:]]\{1,\}$$//g' )"; \
	sed -i "" -e "s/SUBNETS/$${subnetids}/g" -e "s/VPCID/$${vpcid}/g"  -e 's/[[:space:]]\{1,\}$$//g' cooked-asg-parameters.json cooked-alb-parameters.json

apply-templates:
	for tpl in $${tpl:-asg alb} ; do \
		if aws cloudformation --region $(REGION) describe-stacks --stack-name test-$${tpl}  2>&1 | grep -iF 'does not exist' ; then \
			aws cloudformation --region $(REGION) create-stack --template-body file://$${tpl}.json --stack-name test-$${tpl} --parameters file://cooked-$${tpl}-parameters.json --capabilities CAPABILITY_IAM ;  \
		else \
			aws cloudformation update-stack --region $(REGION) --stack-name test-$${tpl} --parameters file://cooked-$${tpl}-parameters.json --capabilities CAPABILITY_IAM  --template-body file://$${tpl}.json; \
		fi;\
	done
