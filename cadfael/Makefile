
build: up

up:
	cd ../ec2 && ./tf.sh apply

env:
	cd ../ec2 && ./tf.sh env

destroy:
	cd ../ec2 && ./tf.sh destroy -force

harness:
	$(foreach v,$(shell cd ../ec2 && ./tf.sh env), $(eval export $v))
	cd harness && make screen
	cd harness && make kill

.PHONY: build up env reprovision destroy harness
