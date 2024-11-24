package com.example.women_safety_app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.util.Log;

public class LockButtonReceiver extends BroadcastReceiver {
    private static final String TAG = "LockButtonReceiver";
    private static final int TRIPLE_PRESS_THRESHOLD = 2000; // 2 seconds
    private static int pressCount = 0;
    private static long lastPressTime = 0;

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();

        if (action != null && (action.equals(Intent.ACTION_SCREEN_ON) || action.equals(Intent.ACTION_SCREEN_OFF))) {
            long currentTime = System.currentTimeMillis();

            if (currentTime - lastPressTime <= TRIPLE_PRESS_THRESHOLD) {
                pressCount++;
            } else {
                pressCount = 1; // Reset if too much time passed
            }

            lastPressTime = currentTime;

            if (pressCount == 3) {
                Log.d(TAG, "Triple press detected!");
                startAudioRecordingService(context);
                pressCount = 0; // Reset press count after triggering
            }
        }
    }

    private void startAudioRecordingService(Context context) {
        Intent serviceIntent = new Intent(context, AudioRecordingService.class);
        context.startForegroundService(serviceIntent); // Ensure foreground service for Android 8+
    }
}
