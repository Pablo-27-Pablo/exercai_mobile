buildscript {
    repositories {
        google()  // ✅ Google's Maven repo
        mavenCentral()  // ✅ Maven Central repo
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.1") // ✅ Add this line
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")  // ✅ Kotlin Gradle plugin
    }
}




allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
