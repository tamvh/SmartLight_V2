package com.vng.gbc;
import android.content.Intent;
import android.content.Context;
import android.content.BroadcastReceiver;


/**
 * Created by tamvh on 10/17/17.
 */
public class BootUpReceiver extends BroadcastReceiver{
    @Override
    public void onReceive(Context context, Intent intent) {
        Intent i = new Intent(context, MyActivity.class);
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(i);
    }

}
