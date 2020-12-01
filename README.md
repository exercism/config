# Exercism Config

![Tests](https://github.com/exercism/config/workflows/Tests/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/513edbd6599a2de3218d/maintainability)](https://codeclimate.com/github/exercism/config/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/513edbd6599a2de3218d/test_coverage)](https://codeclimate.com/github/exercism/config/test_coverage)
[![Gem Version](https://badge.fury.io/rb/exercism-config.svg)](https://badge.fury.io/rb/exercism-config)

When terraform creates Exercism's infrastructure, it writes endpoints and DNS entries to DynamoDB.
This gem allows you to trivially retrieve that data.

When running on AWS, simply ensure the machine has read-access to the relevant table (currently hardcoded to `config`).

## Local AWS

This requires a local version of AWS to work.
We use localstack for this.
If you use the development-environment this will be handled for you.
If not, to start localstack use the following:

```bash
docker run -dp 3042:8080 -p 3040:4566 -p 3041:4566 localstack/localstack
```

## Usage

Simply include this gem in your Gemfile, require it, and then refer to the object:

```ruby
# Gemfile
gem 'exercism-config'

# Your code
require 'exercism-config'
ExercismConfig.config.webservers_alb_dns_name
```
