# Exercism Config

![Tests](https://github.com/exercism/config/workflows/Tests/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/513edbd6599a2de3218d/maintainability)](https://codeclimate.com/github/exercism/config/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/513edbd6599a2de3218d/test_coverage)](https://codeclimate.com/github/exercism/config/test_coverage)
[![Gem Version](https://badge.fury.io/rb/exercism-config.svg)](https://badge.fury.io/rb/exercism-config)

## Usage

This gem provides you with the following config, secrets and helper methods:

```ruby
# Config

Exercism.config.anycable_redis_url
Exercism.config.anycable_rpc_host
Exercism.config.aws_submissions_bucket
Exercism.config.aws_tooling_jobs_bucket
Exercism.config.dynamodb_tooling_jobs_table
Exercism.config.dynamodb_tooling_language_groups_table
Exercism.config.mysql_master_endpoint
Exercism.config.mysql_port
Exercism.config.spi_url
Exercism.config.tooling_orchestrator_url
Exercism.config.language_server_url
Exercism.config.opensearch_host
Exercism.config.paypal_api_url

# Secrets
Exercism.secrets.github_access_token
Exercism.secrets.github_omniauth_app_id
Exercism.secrets.github_omniauth_app_secret
Exercism.secrets.github_webhooks_secret
Exercism.secrets.github_graphql_readonly_access_token
Exercism.secrets.hcaptcha_site_key
Exercism.secrets.hcaptcha_secret
Exercism.secrets.website_secret_key_base
Exercism.secrets.stripe_secret_key
Exercism.secrets.stripe_publishable_key
Exercism.secrets.stripe_endpoint_secret
Exercism.secrets.stripe_recurring_product_id
Exercism.secrets.stripe_premium_product_id
Exercism.secrets.stripe_premium_monthly_price_id
Exercism.secrets.stripe_premium_yearly_price_id
Exercism.secrets.stripe_premium_lifetime_price_id
Exercism.secrets.slack_api_token
Exercism.secrets.google_api_key
Exercism.secrets.discourse_oauth_secret
Exercism.secrets.discourse_api_key
Exercism.secrets.recaptcha_site_key
Exercism.secrets.recaptcha_secret_key
Exercism.secrets.coinbase_webhooks_secret
Exercism.secrets.paypal_webhook_id
Exercism.secrets.paypal_client_id
Exercism.secrets.paypal_client_secret
Exercism.secrets.paypal_donation_product_name
Exercism.secrets.paypal_donation_hosted_button_id
Exercism.secrets.paypal_premium_product_name
Exercism.secrets.paypal_premium_monthly_plan_id
Exercism.secrets.paypal_premium_yearly_plan_id
Exercism.secrets.paypal_lifetime_insiders_hosted_button_id
Exercism.secrets.chatgpt_access_token
Exercism.secrets.sparkpost_api_key
Exercism.secrets.openai_api_key

Exercism.secrets.transactional_smtp_username
Exercism.secrets.transactional_smtp_password
Exercism.secrets.transactional_smtp_address
Exercism.secrets.transactional_smtp_port
Exercism.secrets.transactional_smtp_authentication

Exercism.secrets.bulk_smtp_username
Exercism.secrets.bulk_smtp_password
Exercism.secrets.bulk_smtp_address
Exercism.secrets.bulk_smtp_port
Exercism.secrets.bulk_smtp_authentication

# Helper methods (create new clients)
Exercism.dynamodb_client
Exercism.s3_client
Exercism.ecr_client
Exercism.octokit_client
Exercism.opensearch_client
Exercism.discourse_client
Exercism.openai_client
```

## Explanation

When terraform creates Exercism's infrastructure, it writes endpoints and DNS entries to DynamoDB.
This gem allows you to trivially retrieve that data.

When running on AWS, simply ensure the machine has read-access to the relevant table (currently hardcoded to `config`).

## Local AWS

This requires a local version of AWS to work.
We use localstack for this.
To start localstack use the following command:

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
