import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ─── Assinatura de release ───────────────────────────────────────────────────
// Credenciais ficam em android/key.properties, que NÃO é versionado (ver
// android/.gitignore). O keystore em si mora fora do repositório: o arquivo só
// guarda o caminho até ele.
val keystorePropertiesFile = rootProject.file("key.properties")
val hasKeystore = keystorePropertiesFile.exists()
val keystoreProperties = Properties().apply {
    if (hasKeystore) {
        FileInputStream(keystorePropertiesFile).use { load(it) }
    }
}

// ─── Portão de versionCode ───────────────────────────────────────────────────
// O Android recusa instalar um APK com versionCode menor OU IGUAL ao instalado.
// Distribuindo fora da Play Store não há ninguém validando isso por nós, então
// o build guarda o último versionCode publicado e falha se ele não subir.
val versionGateFile = rootProject.file("last_release_version_code.txt")
val lastReleasedVersionCode: Int =
    versionGateFile.takeIf { it.exists() }
        ?.readText()
        ?.trim()
        ?.toIntOrNull()
        ?: 0

// Escape hatch para reconstruir a MESMA versão de propósito (ex.: corrigir algo
// antes de distribuir):  flutter build apk --release --dart-define=x  \
//   ... ou:  ./gradlew assembleRelease -PallowSameVersionCode=true
val allowSameVersionCode =
    (project.findProperty("allowSameVersionCode") as String?)?.toBoolean() ?: false

android {
    namespace = "com.kayque.pets"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Identidade PERMANENTE da instalação. Trocar depois de distribuir faz
        // o Android tratar como outro app: instala ao lado em vez de atualizar.
        // Precisa existir como cliente Android no google-services.json, senão o
        // plugin do Firebase falha o build.
        applicationId = "com.kayque.pets"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Fonte única: `version: x.y.z+n` do pubspec.yaml. `x.y.z` vira
        // versionName e `n` vira versionCode.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasKeystore) {
            create("release") {
                // Caminho ABSOLUTO no key.properties evita ambiguidade de
                // diretório base entre o projeto raiz e o módulo app.
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Sem keystore o release fica SEM signingConfig e o build falha no
            // `checkReleaseSigning` abaixo — de propósito. Antes caía no
            // signingConfig de debug, o que gera um APK que não atualiza a
            // instalação real e não deveria ser distribuído.
            signingConfig =
                if (hasKeystore) signingConfigs.getByName("release") else null
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// ─── Verificações que rodam só em build de release ───────────────────────────

val checkReleaseSigning by tasks.registering {
    doFirst {
        if (!hasKeystore) {
            throw GradleException(
                "\n\nBuild de release sem chave de assinatura.\n" +
                    "Falta o arquivo: ${keystorePropertiesFile.absolutePath}\n" +
                    "Crie-o com storeFile / storePassword / keyAlias / keyPassword.\n" +
                    "Ele não é versionado — cada máquina que publica precisa do seu.\n"
            )
        }
    }
}

val checkReleaseVersionCode by tasks.registering {
    // Capturado na configuração: ler `flutter.versionCode` dentro da ação da
    // task quebra com configuration cache.
    val currentVersionCode = flutter.versionCode
    val last = lastReleasedVersionCode
    val allowSame = allowSameVersionCode
    val gateFile = versionGateFile

    doFirst {
        if (!allowSame && currentVersionCode <= last) {
            throw GradleException(
                "\n\nversionCode não subiu.\n" +
                    "  atual no pubspec.yaml : $currentVersionCode\n" +
                    "  último publicado      : $last\n\n" +
                    "O Android recusa instalar por cima com versionCode menor ou " +
                    "igual.\nSuba o número depois do '+' em `version:` no " +
                    "pubspec.yaml (ex.: 1.0.0+${last + 1}).\n\n" +
                    "Para reconstruir a MESMA versão de propósito:\n" +
                    "  flutter build apk --release -PallowSameVersionCode=true\n" +
                    "(registro em ${gateFile.name})\n"
            )
        }
    }
}

val recordReleaseVersionCode by tasks.registering {
    val currentVersionCode = flutter.versionCode
    val last = lastReleasedVersionCode
    val gateFile = versionGateFile

    doLast {
        if (currentVersionCode > last) {
            gateFile.writeText("$currentVersionCode\n")
            logger.lifecycle(
                "versionCode $currentVersionCode registrado em ${gateFile.name} " +
                    "— faça commit desse arquivo."
            )
        }
    }
}

// As verificações entram em `preReleaseBuild`, que é o primeiro passo da
// variante de release: assim a falha aparece em segundos. Penduradas em
// `assembleRelease` elas só rodariam DEPOIS de toda a compilação — descobrir
// que esqueceu de subir a versão após alguns minutos de build seria inútil.
tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    dependsOn(checkReleaseSigning, checkReleaseVersionCode)
}

// O registro fica no fim, e só de APK/AAB de release de verdade: `assemble`
// pode rodar sem gerar artefato distribuível.
tasks.matching { it.name.matches(Regex("^(assemble|bundle)Release$")) }
    .configureEach {
        finalizedBy(recordReleaseVersionCode)
    }
