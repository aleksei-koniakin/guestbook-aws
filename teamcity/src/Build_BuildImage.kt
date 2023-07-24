package src

import jetbrains.buildServer.configs.kotlin.BuildType
import jetbrains.buildServer.configs.kotlin.buildFeatures.dockerSupport

const val ecrRegistryIdForTeamCity = "AmazonDocker"
const val spaceRegistryIdForTeamCity = "SpaceDocker"

fun BuildType.dockerLoginFeature() {
    features {
        dockerSupport {
            cleanupPushedImages = true
            loginToRegistry = on {
                dockerRegistryId = ecrRegistryIdForTeamCity
            }
        }
    }
}

fun BuildType.spaceDckerLoginFeature() {
    features {
        dockerSupport {
            cleanupPushedImages = true
            loginToRegistry = on {
                dockerRegistryId = spaceRegistryIdForTeamCity
            }
        }
    }
}
