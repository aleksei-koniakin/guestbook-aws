package src

import jetbrains.buildServer.configs.kotlin.Project

object Infra : Project({
    name = "Infrastructure"

    buildType(Infra_DeployInfrastructure)
    buildType(Infra_DeployBastion)

    buildType(Infra_BuildBastion)
    buildType(Infra_BuildRdImage)

    buildTypesOrderIds = buildTypes.mapNotNull { it.id }
})
