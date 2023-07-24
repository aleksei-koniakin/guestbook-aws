package src

import jetbrains.buildServer.configs.kotlin.BuildType


fun BuildType.linux() {
  requirements {
    equals("docker.server.osType", "linux")
  }
}

fun BuildType.linuxLarge() {
  requirements {
    equals("docker.server.osType", "linux")
    equals("teamcity.agent.hardware.cpuCount", "8")
  }
}