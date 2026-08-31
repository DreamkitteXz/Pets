package com.kayque.pets

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Instalação de APK a partir do próprio app (distribuição fora da Play Store).
 *
 * Escrito à mão em vez de usar pacote pronto porque as duas peças que o fluxo
 * exige — `canRequestPackageInstalls()` e a tela
 * `ACTION_MANAGE_UNKNOWN_APP_SOURCES` — não são expostas pelos plugins de
 * instalação disponíveis. Com um pacote, ainda seria preciso um channel para
 * elas; o pacote só pouparia o Intent de instalação, que são ~10 linhas.
 *
 * O caminho do arquivo NUNCA vai como `file://`: a partir do Android 7 isso
 * lança FileUriExposedException. Vai como `content://` via FileProvider, com
 * FLAG_GRANT_READ_URI_PERMISSION para o instalador conseguir ler.
 */
class ApkInstaller(private val activity: Activity) {

    companion object {
        const val CHANNEL = "pet_app/apk_installer"

        /** Precisa bater com android:authorities do <provider> no manifest. */
        private const val AUTHORITY_SUFFIX = ".provider"

        private const val APK_MIME = "application/vnd.android.package-archive"
    }

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "canRequestPackageInstalls" -> result.success(canRequestPackageInstalls())
            "openInstallPermissionSettings" -> result.success(openInstallSettings())
            "installApk" -> installApk(call.argument<String>("filePath"), result)
            else -> result.notImplemented()
        }
    }

    /**
     * Em API < 26 não existe autorização por app: "fontes desconhecidas" é um
     * ajuste global do aparelho, então do ponto de vista do app já está
     * liberado e não há tela por-app para abrir.
     */
    private fun canRequestPackageInstalls(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            activity.packageManager.canRequestPackageInstalls()
        } else {
            true
        }
    }

    private fun openInstallSettings(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        return try {
            // Com o `package:` a tela abre JÁ no toggle deste app. Sem ele cai
            // na lista geral e o usuário tem que caçar o app no meio de todos.
            val intent = Intent(
                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                Uri.parse("package:${activity.packageName}")
            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            activity.startActivity(intent)
            true
        } catch (e: Exception) {
            // Fabricantes que removem a tela por-app: cai nos ajustes do app.
            try {
                val fallback = Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.parse("package:${activity.packageName}")
                ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                activity.startActivity(fallback)
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    private fun installApk(filePath: String?, result: MethodChannel.Result) {
        if (filePath.isNullOrBlank()) {
            result.error("INVALID_PATH", "Caminho do APK não informado.", null)
            return
        }

        val file = File(filePath)
        if (!file.exists() || file.length() == 0L) {
            result.error("FILE_NOT_FOUND", "APK não encontrado em $filePath", null)
            return
        }

        if (!canRequestPackageInstalls()) {
            // O Dart checa antes, mas a autorização pode ser revogada entre a
            // checagem e o toque — melhor errar aqui que abrir uma tela morta.
            result.error(
                "PERMISSION_DENIED",
                "Autorização para instalar apps desconhecidos não concedida.",
                null
            )
            return
        }

        try {
            val uri: Uri = FileProvider.getUriForFile(
                activity,
                "${activity.packageName}$AUTHORITY_SUFFIX",
                file
            )
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, APK_MIME)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            activity.startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("INSTALL_FAILED", e.message, null)
        }
    }
}
