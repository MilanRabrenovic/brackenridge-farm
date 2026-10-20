import {WebView} from '@amazon-devices/webview';
import * as React from 'react';
import {useEffect, useRef, useState} from 'react';
import {View, Text, StyleSheet} from 'react-native';
import {HOST_URL} from './host-config';
import {STARTUP_DIAGNOSTICS} from './startup-diagnostics';
import {
  useHideSplashScreenCallback,
  usePreventHideSplashScreen,
  useSetTimeoutCallback,
} from '@amazon-devices/react-native-kepler';
import {
  SslErrorData,
  WebViewErrorEvent,
  WebViewHttpErrorEvent,
  WebViewNavigationEvent,
} from '@amazon-devices/webview/dist/types/WebViewTypes';

export const App = () => {
  const webRef = useRef(null);
  const [startup, setStartup] = useState('Starting the farm…');
  const [diagnostic, setDiagnostic] = useState('Waiting for the game page');
  const setComponentTimeout = useSetTimeoutCallback();
  useEffect(() => {
    // Phone input does not count as TV remote activity. Allow the full weekend
    // and joining time before this app's component inactivity timeout.
    // This does not disable system sleep or guarantee a hardware wake lock.
    setComponentTimeout(30 * 60);
  }, [setComponentTimeout]);
  console.info('[Brackenridge startup] Host configured: ' + HOST_URL);
  // By default splash screen is shown in app launch, as the splash
  // screen images are bundled in this app (assets/raw/ folder)
  // Declare that application wants to extend splash screen lifecycle
  usePreventHideSplashScreen();
  const hideSplashScreenCallback = useHideSplashScreenCallback();
  return (
    <View style={styles.container}>
      <WebView
        ref={webRef}
        style={styles.webview}
        allowSystemKeyEvents
        allowsDefaultMediaControl
        domStorageEnabled
        hasTVPreferredFocus
        javaScriptEnabled
        mediaPlaybackRequiresUserAction={false}
        mixedContentMode="compatibility"
        testID="farm-webview"
        onMessage={(event) => {
          let report;
          try {
            report = JSON.parse(event.nativeEvent.data);
          } catch {
            return;
          }
          if (report.source !== 'farm-startup') {
            return;
          }
          console.info('[Brackenridge startup] ' + event.nativeEvent.data);
          if (
            typeof report.message === 'string' &&
            /webgl2/i.test(report.message)
          ) {
            setStartup(
              'This graphics environment cannot start the farm: WebGL2 is unavailable.',
            );
            setDiagnostic('WebGL2 unavailable');
            return;
          }
          if (
            report.kind === 'performance' &&
            Number.isFinite(report.fps) &&
            Number.isFinite(report.frame_p95_ms)
          ) {
            // Numeric, bounded local startup samples; visible in Debug only.
            setDiagnostic(
              `Startup sample ${report.fps} fps; frame p95 ${report.frame_p95_ms} ms`,
            );
          } else if (report.kind === 'canvas') {
            setDiagnostic(
              `Canvas ${report.canvas}; view ${report.bounds}; ready=${report.ready}; ${report.visibility}`,
            );
            if (report.message) {
              setStartup('The farm could not start. Check the laptop host.');
            } else if (report.ready === true) {
              setStartup('');
            }
          } else if (
            report.kind === 'error' ||
            report.kind === 'context-lost'
          ) {
            setStartup('The farm could not start. Check the laptop host.');
            setDiagnostic(report.kind);
          }
        }}
        injectedJavaScriptBeforeContentLoaded={STARTUP_DIAGNOSTICS}
        // thirdPartyCookiesEnabled
        // userAgent={''}
        source={{
          // headers: {},
          uri: HOST_URL,
        }}
        onLoad={(_event: WebViewNavigationEvent) => {
          console.info('Page loading completed...');
          // Hide the splash screen
          hideSplashScreenCallback();
        }}
        onLoadStart={(_event: WebViewNavigationEvent) => {
          setStartup('Starting the farm…');
          console.info('Page loading started...');
        }}
        onError={({
          nativeEvent: {code, url, description},
        }: WebViewErrorEvent) => {
          hideSplashScreenCallback();
          setStartup('The farm could not connect. Check the laptop host.');
          console.error(`[onError]: (${code}: ${url}) ${description}`);
        }}
        onHttpError={({
          nativeEvent: {url, statusCode: code, description, isMainFrame},
        }: WebViewHttpErrorEvent) => {
          if (isMainFrame) {
            hideSplashScreenCallback();
            setStartup('The farm could not connect. Check the laptop host.');
          }
          console.error(`[onHttpError]: (${code}: ${url}) ${description}`);
          console.error(`[onHttpError]: isMainFrame: ${isMainFrame}`);
        }}
        onSslError={({code, url, description}: SslErrorData) => {
          hideSplashScreenCallback();
          setStartup(
            'The farm could not connect securely. Check the host address.',
          );
          console.error(`[onSslError]: (${code}: ${url}) ${description}`);
        }}
      />
      {startup || __DEV__ ? (
        <View pointerEvents="none" style={styles.startup}>
          {startup ? <Text style={styles.status}>{startup}</Text> : null}
          {__DEV__ ? <Text style={styles.status}>{diagnostic}</Text> : null}
        </View>
      ) : null}
    </View>
  );
};

// Styles for layout, which are necessary for proper focus behavior
const styles = StyleSheet.create({
  container: {flex: 1},
  webview: {flex: 1, backgroundColor: '#142c22'},
  startup: {
    position: 'absolute',
    bottom: 12,
    left: 20,
    right: 20,
    backgroundColor: '#142c22',
    padding: 8,
  },
  status: {color: '#ffe8aa', fontSize: 18},
});
