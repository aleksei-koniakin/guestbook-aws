@file:Suppress("ClassName")

package src

import jetbrains.buildServer.configs.kotlin.ReuseBuilds

object Deploy_DeployProduction: DeployBuildType({
    name = "Deploy to Production"

    terraformScript(
        workdir = "tf/prod",
        text = """
                terraform apply -auto-approve \
                                -var backend_version=${Build_BuildBackendImage.depParamRefs.buildNumber.ref} \
                                -var frontend_version=${Build_BuildFrontendImage.depParamRefs.buildNumber.ref}

        """.trimIndent()
    )

    dependencies {
        snapshot(Deploy_DeployStaging) {
            reuseBuilds = ReuseBuilds.SUCCESSFUL
            synchronizeRevisions = false
        }
    }
})

