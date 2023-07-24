@file:Suppress("ClassName")

package src

import jetbrains.buildServer.configs.kotlin.BuildType
import jetbrains.buildServer.configs.kotlin.CheckoutMode
import jetbrains.buildServer.configs.kotlin.DslContext
import jetbrains.buildServer.configs.kotlin.ReuseBuilds
import jetbrains.buildServer.configs.kotlin.buildSteps.dockerCommand
import src.AwsConnection.ecrFrontendName

object Build_BuildFrontendImage : BuildType({
    name = "Build Frontend Image"
    buildNumberPattern = Build_BuildFrontend.depParamRefs.buildNumber.ref

    linux()
    vcs {
        root(DslContext.settingsRoot, "+:frontend => frontend")
        checkoutMode = CheckoutMode.ON_AGENT
    }

    steps {
        dockerCommand {
            name = "Build Image"
            commandType = build {
                source = file {
                    path = "frontend/docker/Dockerfile"
                }
                contextDir = "frontend/docker"
                namesAndTags = ecrFrontendName
                commandArgs = "--pull"
            }
        }
        dockerCommand {
            name = "Push Image"
            commandType = push {
                namesAndTags = ecrFrontendName
            }
        }
    }

    dockerLoginFeature()

    dependencies {
        dependency(Build_BuildFrontend) {
            snapshot {
                reuseBuilds = ReuseBuilds.ANY
                synchronizeRevisions = false
            }

            artifacts {
                cleanDestination = true
                artifactRules = "dist/** => frontend/docker/dist"
            }
        }
    }
})
