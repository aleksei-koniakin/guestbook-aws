@file:Suppress("ClassName")

package src

import jetbrains.buildServer.configs.kotlin.*
import jetbrains.buildServer.configs.kotlin.buildSteps.ScriptBuildStep
import jetbrains.buildServer.configs.kotlin.buildSteps.script

abstract class DeployBuildType(init: DeployBuildType.() -> Unit) : BuildType() {
    init {
        enablePersonalBuilds = false
        type = Type.DEPLOYMENT
        maxRunningBuilds = 1

        linux()

        dependencies {
          //we use this image as to run all deployments
          artifacts(Build_DeployImage) {
            buildRule = lastSuccessful()
            artifactRules = ".teamcity/** => junk"
          }
        }

        steps {
          script {
            name = "info and debug"
            scriptContent = """#!/bin/bash
              |echo "Just in case you are setting it up, please check ${Build_DeployImage.id} for the Terraform image"   
              |""".trimMargin()
          }
        }

        spaceDckerLoginFeature()

        vcs {
            root(DslContext.settingsRoot, "+:tf=>tf", "+:infrastructure=>infrastructure", "+:database=>database")
            checkoutMode = CheckoutMode.ON_AGENT
        }

        params {
            password("env.AWS_ACCESS_KEY_ID", AwsConnection.accessKeyId, display = ParameterDisplay.HIDDEN, readOnly = true)
            password("env.AWS_SECRET_ACCESS_KEY", AwsConnection.secretAccessKey, display = ParameterDisplay.HIDDEN, readOnly = true)
            text("env.AWS_DEFAULT_REGION", AwsConnection.region, display = ParameterDisplay.HIDDEN, readOnly = true)
        }

        init()
    }
}

fun DeployBuildType.terraformScript(workdir: String, text: String) {
  steps {
    script {
      name = "deploy"
      workingDir = workdir
      scriptContent = """
                set -e -u
                
                aws_credentials=${'$'}(aws sts assume-role \
                                           --role-arn ${AwsConnection.assumeRoleArn} \
                                           --role-session-name "TeamCity-%build.number%")
                
                export AWS_ACCESS_KEY_ID=${'$'}(echo ${'$'}aws_credentials|jq '.Credentials.AccessKeyId'|tr -d '"')
                export AWS_SECRET_ACCESS_KEY=${'$'}(echo ${'$'}aws_credentials|jq '.Credentials.SecretAccessKey'|tr -d '"')
                export AWS_SESSION_TOKEN=${'$'}(echo ${'$'}aws_credentials|jq '.Credentials.SessionToken'|tr -d '"')
                
                terraform -version
                
                terraform init
                
                $text
            """.trimIndent()
      dockerImage = spaceImageTerraform
      dockerPull = true
      dockerImagePlatform = ScriptBuildStep.ImagePlatform.Linux
      dockerRunParameters = "--rm -v /var/run/docker.sock:/var/run/docker.sock "
    }
  }
}
