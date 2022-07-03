import java.net.URL

repositories.mavenCentral()

plugins {
    id("io.gitlab.arturbosch.detekt") version Version.detekt
    id("org.jetbrains.kotlin.jvm")
    id("org.gradle.jacoco")
    id("org.jetbrains.dokka") version Version.dokka
}

tasks.getByName<JavaCompile>("compileJava") {
    targetCompatibility = Version.jvmTarget
}

val compileKotlinTask = tasks.getByName<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>("compileKotlin") {
    kotlinOptions.jvmTarget = Version.jvmTarget
}

dependencies {
    testImplementation("junit:junit:${Version.junit}")
}

tasks.getByName<JavaCompile>("compileTestJava") {
    targetCompatibility = Version.jvmTarget
}

tasks.getByName<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>("compileTestKotlin").kotlinOptions {
    jvmTarget = Version.jvmTarget
    freeCompilerArgs = freeCompilerArgs + listOf("-module-name", Maven.groupId + ":" + Maven.artifactId)
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

"unstable".also { variant ->
    val tag = "${Version.name}-${variant.toUpperCase()}"
    task<Jar>("assemble${variant.capitalize()}Jar") {
        dependsOn(compileKotlinTask)
        archiveBaseName.set(Repository.name)
        archiveVersion.set(tag)
        from(compileKotlinTask.destinationDirectory.asFileTree)
    }
}

"snapshot".also { variant ->
    val tag = "${Version.name}-${variant.toUpperCase()}"
    task<Jar>("assemble${variant.capitalize()}Jar") {
        dependsOn(compileKotlinTask)
        archiveBaseName.set(Maven.artifactId)
        archiveVersion.set(tag)
        from(compileKotlinTask.destinationDirectory.asFileTree)
    }
    task<Jar>("assemble${variant.capitalize()}Source") {
        archiveBaseName.set(Maven.artifactId)
        archiveVersion.set(tag)
        archiveClassifier.set("sources")
        from("src/main")
    }
    task<Jar>("assemble${variant.capitalize()}Pom") {
        doLast {
            val parent = File(buildDir, "libs")
            if (!parent.exists()) parent.mkdirs()
            val file = File(parent, "${Maven.artifactId}-$tag.pom")
            if (file.exists()) file.delete()
            val text = MavenUtil.pom(
                modelVersion = "4.0.0",
                groupId = Maven.groupId,
                artifactId = Maven.artifactId,
                version = tag,
                packaging = "jar"
            )
            file.writeText(text)
        }
    }
    task<org.jetbrains.dokka.gradle.DokkaTask>("assemble${variant.capitalize()}Documentation") {
        outputDirectory.set(File(buildDir, "documentation/$variant"))
        moduleName.set(Maven.artifactId)
        moduleVersion.set(tag)
        dokkaSourceSets {
            named("main") {
                reportUndocumented.set(false)
                sourceLink {
                    val path = "src/main/kotlin"
                    localDirectory.set(file(path))
                    remoteUrl.set(URL("https://github.com/${Repository.owner}/${Repository.name}/tree/$variant/lib/$path"))
                }
            }
        }
    }
}

task<io.gitlab.arturbosch.detekt.Detekt>("verifyDocumentation") {
    jvmTarget = Version.jvmTarget
    setSource(files("src/main/kotlin"))
    val configs = setOf(
        "common",
        "documentation"
    ).map { config ->
        File(rootDir, "buildSrc/src/main/resources/detekt/config/$config.yml").existing()
    }
    config.setFrom(configs)
    reports {
        html {
            required.set(true)
            outputLocation.set(File(buildDir, "reports/documentation/html/index.html"))
        }
        xml.required.set(false)
        txt.required.set(false)
        sarif.required.set(false)
    }
}
