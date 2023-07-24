package src

import jetbrains.buildServer.configs.kotlin.*
import jetbrains.buildServer.configs.kotlin.Project

object Deploy : Project({
    name = "Deploy"

    buildType(Deploy_DeployStaging)
    buildType(Deploy_DeployProduction)

    buildTypesOrderIds = arrayListOf(RelativeId("Deploy_DeployStaging"), RelativeId("Deploy_DeployProduction"))
})
