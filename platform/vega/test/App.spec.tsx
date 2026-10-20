import * as React from 'react';
import {fireEvent, render} from '@testing-library/react-native';
import {App} from '../src/App';

jest.mock('@amazon-devices/webview', () => ({
  WebView: 'WebView',
}));

jest.mock('@amazon-devices/react-native-kepler', () => ({
  usePreventHideSplashScreen: jest.fn(),
  useHideSplashScreenCallback: jest.fn(() => jest.fn()),
  useSetTimeoutCallback: jest.fn(() => jest.fn()),
  StyleSheet: {
    create: (styles: unknown) => styles,
    flatten: (style: unknown) =>
      Object.assign({}, ...(Array.isArray(style) ? style : [style])),
  },
  View: 'View',
  Text: 'Text',
}));

describe('App', () => {
  it('renders without crashing', () => {
    const {toJSON} = render(<App />);
    expect(toJSON()).toBeTruthy();
  });
  it('keeps loading visible until the engine reports a nonzero ready canvas', () => {
    const {getByTestId, getByText, queryByText} = render(<App />);
    const web = getByTestId('farm-webview');
    fireEvent(web, 'message', {nativeEvent: {data: 'not a startup report'}});
    expect(getByText('Starting the farm…')).toBeTruthy();
    fireEvent(web, 'message', {
      nativeEvent: {
        data: JSON.stringify({
          source: 'farm-startup',
          kind: 'canvas',
          ready: false,
          canvas: [0, 0],
          bounds: [0, 0],
          visibility: 'visible',
        }),
      },
    });
    expect(getByText('Starting the farm…')).toBeTruthy();
    fireEvent(web, 'message', {
      nativeEvent: {
        data: JSON.stringify({
          source: 'farm-startup',
          kind: 'canvas',
          ready: true,
          canvas: [1280, 720],
          bounds: [1280, 720],
          visibility: 'visible',
        }),
      },
    });
    expect(queryByText('Starting the farm…')).toBeNull();
    fireEvent(web, 'message', {
      nativeEvent: {
        data: JSON.stringify({
          source: 'farm-startup',
          kind: 'context-lost',
        }),
      },
    });
    expect(
      getByText('The farm could not start. Check the laptop host.'),
    ).toBeTruthy();
  });
  it('shows numeric performance samples without treating them as readiness', () => {
    const {getByTestId, getByText} = render(<App />);
    fireEvent(getByTestId('farm-webview'), 'message', {
      nativeEvent: {
        data: JSON.stringify({
          source: 'farm-startup', kind: 'performance', fps: 29.8,
          frame_p95_ms: 41,
        }),
      },
    });
    expect(getByText('Starting the farm…')).toBeTruthy();
    expect(getByText('Startup sample 29.8 fps; frame p95 41 ms')).toBeTruthy();
  });
  it('identifies missing WebGL2 instead of blaming the laptop connection', () => {
    const {getByTestId, getByText, queryByText} = render(<App />);
    fireEvent(getByTestId('farm-webview'), 'message', {
      nativeEvent: {
        data: JSON.stringify({
          source: 'farm-startup',
          kind: 'canvas',
          ready: false,
          message:
            'The following features required to run Godot projects on the Web are missing: WebGL2',
        }),
      },
    });
    expect(
      getByText(
        'This graphics environment cannot start the farm: WebGL2 is unavailable.',
      ),
    ).toBeTruthy();
    expect(
      queryByText('The farm could not start. Check the laptop host.'),
    ).toBeNull();
  });
});
