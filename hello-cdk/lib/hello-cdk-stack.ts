import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as s3 from 'aws-cdk-lib/aws-s3';

export class HelloCdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // An S3 bucket provisioned by this stack.
    const bucket = new s3.Bucket(this, 'HelloCdkBucket', {
      versioned: true,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      autoDeleteObjects: true,
    });

    // Export the bucket name as a stack output.
    new cdk.CfnOutput(this, 'BucketNameOutput', {
      value: bucket.bucketName,
      description: 'Name of the S3 bucket provisioned by HelloCdkStack',
    });

    // Export the AWS region as a stack output (useful for dynamic provisioning).
    new cdk.CfnOutput(this, 'RegionOutput', {
      value: cdk.Aws.REGION,
      description: 'AWS region of the stack',
    });
  }
}
