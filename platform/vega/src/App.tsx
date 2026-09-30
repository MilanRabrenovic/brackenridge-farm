import {WebView} from '@amazon-devices/webview';
import * as React from 'react';
import {useEffect, useRef} from 'react';
import {View, StyleSheet} from 'react-native';
import {HOST_URL} from './host-config';
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
        onMessage={event => console.info('[Brackenridge startup] ' + event.nativeEvent.data)}
        injectedJavaScriptBeforeContentLoaded={`
          window.addEventListener('error', event => window.ReactNativeWebView.postMessage('Error: ' + event.message));
          window.addEventListener('unhandledrejection', event => window.ReactNativeWebView.postMessage('Rejection: ' + String(event.reason)));
          window.addEventListener('load', () => {
            window.ReactNativeWebView.postMessage('Document loaded; WebAssembly=' + !!window.WebAssembly);
            setTimeout(() => window.ReactNativeWebView.postMessage('Status: ' + (document.querySelector('#status-notice')?.textContent || 'no failure notice')), 15000);
          }); true;
        `}
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
          console.info('Page loading started...');
        }}
        onError={({
          nativeEvent: {code, url, description},
        }: WebViewErrorEvent) => {
          console.error(`[onError]: (${code}: ${url}) ${description}`);
        }}
        onHttpError={({
          nativeEvent: {url, statusCode: code, description, isMainFrame},
        }: WebViewHttpErrorEvent) => {
          console.error(`[onHttpError]: (${code}: ${url}) ${description}`);
          console.error(`[onHttpError]: isMainFrame: ${isMainFrame}`);
        }}
        onSslError={({code, url, description}: SslErrorData) => {
          console.error(`[onSslError]: (${code}: ${url}) ${description}`);
        }}
      />
    </View>
  );
};

// Styles for layout, which are necessary for proper focus behavior
const styles = StyleSheet.create({
  container: {flex: 1},
  webview: {flex: 1, backgroundColor: '#142c22'},
});
