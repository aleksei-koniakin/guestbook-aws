@file:Suppress("ClassName")

package src

import jetbrains.buildServer.configs.kotlin.BuildType
import jetbrains.buildServer.configs.kotlin.CheckoutMode
import jetbrains.buildServer.configs.kotlin.DslContext
import jetbrains.buildServer.configs.kotlin.buildSteps.dockerCommand

const val spaceImageTerraform = SpaceConnection.spaceRegistryUrl + "/terraformx:latest"

object Build_DeployImage : BuildType({
    name = "Build Deploy Image"

    linux()
    vcs {
        root(DslContext.settingsRoot, "+:infrastructure/tf => infrastructure/tf")
        checkoutMode = CheckoutMode.ON_AGENT
    }

    steps {
        dockerCommand {
            name = "Build Image"
            commandType = build {
                source = file {
                    path = "infrastructure/tf/Dockerfile"
                }
                contextDir = "infrastructure/tf"
                namesAndTags = spaceImageTerraform
                commandArgs = "--pull"
            }
        }
        dockerCommand {
            name = "Push Image"
            commandType = push {
                namesAndTags = spaceImageTerraform
            }
        }
    }

    spaceDckerLoginFeature()
})
