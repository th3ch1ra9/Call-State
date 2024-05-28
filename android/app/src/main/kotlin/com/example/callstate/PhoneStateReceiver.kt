package com.example.callstate
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log

class PhoneStateReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action.equals(TelephonyManager.ACTION_PHONE_STATE_CHANGED)) {
            val state = intent?.getStringExtra(TelephonyManager.EXTRA_STATE)
            when (state) {
                TelephonyManager.EXTRA_STATE_RINGING -> {
                    // Incoming call
                    Log.d("PhoneStateReceiver", "Incoming call")
                }
                TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                    // Call started
                    Log.d("PhoneStateReceiver", "Call started")
                }
                TelephonyManager.EXTRA_STATE_IDLE -> {
                    // Call ended
                    Log.d("PhoneStateReceiver", "Call ended")
                }
            }
        }
    }
}
