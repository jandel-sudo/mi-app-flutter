pluginManagement {
    

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
 
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
}
val flutterSdkPath = System.getenv("FLUTTER_ROOT")
incluideBuild("$flutterSdkPath/packages/flutter_tools/gradle")
include(":app")
