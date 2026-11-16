allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    val subprojectName = name
    project.buildDir = File(rootProject.projectDir.parentFile, "build/$subprojectName")

    afterEvaluate {
        if (hasProperty("android")) {
            val android = property("android") as? com.android.build.gradle.BaseExtension
            android?.compileSdkVersion(36)
            android?.defaultConfig {
                targetSdkVersion(36)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
