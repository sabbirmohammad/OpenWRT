package com.archerguard.openwrt

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.viewmodel.compose.viewModel
import com.archerguard.openwrt.core.datastore.PreferencesRepository
import com.archerguard.openwrt.ui.navigation.ArcherNavHost
import com.archerguard.openwrt.ui.theme.ArcherGuardTheme
import com.archerguard.openwrt.ui.viewmodel.RouterViewModel

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val preferencesRepository = PreferencesRepository(applicationContext)

        setContent {
            ArcherGuardTheme {
                val viewModel: RouterViewModel = viewModel {
                    RouterViewModel(preferencesRepository)
                }
                ArcherNavHost(viewModel = viewModel)
            }
        }
    }
}
