package src

import jetbrains.buildServer.configs.kotlin.BuildType
import jetbrains.buildServer.configs.kotlin.CheckoutMode
import jetbrains.buildServer.configs.kotlin.DslContext
import jetbrains.buildServer.configs.kotlin.buildFeatures.parallelTests
import jetbrains.buildServer.configs.kotlin.buildSteps.gradle

object Build_RunBackendTests : BuildType({
    name = "Run Backend Tests"
    buildNumberPattern = "1.0.%build.counter%"
    vcs {
        root(DslContext.settingsRoot, "+:backend => backend")
        checkoutMode = CheckoutMode.ON_AGENT
    }

    linuxLarge()

    features {
        parallelTests {
            numberOfBatches = 3
        }
    }

    steps {
        gradle {
            tasks = "test"
            buildFile = "build.gradle.kts"
            workingDir = "backend"
            dockerImage = "openjdk:11-jdk"
        }
    }
})