package com.tianxin.flutter_aiui

import android.annotation.SuppressLint
import android.content.Context
import android.net.wifi.WifiManager
import android.os.Build
import android.text.TextUtils
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.RandomAccessFile
import java.net.NetworkInterface
import java.nio.charset.Charset
import java.util.*
import kotlin.math.abs

object DeviceUtils {
    private const val TAG = "DeviceUtils"
    private const val DEVICE_CACHE_FILE = "INSTALLATION.id"
    fun getDeviceId(context: Context): String {
        var deviceId: String
        try {
            val deviceIdFile = File(context.filesDir, DEVICE_CACHE_FILE)
            do {
                deviceId = readDeviceId(deviceIdFile)
                if (!TextUtils.isEmpty(deviceId)) {
                    break
                }
                deviceId = getWifiMac(context)
                if (!TextUtils.isEmpty(deviceId)) {
                    break
                }
                deviceId = UUID.randomUUID().toString()
                deviceId = deviceId.replace("-".toRegex(), "")
            } while (false)
            writeDeviceId(deviceId, deviceIdFile)
            return deviceId
        } catch (t: Throwable) {
            t.printStackTrace()
        }
        return ""
    }

    private fun readDeviceId(cacheFile: File): String {
        try {
            val f = RandomAccessFile(cacheFile, "r")
            val bytes = ByteArray(f.length().toInt())
            f.readFully(bytes)
            f.close()
            return String(bytes, Charset.defaultCharset())
        } catch (t: Throwable) {
            t.printStackTrace()
        }
        return ""
    }

    @Throws(IOException::class)
    private fun writeDeviceId(deviceId: String, cacheFile: File) {
        if (cacheFile.exists()) {
            cacheFile.deleteOnExit()
        }
        val out = FileOutputStream(cacheFile)
        out.write(deviceId.toByteArray(Charset.defaultCharset()))
        out.close()
    }

    /**
     * 获取Wifi Mac 默认值空字符串
     *
     * @param paramContext
     * @return
     */
    @SuppressLint("HardwareIds")
    fun getWifiMac(paramContext: Context): String {
        var result = ""
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val interfaces = NetworkInterface.getNetworkInterfaces()
                while (interfaces != null && interfaces.hasMoreElements()) {
                    val iF = interfaces.nextElement()
                    val addr = iF.hardwareAddress
                    var sum: Long = 0
                    for (item in addr!!) {
                        sum += abs(item.toInt()).toLong()
                    }
                    if (addr.isEmpty() || sum < Byte.MAX_VALUE) {
                        continue
                    }
                    //其他网卡（如rmnet0）的MAC，跳过
                    if ("wlan0".equals(iF.name, ignoreCase = true) || "eth0".equals(
                            iF.name,
                            ignoreCase = true
                        )
                    ) {
                        val buf = StringBuilder()
                        for (b in addr) {
                            buf.append(String.format("%02X:", b))
                        }
                        if (buf.isNotEmpty()) {
                            buf.deleteCharAt(buf.length - 1)
                        }
                        val mac = buf.toString()
                        if (mac.isNotEmpty()) {
                            result = mac
                            return result
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, e.toString())
            }
        } else {
            try {
                // MAC地址
                val wifi =
                    paramContext.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                val wiinfo = wifi.connectionInfo
                result = wiinfo.macAddress
            } catch (e: Throwable) {
                Log.w(TAG, "Failed to get mac Info")
            }
        }
        return result
    }
}