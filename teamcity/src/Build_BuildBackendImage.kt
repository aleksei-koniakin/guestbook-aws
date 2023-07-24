@file:Suppress("ClassName")

package src

import jetbrains.buildServer.configs.kotlin.BuildType
import jetbrains.buildServer.configs.kotlin.CheckoutMode
import jetbrains.buildServer.configs.kotlin.DslContext
import jetbrains.buildServer.configs.kotlin.ReuseBuilds
import jetbrains.buildServer.configs.kotlin.buildSteps.dockerCommand
import src.AwsConnection.ecrBackendName

object Build_BuildBackendImage : BuildType({
    name = "Build Backend Image"
    buildNumberPattern = Build_BuildBackend.depParamRefs.buildNumber.ref

    linux()

    vcs {
        root(DslContext.settingsRoot, "+:backend => backend")
        checkoutMode = CheckoutMode.ON_AGENT
    }

    steps {
        dockerCommand {
            name = "Build Image"
            commandType = build {
                source = file {
                    path = "backend/Dockerfile"
                }
                namesAndTags = ecrBackendName
                commandArgs = "--pull --build-arg JAR_FILE=build/*.jar"
            }
        }
        dockerCommand {
            name = "Push Image"
            commandType = push {
                namesAndTags = ecrBackendName
            }
        }
    }

    dockerLoginFeature()

    dependencies {
        dependency(Build_BuildBackend) {
            snapshot {
                reuseBuilds = ReuseBuilds.SUCCESSFUL
                synchronizeRevisions = false
            }

            artifacts {
                cleanDestination = true
                artifactRules = "*.jar => backend/build"
            }
        }
    }
})