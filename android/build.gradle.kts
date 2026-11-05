buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // 保持你原有的 classpath，通常如下：
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 解决旧插件 V1 / namespace 报错的核心代码（Kotlin DSL 标准写法）
subprojects {
    afterEvaluate {
        if (hasProperty("android")) {
            extensions.configure("android") {
                if (this is com.android.build.gradle.BaseExtension) {
                    if (namespace == null) {
                        namespace = project.group.toString()
                    }
                }
            }
        }
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
