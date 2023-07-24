package src

import jetbrains.buildServer.configs.kotlin.triggers.vcs

object Infra_BuildRdImage : DeployBuildType({
    name = "Build Remote Development AMI"

    linux()

    terraformScript(
        workdir = "infrastructure/rd",
        text = """
            packer build packer.json
        """.trimIndent()
    )

    triggers {
        vcs {
            triggerRules = "+:infrastructure/rd/**"
            branchFilter = "+:master"
        }
    }
})
