Guestbook Terraform
===================

Settings up AWS Accounts
========================

Follow the https://youtrack.jetbrains.com/articles/ITKB-A-3/AWS-Access(SSO)
and configure AWS CLI locally.

Log in to the AWS Management console and
find the Amazon Account ID. It will be needed
later to create the configuration profile. 

You may use the ... icon from your Google Account 
adn select AWS SSO to proceed.

Add the following lines to the `~/.aws/config`

```
[profile guestbook]
sso_start_url = https://jetbrains.awsapps.com/start
sso_region = eu-west-1
sso_account_id = YOUR ACCOUNT ID
sso_role_name = AdministratorAccess
region = us-west-2
```

Run `export AWS_PROFILE=guestbook` in the console. Next, run `aws sso login`.

Now you are ready to use IDE or `terraform` to run the deployment scripts.


RDS Database Access
===================

We use IAM credentials to access the database, to make it work
we need to set up the IAM in the database, for that, see the 

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.DBAccounts.html

Use the AWS Toolkit plugin in the IDE to connect to the database, 
using the AWS security manager for the password. For that, find the RDS 
in the AWS Explorer, click Connect With Secrets Manager... action, select the secret
named `guestbook/db/master_json`. Use `postgres` database name in the settings.

execute in DDL
```postgresql
CREATE USER iamuser WITH LOGIN; 
GRANT rds_iam TO iamuser;
GRANT rds_superuser to iamuser;
```

NOTE. That has to be a unique user, using existing user will ruin the password login

Now you can configure the database to use the IAM credentials with 
 - username `jetbrains`
 - database `postgres`


Structure
=========

The Terraform configuration is split between multiple folders. There are three layers:

**Infrastructure**

This is shared between all deployments. We're only using a single RDS server that is
shared between all deployments. And all TeamCity settings live here.

**Staging-env and prod-env**

These are the immediate environment for a single deployment: the S3 bucket for the 
pictures, the queue, the load balancer and the DNS settings.
    
**Staging-app and prod-app**

These are the actual application (the ECS services)

There is no real difference between the `staging` versions and the `prod` versions. 
The `prod` version is just hardcoded to run at http://guestbook.teamcity.com

When running terraform init, supply backend configuration with the `-backend-config`
CLI option:

    cd tf/app/
    terraform init -backend-config=../backend.hcl

Spinning everything up
----------------------

If everything is down, to get started, you'll need to do a couple things.

Shared Infrastructure
---------------------

#. Ensure you have the AWS CLI configured with AdminAccess, and the region you
   want for this instance. If you use a profile, set the `AWS_PROFILE` 
   environment variable. All HashiCorp tools obey it.
   See above for generic comments on AWS credentials
#. Make sure the bucket name contains the right year, i.e. "reinvent<YEAR>-guestbook-tfstate"
#. Comment out the `terraform` section in `infrastructure/main.tf`.
#. In the `infrastrcuture` folder, run `terraform init && terraform apply`.
#. Uncomment the section you commented earlier.
#. Now run `terraform init -backend-config=../backend.hcl`
#. At this point `terraform apply` for the infrastructure should work.


Creating application instances
------------------------------

The idea behind the `app-instance` and `app-env` modules is that multiple instances can be created.

[Terraform workspaces](https://www.terraform.io/docs/state/workspaces.html) are used to create 
multiple staging deployments. Please **do not use workspaces for the prod deployment**.

The default workspace will deploy to http://staging.guestbook.teamcity.com, every other workspace
will deploy to http://<workspace-name>.guestbook.teamcity.com. 

Make sure that you select the same workspace for both `staging-env` and `staging-app` when updating.

For everything except the `default` workspace, you need to **set the correct subnet**. See the 
[subnet Google Sheet](https://docs.google.com/spreadsheets/d/1lxYOIV9kh2PNmwxRPluAhLmcnBPMvH89BdO2W8TcrFU/edit#gid=0)
please create a new /24 for each new staging deployment. Up to 10.0.100.0 should be free.

1. Make sure you can connect to the database. This means either running from within the VPC, or 
   using the bastion host (see the 'Connecting to the database' section)
   
2. Go to the `staging-env` folder.

3. If applicable, (create and) activate the appropriate workspace
   
4. Run `terraform apply`. If you're not running in the `default` workspace, make sure you provide 
   the subnet in [a Terraform variable](https://www.terraform.io/docs/configuration/variables.html). 
   See `staging-env/vars.tf`

5. If your environment is new, open a connection to the newly created database, and run `schema.sql`.
   Afterward, re-run `terraform apply` to ensure the postgres rights are set up correctly.
   
6. Navigate to `staging-app`, and **activate a workspace with the same name**.

7. Run `terraform apply`

Connecting to the Database
--------------------------

For all environments, if you're running Terraform from outside the VPC,
you'll need to set up a tunnel toward the database before running `terraform apply`.

Using IDEA (or any IDEA platform IDE), follow the instructions below, but set
`Local Port` on the SSH/SSL page to any free port. Be sure to have IDEA connect
to the database (its name should be bold) before running Terraform. 

Alternatively, run:

    ssh -N -L <localport>:db.guestbook.teamcity.com:5432 jetbrains@bastion.guestbook.teamcity.com
    
At this point 
[configure Terraform's input variables](https://www.terraform.io/docs/configuration/variables.html)
to set `database_host` to `localhost` and `database_port` to the port you've 
selected.

When creating additional staging environments, be sure to pick a free subnet.

After running Terraform to create a new instance, you still need to initiate the database
use an appropriately configured database tool to run `database/schema.sql` in
the database created for your instance. 

After this, ensure that the PostgreSQL role (user) configured for the instance
has rights to the tables created by running `schema.sql`.  You can do this by
re-running `terraform apply`.

Using the Bastion Host
----------------------

You need to use the bastion host, and get the password from secrets manager.

To get access to the bastion host, add your public key to the
`jetbrains-guestbook-bastion-keys` bucket in the OpenSSH authorized_keys
format. 

Get the database's password using the AWS CLI (you need 
`secretsmanager:GetSecretValue` IAM permissions for this):

    aws secretsmanager get-secret-value --secret-id=guestbook/db/master

At that point connect using IntelliJ IDEA (or anything else with DataGrip
integration):

    Host:           db.guestbook.teamcity.com
    Username:       jetbrains
    Password:       <what you got from the AWS CLI>
    Port:           5432

And on the SSH/SSL page, enable 'Use SSH tunnel':

    Proxy Host:     bastion.guestbook.teamcity.com
    Proxy User:     jetbrains

Use the private key belonging to the public key you put in the S3 bucket 
to authenticate.
