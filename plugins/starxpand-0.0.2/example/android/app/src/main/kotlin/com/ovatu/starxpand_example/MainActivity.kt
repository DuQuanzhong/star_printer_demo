package com.ovatu.starxpand_example

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattServerCallback
import android.bluetooth.BluetoothManager
import android.content.pm.PackageManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import android.widget.Toast
import androidx.core.app.ActivityCompat


class MainActivity: FlutterActivity() {
    private var bluetoothAdapter: BluetoothAdapter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val bluetoothManager  = getSystemService(BLUETOOTH_SERVICE) as BluetoothManager
        if (bluetoothManager != null) {
            bluetoothAdapter = bluetoothManager.adapter
            if (bluetoothAdapter == null || !bluetoothAdapter!!.isEnabled) {
                // Prompt user to enable Bluetooth
            }
        }

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
            return
        }
        bluetoothManager.openGattServer(this@MainActivity, object : BluetoothGattServerCallback() {
            open fun onPhyUpdateBlue(gatt : BluetoothGatt, txPhy:Int, rxPhy:Int, status:Int) {

            }
        })

    }

}
