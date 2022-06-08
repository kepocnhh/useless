buildscript {
    repositories.mavenCentral()

    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:${Version.kotlin}")
    }
}

task<Delete>("clean") {
    delete = setOf(buildDir, file("buildSrc/build"))
}

repositories.mavenCentral() // com.pinterest.ktlint

val kotlinLint: Configuration by configurations.creating

dependencies {
    kotlinLint("com.pinterest:ktlint:${Version.ktlint}") {
        attributes {
            attribute(Bundling.BUNDLING_ATTRIBUTE, objects.named(Bundling.EXTERNAL))
        }
    }
}

task<JavaExec>("verifyCodeStyle") {
    classpath = kotlinLint
    mainClass.set("com.pinterest.ktlint.Main")
    args(
        "build.gradle.kts",
        "settings.gradle.kts",
        "buildSrc/src/main/kotlin/**/*.kt",
        "buildSrc/build.gradle.kts",
        "lib/src/main/kotlin/**/*.kt",
        "lib/src/test/kotlin/**/*.kt",
        "lib/build.gradle.kts",
        "--reporter=html,output=${File(buildDir, "reports/analysis/code/style/html/index.html")}"
    )
}

task("verifyReadme") {
    doLast {
        val badges = setOf(
            MarkdownUtil.image(
                text = "version",
                url = BadgeUtil.url(
                    label = "version",
                    message = Version.name,
                    color = "2962ff"
                )
            )
        )
        FileUtil.check(
            file = File(rootDir, "README.md"),
            expected = badges,
            report = File(buildDir, "reports/analysis/readme/index.html")
        )
    }
}

task("verifyLicense") {
    doLast {
        FileUtil.check(
            file = File(rootDir, "LICENSE"),
            expected = emptySet(),
            report = File(buildDir, "reports/analysis/license/index.html")
        )
    }
}

task("verifyService") {
    doLast {
        val forbidden = setOf(".DS_Store")
        rootDir.forEachRecurse {
            if (!it.isDirectory) check(!forbidden.contains(it.name)) {
                "File by path ${it.absolutePath} is forbidden!"
            }
        }
    }
}

task("saveCommonInfo") {
    doLast {
        val result = setOf(
            "version" to setOf(
                "name" to Version.name
            ),
            "repository" to setOf(
                "owner" to Repository.owner,
                "name" to Repository.name
            )
        ).joinToString(prefix = "{", separator = ",", postfix = "}") { (key, value) ->
            "\"$key\":" + value.joinToString(prefix = "{", separator = ",", postfix = "}") { (k, v) ->
                "\"$k\":\"$v\""
            }
        }
        File(buildDir, "common.json").also {
            it.parentFile!!.mkdirs()
            it.delete()
            it.writeText(result)
        }
    }
}
