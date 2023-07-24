package src

import jetbrains.buildServer.configs.kotlin.CustomChart
import jetbrains.buildServer.configs.kotlin.Project
import jetbrains.buildServer.configs.kotlin.projectCustomChart

object Build : Project({
    name = "Build"

    buildType(Build_RunBackendTests)
    buildType(Build_BuildBackend)
    buildType(Build_BuildFrontend)
    buildType(Build_BuildFrontendImage)
    buildType(Build_BuildBackendImage)

    buildType(Build_DeployImage)

    features {
        projectCustomChart {
            id = "PROJECT_EXT_15"
            title = "New chart title"
            seriesTitle = "Serie"
            format = CustomChart.Format.TEXT
            series = listOf(
                    CustomChart.Serie(title = "Queue wait reason: No available agents", key = CustomChart.SeriesKey("queueWaitReason:No_available_agents"), sourceBuildTypeId = "GuestbookAws_Build_BuildBackend")
            )
        }
    }

    buildTypesOrder = arrayListOf(Build_RunBackendTests, Build_BuildBackend, Build_BuildBackendImage, Build_DeployImage, Build_BuildFrontend, Build_BuildFrontendImage)
})