allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Workaround AGP 8: plugins antigos (ex.: flutter_keyboard_visibility 5.x) não
// declaram `namespace` no seu build.gradle (usavam `package` no AndroidManifest),
// o que falha no AGP 8 ("Namespace not specified"). Injeta o namespace a partir
// do `package` do AndroidManifest do módulo. Registrado ANTES de
// evaluationDependsOn para não cair em "project already evaluated". Reflexão
// para não exigir o AGP no classpath do root.
subprojects {
    afterEvaluate {
        val androidExt = extensions.findByName("android") ?: return@afterEvaluate
        val getNs = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" }
        val setNs = androidExt.javaClass.methods.firstOrNull {
            it.name == "setNamespace" && it.parameterCount == 1
        }
        if (getNs != null && setNs != null && getNs.invoke(androidExt) == null) {
            val manifest = file("src/main/AndroidManifest.xml")
            if (manifest.exists()) {
                val pkg = Regex("package=\"(.+?)\"")
                    .find(manifest.readText())?.groupValues?.get(1)
                if (!pkg.isNullOrBlank()) {
                    setNs.invoke(androidExt, pkg)
                    println("[namespace-fix] ${project.name} -> $pkg")
                }
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}