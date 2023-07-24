#!/usr/bin/env bash

terraform taint aws_instance.rd
terraform apply -auto-approve
