#!/bin/bash

cd ansible
ansible-playbook -i inventory playbook.yml --ask-become-pass | tee ansible_output.log

echo "Completed"
