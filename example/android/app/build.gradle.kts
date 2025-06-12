plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.razorpay.example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.razorpay.upisampleapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        viewBinding = true
        dataBinding = true
    }

    buildTypes {
        release {
            isDebuggable = true
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    configurations {
        all {
            exclude(group = "com.razorpay", module = "checkout")
            exclude(group = "com.razorpay", module = "razorpay-turbo-wrapper")
        }
    }

    dependencies {
        implementation("androidx.appcompat:appcompat:1.6.1")
        implementation("androidx.constraintlayout:constraintlayout:2.1.4")
        implementation("com.google.android.material:material:1.11.0")
        implementation("com.google.android.gms:play-services-auth:20.7.0")
        implementation("com.google.android.gms:play-services-auth-api-phone:18.0.1")
        implementation(fileTree(mapOf("dir" to "/Users/ramprasad.a/Documents/projects/Android/AAR_Files/std_checkout_uat_aars", "include" to listOf("*.aar"))))
        implementation ("io.sentry:sentry:6.21.0")
        implementation ("com.squareup.retrofit2:retrofit:2.9.0")
        implementation ("com.squareup.retrofit2:converter-gson:2.9.0")
        implementation ("com.squareup.okhttp3:logging-interceptor:4.10.0")
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.6.3")
        implementation("com.github.bumptech.glide:glide:4.15.1")
    }
}

flutter {
    source = "../.."
}
