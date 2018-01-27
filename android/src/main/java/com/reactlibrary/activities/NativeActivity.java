package com.reactlibrary.activities;

import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactRootView;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.reactlibrary.R;
import com.reactlibrary.react.ReactAppCompatActivity;
import com.reactlibrary.util.TurbolinksRoute;

public class NativeActivity extends ReactAppCompatActivity {

    private static final String INTENT_INITIAL_VISIT = "intentInitialVisit";

    private TurbolinksRoute route;
    private Boolean initialVisit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        route = new TurbolinksRoute(getIntent());
        initialVisit = getIntent().getBooleanExtra(INTENT_INITIAL_VISIT, true);

        setContentView(R.layout.activity_native);
        renderToolBar();
        renderReactRootView();
    }

    @Override
    public void onBackPressed() {
        if (initialVisit) {
            moveTaskToBack(true);
        } else {
            if (!route.getModal()) super.onBackPressed();
        }
    }

    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.turbolinks_menu, menu);
        renderRightButton(menu);
        renderLeftButton(menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        WritableMap params = Arguments.createMap();
        params.putString("component", route.getComponent());
        params.putString("url", null);
        params.putString("path", null);
        if (item.getItemId() == R.id.action_left) {
            getEventEmitter().emit("turbolinksLeftButtonPress", params);
            return true;
        }
        if (item.getItemId() == R.id.action_right) {
            getEventEmitter().emit("turbolinksRightButtonPress", params);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void renderReactRootView() {
        ReactRootView mReactRootView = (ReactRootView) findViewById(R.id.native_view);
        ReactInstanceManager mReactInstanceManager = getReactInstanceManager();
        mReactRootView.startReactApplication(mReactInstanceManager, route.getComponent(), route.getPassProps());
    }

    private void renderToolBar() {
        Toolbar turbolinksToolbar = (Toolbar) findViewById(R.id.native_toolbar);
        setSupportActionBar(turbolinksToolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(!initialVisit);
        getSupportActionBar().setDisplayShowHomeEnabled(!initialVisit);
        getSupportActionBar().setTitle(route.getTitle());
        getSupportActionBar().setSubtitle(route.getSubtitle());
    }

    private void renderRightButton(Menu menu) {
        if (route.getRightButtonTitle() != null) {
            MenuItem menuItem =  menu.findItem(R.id.action_right);
            menuItem.setTitle(route.getRightButtonTitle());
            menuItem.setVisible(true);
        }
    }

    private void renderLeftButton(Menu menu) {
        if (route.getLeftButtonTitle() != null) {
            MenuItem menuItem = menu.findItem(R.id.action_left);
            menuItem.setTitle(route.getLeftButtonTitle());
            menuItem.setVisible(true);
        }
    }

    private DeviceEventManagerModule.RCTDeviceEventEmitter getEventEmitter() {
        return getReactInstanceManager().getCurrentReactContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class);
    }

}