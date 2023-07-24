@file:Suppress("ClassName")
package src

object Infra_BuildBastion : DeployBuildType({
    name = "Build Bastion Host AMI"

    linux()

    terraformScript(
        workdir = "infrastructure/bastion",
        text = """
            packer build packer.json
        """.trimIndent()
    )
})
