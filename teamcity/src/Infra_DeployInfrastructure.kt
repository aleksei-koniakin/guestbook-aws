@file:Suppress("ClassName")

package src

object Infra_DeployInfrastructure : DeployBuildType({
    name = "Deploy Infrastructure"

    terraformScript(
      "tf/infrastructure",
      """
                  terraform apply -auto-approve      
      """.trimIndent()
    )
})

object Infra_DeployBastion : DeployBuildType({
    name = "Deploy Bastion"

    terraformScript(
      "tf/bastion",
      """
                  terraform apply -auto-approve      
      """.trimIndent()
    )
})
