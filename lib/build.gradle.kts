repositories.mavenCentral()

plugins {
    id("io.gitlab.arturbosch.detekt") version Version.detekt
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

kotlin.sourceSets.forEach {
    val detektTask = tasks.getByName<io.gitlab.arturbosch.detekt.Detekt>("detekt" + it.name.capitalize())
    task<io.gitlab.arturbosch.detekt.Detekt>("verifyCodeQuality" + it.name.capitalize()) {
        jvmTarget = Version.jvmTarget
        setSource(it.kotlin.sourceDirectories)
        val configs = setOf(
            "common",
            "comments",
            "complexity",
            "coroutines",
            "empty-blocks",
            "exceptions",
            "naming",
            "performance",
            "potential-bugs",
            "style"
        ).map { config ->
            File(rootDir, "buildSrc/src/main/resources/detekt/config/$config.yml").existing()
        }
        config.setFrom(configs)
        reports {
            xml.required.set(false)
            sarif.required.set(false)
            txt.required.set(false)
            html {
                required.set(true)
                outputLocation.set(File(buildDir, "reports/analysis/code/quality/${it.name}/html/index.html"))
            }
        }
        classpath.setFrom(detektTask.classpath)
    }
}
