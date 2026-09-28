package com.eraprojects.era_wallet

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Wallet screens can expose balances, addresses, and recovery phrases.
        // Prevent screenshots and non-secure display mirroring in production.
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
