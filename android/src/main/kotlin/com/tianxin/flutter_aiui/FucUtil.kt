package com.tianxin.flutter_aiui

import android.content.Context
import android.os.Environment
import android.util.Log
import java.io.*


/**
 * 功能性函数扩展类
 */
object FucUtil {

    fun getFileRoot(context: Context): String? {
        if (Environment.getExternalStorageState().equals(
                Environment.MEDIA_MOUNTED
            )
        ) {
            val external = context.getExternalFilesDir(null)
            if (external != null) {
                return external.absolutePath
            }
        }
        return context.filesDir.absolutePath
    }

    fun copyAssetFolder(context: Context, srcName: String, dstName: String): Boolean {
        return try {
            var result: Boolean
            val fileList: Array<String> = context.assets.list(srcName) ?: return false
            if (fileList.isEmpty()) {
                result = copyAssetFile(context, srcName, dstName)
            } else {
                val file = File(dstName)
                result = file.mkdirs()
                for (filename in fileList) {
                    result = result and copyAssetFolder(
                        context,
                        srcName + File.separator + filename,
                        dstName + File.separator + filename
                    )
                }
            }
            result
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }

    private fun copyAssetFile(context: Context, srcName: String, dstName: String): Boolean {
        return try {
            var `in`: InputStream

            val iniPath =
                Constant.IVW_FOLDER_NAME + File.separator + Constant.VTN_FOLDER_NAME + File.separator + Constant.INI_FILE_NAME
            if (srcName == iniPath) {
                val temp: InputStream = context.assets.open(srcName)

                val bufferReader = BufferedReader(temp.reader())
                bufferReader.use { reader ->
                    var content = reader.readText()
                    content += "res_path=" + dstName.replace(
                        Constant.INI_FILE_NAME,
                        Constant.BIN_FILE_NAME
                    )
                    `in` = ByteArrayInputStream(content.toByteArray())
                }
            } else {
                `in` = context.assets.open(srcName)
            }

            val outFile = File(dstName)
            if (!outFile.parentFile!!.exists()) {
                outFile.parentFile!!.mkdirs()
            }
            val out: OutputStream = FileOutputStream(outFile)
            val buffer = ByteArray(1024)
            var read: Int
            while (`in`.read(buffer).also { read = it } != -1) {
                out.write(buffer, 0, read)
            }
            `in`.close()
            out.close()
            true
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }
}
