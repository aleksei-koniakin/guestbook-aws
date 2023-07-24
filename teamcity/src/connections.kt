package src

import jetbrains.buildServer.configs.kotlin.ProjectFeatures
import jetbrains.buildServer.configs.kotlin.projectFeatures.dockerECRRegistry
import jetbrains.buildServer.configs.kotlin.projectFeatures.dockerRegistry
import jetbrains.buildServer.configs.kotlin.projectFeatures.spaceConnection

object AwsConnection {
    const val accountId = "920267453440"
    const val region = "us-west-2"

    /// these credentials are managed via Terraform, see tf/infrastructure/users-deploy.tf
    /// create access keys via AWS console, and use them here, look for the
    /// "deploy-user-sts" user
    /// just call `terraform output` in the `tf/infrastructure` to get these parameters
    const val accessKeyId = "AKIA5MRBW6QADK6G4SHL"
    const val secretAccessKey = "credentialsJSON:54b77752-1b4d-4fb7-9e0a-3cc8ae575ca5"

    const val assumeRoleArn = "arn:aws:iam::${accountId}:role/TeamCityDeployRole"

    private const val ecrRegistryBase = "$accountId.dkr.ecr.us-west-2.amazonaws.com"
    const val ecrFrontendName = "$ecrRegistryBase/guestbook-frontend:%build.number%"
    const val ecrBackendName = "$ecrRegistryBase/guestbook-backend:%build.number%"

    const val cloudAgentSubnetId = "subnet-00aabb07d6208878d"
    const val cloudAgentSecurityGroups = "sg-0981408bbf9c14d6b"
}

object SpaceConnection {
    const val clientId = "6a972166-c84c-4bca-a4ae-b2effe0ae0a9"
    const val clientSecret = "credentialsJSON:38ca9b0a-0561-40b6-8492-b68d9b169b55"
    const val serverUrl = "https://guestbook.jetbrains.space/"
    const val spaceRegistryUrl = "guestbook.registry.jetbrains.space/p/gb/containers"
}

fun ProjectFeatures.dockerEcr() {
    dockerECRRegistry {
        id = ecrRegistryIdForTeamCity
        displayName = "Amazon ECR"
        registryId = AwsConnection.accountId

        credentialsProvider = accessKey {
            accessKeyId = AwsConnection.accessKeyId
            secretAccessKey = AwsConnection.secretAccessKey
        }
        regionCode = AwsConnection.region
        credentialsType = tempCredentials {
            iamRoleArn = AwsConnection.assumeRoleArn
        }
    }
}

fun ProjectFeatures.dockerSpace() {
    dockerRegistry {
        id = spaceRegistryIdForTeamCity
        url = SpaceConnection.spaceRegistryUrl
        name = "Space Docker Registry"
        userName = SpaceConnection.clientId
        password = SpaceConnection.clientSecret
    }
}

fun ProjectFeatures.cloudImage() {
    feature {
                type = "CloudImage"
                id = "PROJECT_EXT_10"
                param("agent_pool_id", "-2")
                param("amazon-id", "ami-054328a36911618f1")
                param("ebs-optimized", "false")
                param("image-instances-limit", "3")
                param("image-name-prefix", "Linux-Medium")
                param("instance-type", "c5d.2xlarge")
                param("key-pair-name", "tc-agents-prod")
                param("profileId", "amazon-1")
                param("security-group-ids", AwsConnection.cloudAgentSecurityGroups)
                param("source-id", "Linux-Medium")
                param("subnet-id", AwsConnection.cloudAgentSubnetId)
                param("use-spot-instances", "false")
                param("user-tags", "<custom-profile>=<demo-teamcity-com>")
            }
    feature {
                type = "CloudImage"
                id = "PROJECT_EXT_12"
                param("amazon-id", "ami-0a3d09e49d0e8b93b")
                param("ebs-optimized", "false")
                param("image-instances-limit", "3")
                param("image-name-prefix", "Windows")
                param("instance-type", "c5d.xlarge")
                param("key-pair-name", "tc-agents-prod")
                param("profileId", "amazon-1")
                param("security-group-ids", AwsConnection.cloudAgentSecurityGroups)
                param("source-id", "Windows")
                param("subnet-id", AwsConnection.cloudAgentSubnetId)
                param("use-spot-instances", "false")
                param("user-tags", "<custom-profile>=<demo-teamcity-com>")
            }
    feature {
                type = "CloudImage"
                id = "PROJECT_EXT_14"
                param("agent_pool_id", "-2")
                param("amazon-id", "ami-054328a36911618f1")
                param("ebs-optimized", "false")
                param("iam-instance-profile", "TeamcityAgentsProfile-prod")
                param("image-instances-limit", "3")
                param("image-name-prefix", "Linux-Small")
                param("instance-type", "c5d.xlarge")
                param("key-pair-name", "tc-agents-prod")
                param("profileId", "amazon-1")
                param("security-group-ids", AwsConnection.cloudAgentSecurityGroups)
                param("source-id", "Linux-Small")
                param("subnet-id", AwsConnection.cloudAgentSubnetId)
                param("use-spot-instances", "false")
                param("user-tags", "<custom-profile>=<demo-teamcity-com>")
            }
}

fun ProjectFeatures.spaceConnection() {
    spaceConnection {
        id = "PROJECT_EXT_3"
        displayName = "JetBrains Space"
        serverUrl = SpaceConnection.serverUrl
        clientId = SpaceConnection.clientId
        clientSecret = SpaceConnection.clientSecret
    }
}

fun ProjectFeatures.featureAws() {
    feature {
        id = "amazon-1"
        type = "CloudProfile"
        param("profileServerUrl", "")
        param("system.cloud.profile_id", "amazon-1")
        param("total-work-time", "")
        param("description", "")
        param("user-script", "")
        param("cloud-code", "amazon")
        param("spot-fleet-config", "")
        param("enabled", "true")
        param("max-running-instances", "10")
        param("agentPushPreset", "")
        param("profileId", "amazon-1")
        param("use-instance-iam-role", "false")
        param("name", "AWS EC2")
        param("next-hour", "")
        param("region", AwsConnection.region)
        param("terminate-idle-time", "60")
        param("not-checked", "")
        param("secure:access-id", AwsConnection.accessKeyId)
        param("secure:secret-key", AwsConnection.secretAccessKey)
    }
}
