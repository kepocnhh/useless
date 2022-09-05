repositories.mavenCentral()

plugins {
    id("org.gradle.kotlin.kotlin-dsl") version "2.3.3"
}

val jvmTarget = "1.8"

tasks.getByName<JavaCompile>("compileJava") {
    targetCompatibility = jvmTarget
}

tasks.getByName<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>("compileKotlin") {
    kotlinOptions.jvmTarget = jvmTarget
}
