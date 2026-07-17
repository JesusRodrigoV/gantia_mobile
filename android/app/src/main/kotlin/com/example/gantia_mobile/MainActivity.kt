package com.example.gantia_mobile

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothProfile
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var _connectedName: String? = null
    private var _connectedAddress: String? = null
    private var _isConnected = false
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.gantia_mobile/media_control"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "playPause" -> {
                    dispatchMediaKey(audioManager, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE)
                    result.success(true)
                }
                "next" -> {
                    dispatchMediaKey(audioManager, KeyEvent.KEYCODE_MEDIA_NEXT)
                    result.success(true)
                }
                "prev" -> {
                    dispatchMediaKey(audioManager, KeyEvent.KEYCODE_MEDIA_PREVIOUS)
                    result.success(true)
                }
                "volumeUp" -> {
                    audioManager.adjustStreamVolume(
                        AudioManager.STREAM_MUSIC,
                        AudioManager.ADJUST_RAISE,
                        AudioManager.FLAG_SHOW_UI
                    )
                    result.success(true)
                }
                "volumeDown" -> {
                    audioManager.adjustStreamVolume(
                        AudioManager.STREAM_MUSIC,
                        AudioManager.ADJUST_LOWER,
                        AudioManager.FLAG_SHOW_UI
                    )
                    result.success(true)
                }
                "mute" -> {
                    if (audioManager.getStreamVolume(AudioManager.STREAM_MUSIC) > 0)
                        audioManager.adjustStreamVolume(
                            AudioManager.STREAM_MUSIC,
                            AudioManager.ADJUST_MUTE,
                            AudioManager.FLAG_SHOW_UI
                        )
                    else
                        audioManager.adjustStreamVolume(
                            AudioManager.STREAM_MUSIC,
                            AudioManager.ADJUST_UNMUTE,
                            AudioManager.FLAG_SHOW_UI
                        )
                    result.success(true)
                }
                "getConnectedDevice" -> result.success(
                    mapOf(
                        "name" to _connectedName,
                        "address" to _connectedAddress,
                        "connected" to _isConnected
                    )
                )
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.gantia_mobile/bt_events"
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        registerReceiver(
            btReceiver,
            IntentFilter().apply {
                addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
                addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
            }
        )

        queryA2dpState()
    }

    private fun queryA2dpState() {
        val adapter = BluetoothAdapter.getDefaultAdapter() ?: return
        adapter.getProfileProxy(
            this,
            object : BluetoothProfile.ServiceListener {
                override fun onServiceConnected(profileId: Int, proxy: BluetoothProfile) {
                    if (profileId == BluetoothProfile.A2DP) {
                        val devices = proxy.connectedDevices
                        if (devices.isNotEmpty()) {
                            val device = devices[0]
                            _connectedName = device.name
                            _connectedAddress = device.address
                            _isConnected = true
                            emitEvent()
                        }
                        adapter.closeProfileProxy(BluetoothProfile.A2DP, proxy)
                    }
                }

                override fun onServiceDisconnected(profileId: Int) {}
            },
            BluetoothProfile.A2DP
        )
    }

    private val btReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val device =
                intent?.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE) ?: return
            when (intent.action) {
                BluetoothDevice.ACTION_ACL_CONNECTED -> {
                    _connectedName = device.name
                    _connectedAddress = device.address
                    _isConnected = true
                }

                BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                    _connectedName = null
                    _connectedAddress = null
                    _isConnected = false
                }
            }
            emitEvent()
        }
    }

    private fun emitEvent() {
        eventSink?.success(
            mapOf(
                "name" to _connectedName,
                "address" to _connectedAddress,
                "connected" to _isConnected
            )
        )
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(btReceiver)
        } catch (_: Exception) {}
        super.onDestroy()
    }
}

private fun dispatchMediaKey(audioManager: AudioManager, keyCode: Int) {
    audioManager.dispatchMediaKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
    audioManager.dispatchMediaKeyEvent(KeyEvent(KeyEvent.ACTION_UP, keyCode))
}
