package src

import jetbrains.buildServer.configs.kotlin.BuildType
import jetbrains.buildServer.configs.kotlin.DslContext
import jetbrains.buildServer.configs.kotlin.buildSteps.qodana
import jetbrains.buildServer.configs.kotlin.buildSteps.script

object Build_BuildFrontend : BuildType({
    name = "Build Frontend"
    buildNumberPattern = "1.0.%build.counter%"

    artifactRules = "frontend/docker/dist/* => dist/"

    linuxLarge()

    vcs {
        // Checkout directory needs to contain the .git folder in order for the Qodana => IDE generated links to work,
        // so use exclusion rules rather than specific inclusion/mapping rules. If inclusion/mapping rules are used,
        // the .git folder isn't present in the checkout directory.
        root(DslContext.settingsRoot, "-:backend", "-:conf", "-:database", "-:deployment", "-:infrastructure", "-:requests", "-:tf", "-:.teamcity", "-:.space")
    }

    steps {
        script {
            name = "Install && Build"
            workingDir = "frontend"
            scriptContent = """
                        npm install
                        npm run build
                    """.trimIndent()
            dockerPull = true
            dockerImage = "node:14"
        }
        qodana {
            linter = javascript {
            }
        }
    }
})
