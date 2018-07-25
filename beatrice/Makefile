
build: up

up:
	cd ../vagrant_k8s && VM_EXTRA_MOUNT=../beatrice vagrant up
	cd ../vagrant_db && VM_EXTRA_MOUNT=../beatrice vagrant up

halt:
	cd ../vagrant_db && VM_EXTRA_MOUNT=../beatrice vagrant halt
	cd ../vagrant_k8s && VM_EXTRA_MOUNT=../beatrice vagrant halt

reprovision:
	cd ../vagrant_db && VM_EXTRA_MOUNT=../beatrice vagrant up --provision
	cd ../vagrant_k8s && VM_EXTRA_MOUNT=../beatrice vagrant up --provision

destroy:
	cd ../vagrant_db && VM_EXTRA_MOUNT=../beatrice vagrant destroy -f
	cd ../vagrant_k8s && VM_EXTRA_MOUNT=../beatrice vagrant destroy -f

harness: build
	cd harness && make screen
	cd harness && make kill

.PHONY: build up halt reprovision destroy harness
