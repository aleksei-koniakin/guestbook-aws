@file:Suppress("ClassName")

package src

import jetbrains.buildServer.configs.kotlin.*
import jetbrains.buildServer.configs.kotlin.BuildType
import jetbrains.buildServer.configs.kotlin.buildSteps.script
import jetbrains.buildServer.configs.kotlin.triggers.vcs

object Deploy_DeployStaging : DeployBuildType({
    name = "Deploy to Staging"

    terraformScript(
        workdir = "tf/prod",
        text = """
            
                export TF_WORKSPACE=%teamcity.build.branch%
                
                terraform apply -auto-approve \
                                -var backend_version=${Build_BuildBackendImage.depParamRefs.buildNumber.ref} \
                                -var frontend_version=${Build_BuildFrontendImage.depParamRefs.buildNumber.ref}

        """.trimIndent()
    )

    triggers {
        vcs {
            triggerRules = "-:.teamcity/**"
            branchFilter = listOf(
                //"-:master",
                "+:*",
            ).joinToString("\n")
            watchChangesInDependencies = true
        }
    }

    dependencies {
        snapshot(Build_BuildBackendImage) {
            reuseBuilds = ReuseBuilds.SUCCESSFUL
            synchronizeRevisions = false
        }
        snapshot(Build_BuildFrontendImage) {
            reuseBuilds = ReuseBuilds.SUCCESSFUL
            synchronizeRevisions = false
        }
    }
})

