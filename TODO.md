TODOs
=========

## cloud infra

- ssl certificate / https config
- dns 
- dns based listener conditions for per-version endpoints

- configuration from SSM for per-env config settings distinct from stack params
  - auto-update of stack from ssm change with ssm -> event -> sns -> lambda -> stack update
  - ssm configs are potentially a good choice for:
    - load balancer weights,
    - ami / image versions, 

- ssh access process

## app infra

- splunk
- apache

## app

- config settings & files

