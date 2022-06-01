repositories.mavenCentral()

plugins {
    id("org.jetbrains.kotlin.jvm")
    id("org.gradle.jacoco")
}

tasks.getByName<JavaCompile>("compileJava") {
    targetCompatibility = Version.jvmTarget
}

tasks.getByName<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>("compileKotlin") {
    kotlinOptions.jvmTarget = Version.jvmTarget
}

dependencies {
    testImplementation("junit:junit:${Version.junit}")
}

tasks.getByName<JavaCompile>("compileTestJava") {
    targetCompatibility = Version.jvmTarget
}

tasks.getByName<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>("compileTestKotlin") {
    kotlinOptions.jvmTarget = Version.jvmTarget
}

val testTask = tasks.getByName<Test>("test")

jacoco {
    toolVersion = Version.jacoco
}

val testCoverageTask = tasks.getByName<JacocoReport>("jacocoTestReport") {
    dependsOn(testTask)
    reports {
        csv.required.set(false)
        html.required.set(true)
        xml.required.set(false)
    }
}

tasks.getByName<JacocoCoverageVerification>("jacocoTestCoverageVerification") {
    dependsOn(testCoverageTask)
    violationRules {
        rule {
            limit {
                minimum = BigDecimal(0.96)
            }
        }
    }
}
