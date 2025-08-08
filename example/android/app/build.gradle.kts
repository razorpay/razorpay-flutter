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



    dependencies {
        implementation("androidx.appcompat:appcompat:1.6.1")
        implementation("androidx.constraintlayout:constraintlayout:2.1.4")
        implementation("com.google.android.material:material:1.11.0")
        implementation("com.google.android.gms:play-services-auth:20.7.0")
        implementation("com.google.android.gms:play-services-auth-api-phone:18.0.1")
        implementation("com.razorpay:checkout:1.6.41")
        implementation("com.razorpay:razorpay-turbo:2.1.0")
        implementation("com.razorpay:turbo-ui:2.1.0")
    }
}

flutter {
    source = "../.."
}
