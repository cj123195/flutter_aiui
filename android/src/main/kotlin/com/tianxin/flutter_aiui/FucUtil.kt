package com.tianxin.flutter_aiui

import android.content.Context
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStream


/**
 * 功能性函数扩展类
 */
object FucUtil {
    fun copyAssetFolder(context: Context, srcName: String, dstName: String): Boolean {
        return try {
            var result: Boolean
            val fileList = context.assets.list(srcName) ?: return false
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

    fun copyAssetFile(context: Context, srcName: String, dstName: String): Boolean {
        return try {
            val `in` = context.assets.open(srcName)
            val outFile = File(dstName)
            if (outFile.parentFile?.exists() == true) {
                outFile.parentFile?.mkdirs()
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
