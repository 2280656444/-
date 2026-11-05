import com.android.build.gradle.internal.cxx.configure.gradleLocalProperties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // 如果有 Flutter 插件自动生成，保留 id("dev.flutter.flutter-gradle-plugin")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // 必须明确声明 namespace（替代旧 Manifest 里的 package）
    namespace = "com.example.rili"
    compileSdk = 34

    defaultConfig {
        applicationId = "日厤"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // 签名配置：若 GitHub Actions 用了签名，保持你原有的 signingConfigs
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
}
