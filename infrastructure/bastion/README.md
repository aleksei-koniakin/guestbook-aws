EC2 Bastion Host
================

This packer configuration serves to create an EC2 instance that behaves
as follows: 

 - The idea is to have a bastion host that'll let anyone with a valid private
   key get a connection to proxy TCP connections (and nothing else).


 - It look in the S3 bucket configured in the `/etc/keybucket` file, will give
   anyone authenticating with user `jetbrains` and a valid private key SSH access.
   
 
 - The server will not, however, give these users shell access.


Building the image
------------------

Use [HashiCorp Packer](https://www.packer.io):

    packer build packer.json

Just ensure that you have the AWS CLI correctly configured before you do this. 
 
How to use
----------

Create an S3 bucket, and ensure your bastion host will be able to read from it.
Sample IAM permissions: 

    data "aws_iam_policy_document" "bastion_host" {
      statement {
        actions = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
    
        resources = [
          "${aws_s3_bucket.bastion_keys.arn}",
          "${aws_s3_bucket.bastion_keys.arn}/*",
        ]
      }
    }

In the S3 bucket, have files that contain public keys, and nothing else:

    File: example.pub
    ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAoA<snip>SHtQ== name-of-my-key

Make sure the EC2 box comes up, and include something like this in the userdata:

    echo "s3://<bucketname>/" >> /etc/keybucket && chmod 644 /etc/keybucket
