# Exercism Config

When terraform creates Exercism's infrastructure, it writes endpoints and DNS entries to DynamoDB.
This gem allows you to trivially retrieve that data.

When running on AWS, simply ensure the machine has read-access to the relevant table (currently hardcoded to `config`).
On a local machine specify the AWS_PROFILE environment variable with the relevant profile stored in your `.aws/credentials`.

## Usage

Simply include this gem in your Gemfile, require it, and then refer to the object:

```ruby
# Gemfile
gem 'exercism_config'

# Your code
require 'exercism_config'
ExercismConfig.config.webservers_alb_dns_name
```

To print out all the config from the command-line, you can run:

```bash
AWS_PROFILE=exercism_terraform ./bin/run
```
