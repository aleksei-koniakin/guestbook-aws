package src

import jetbrains.buildServer.configs.kotlin.BuildType
import jetbrains.buildServer.configs.kotlin.DslContext
import jetbrains.buildServer.configs.kotlin.ReuseBuilds
import jetbrains.buildServer.configs.kotlin.buildSteps.gradle
import jetbrains.buildServer.configs.kotlin.buildSteps.qodana

object Build_BuildBackend : BuildType({
    name = "Build Backend"
    buildNumberPattern = "1.0.%build.counter%"

    vcs {
        // Checkout directory needs to contain the .git folder in order for the Qodana => IDE generated links to work,
        // so use exclusion rules rather than specific inclusion/mapping rules. If inclusion/mapping rules are used,
        // the .git folder isn't present in the checkout directory.
        root(DslContext.settingsRoot, "-:frontend", "-:conf", "-:database", "-:deployment", "-:infrastructure", "-:requests", "-:tf", "-:.teamcity", "-:.space")
    }

    linuxLarge()

    steps {
        gradle {
            tasks = "teamcity"
            workingDir = "backend"
            buildFile = "build.gradle.kts"
            dockerImage = "openjdk:11-jdk"
        }
        qodana {
            linter = jvm {
            }
        }
    }

    dependencies {
        dependency(Build_RunBackendTests) {
            snapshot {
                reuseBuilds = ReuseBuilds.SUCCESSFUL
                synchronizeRevisions = false
            }
        }
    }
})