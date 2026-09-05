package com.example.verygoodcore.frontend

import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Plays the phone's own ringtone for an incoming/outgoing call, so calls
 * sound like calls on this device instead of like a tone somebody chose
 * for everyone. Flutter's audio plugins can only play bundled assets, so
 * the ringtone the user actually picked in Settings has to be resolved
 * and played here.
 *
 * Driven from `CallRingService` (frontend/lib/shared/chat/call_signaling)
 * over `care_connect/ringtone`: `start` takes a `volume` in 0..1 (the
 * caller's ringback is quieter than the callee's ring) and returns
 * whether it managed to play, so Dart can fall back to the bundled tone;
 * `stop` silences it and is safe to call when nothing is playing.
 */
class MainActivity : FlutterActivity() {
    private var ringtonePlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RINGTONE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val volume = (call.argument<Double>("volume") ?: 1.0).toFloat()
                        result.success(startRingtone(volume))
                    }
                    "stop" -> {
                        stopRingtone()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        stopRingtone()
        super.onDestroy()
    }

    private fun startRingtone(volume: Float): Boolean {
        // A second start replaces the first: only one call rings at a time.
        stopRingtone()
        val uri = defaultRingtoneUri() ?: return false
        return try {
            ringtonePlayer = MediaPlayer().apply {
                // The ringtone usage is what puts this on the phone's ring
                // stream, so the ring volume (not the media volume) governs
                // it and it still sounds while music is playing.
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                )
                setDataSource(applicationContext, uri)
                isLooping = true
                setVolume(volume, volume)
                // The ringtone is a local file, so preparing it is quick
                // enough to do inline and start ringing immediately.
                prepare()
                start()
            }
            true
        } catch (e: Exception) {
            // A silent-mode ringtone, a revoked media URI or a busy audio
            // route must never take the call itself down — report the
            // failure and let Dart ring with the bundled tone instead.
            stopRingtone()
            false
        }
    }

    private fun stopRingtone() {
        val player = ringtonePlayer ?: return
        ringtonePlayer = null
        try {
            if (player.isPlaying) player.stop()
        } catch (e: IllegalStateException) {
            // Already stopped or never prepared; releasing is all that's left.
        }
        player.release()
    }

    /**
     * The ringtone the user picked, falling back to the system default and
     * then to the notification sound. Any of these can be null — silent
     * ringtone, or a stale URI pointing at deleted media.
     */
    private fun defaultRingtoneUri(): Uri? =
        RingtoneManager.getActualDefaultRingtoneUri(this, RingtoneManager.TYPE_RINGTONE)
            ?: Settings.System.DEFAULT_RINGTONE_URI
            ?: RingtoneManager.getActualDefaultRingtoneUri(
                this,
                RingtoneManager.TYPE_NOTIFICATION,
            )

    private companion object {
        const val RINGTONE_CHANNEL = "care_connect/ringtone"
    }
}
