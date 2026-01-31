buildscript {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    dependencies {
        // Android Gradle Plugin
        classpath("com.android.tools.build:gradle:8.2.1")

        // Google Services plugin (จำเป็นสำหรับ Firebase)
        classpath("com.google.gms:google-services:4.4.0")

        // ถ้าใช้ Firebase Crashlytics หรือ Performance Monitoring ให้เพิ่มด้วย
        // classpath("com.google.firebase:firebase-crashlytics-gradle:2.9.9")
        // classpath("com.google.firebase:perf-plugin:1.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// กำหนด buildDir รวมศูนย์
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ให้ Gradle ประเมิน project :app ก่อน
subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ ใช้ Java Toolchain 17 แทน options.release
subprojects {
    plugins.withType<JavaPlugin> {
        configure<JavaPluginExtension> {
            toolchain {
                languageVersion.set(JavaLanguageVersion.of(17))
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}