import org.gradle.api.tasks.Delete

// 顶层插件声明（Flutter 3.24 新架构必须这样写）
plugins {
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
