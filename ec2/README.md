# Basic VPC and EC2 setup for AWS demos

This terraform config will create a VPN (and associated routes,
security groups and rules) and three EC2 instances.

Valid AWS admin credentials are needed, either via the environment
or `~/.aws/` configuration

A terraform wrapper script `tf.sh` is provided to create an ssh key
and set various input variables.

To create:

```
./tf.sh plan # check what's going to happen
./tf.sh apply
```

To fetch the public IP addresses of the EC2 instances:

```
./tf.sh output
```

To ssh to an instance:

```
ssh -i ./demo_ssh_key ubuntu@<public ip address>
```

To destroy all config:

```
./tf.sh destroy
```

