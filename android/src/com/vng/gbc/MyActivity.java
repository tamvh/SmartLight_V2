package com.vng.gbc;

import android.os.Bundle;
import android.util.Log;

/*
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.widget.TextView;
import android.widget.Button;
*/

import android.widget.Toast;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;

import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbEndpoint;
import android.hardware.usb.UsbInterface;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;

import com.hoho.android.usbserial.driver.UsbSerialDriver;
import com.hoho.android.usbserial.driver.UsbSerialPort;
import com.hoho.android.usbserial.driver.UsbSerialProber;
import com.hoho.android.usbserial.util.HexDump;
import com.hoho.android.usbserial.util.SerialInputOutputManager;

import java.util.ArrayList;
import java.util.List;
import java.io.IOException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import com.wordpress.ebc81.esc_pos_android.ReceiptESCPrinter;

import org.qtproject.qt5.android.bindings.QtActivity;

public class MyActivity extends org.qtproject.qt5.android.bindings.QtActivity
{
    private final String TAG = MyActivity.class.getSimpleName();

    //private View decorView;
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.v(TAG, "My activity started !!!");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

}
