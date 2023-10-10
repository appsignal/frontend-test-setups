import React from 'react';
// import ReactDOM from 'react-dom/client';
import ReactDOM from 'react-dom';
import { ErrorBoundary } from "@appsignal/react";
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';
import { store } from './store';
import { Provider } from 'react-redux';

import appsignal from "./appsignal.js"

const FallbackComponent = () => (
  <div>An error was thrown</div>
);

const WrappedApp = () => (
  <ErrorBoundary
    instance={appsignal}
  >
    <Provider store={store}>
      <App />
    </Provider>
  </ErrorBoundary>
);

ReactDOM.render(
  <React.StrictMode>
    <WrappedApp />
  </React.StrictMode>,
  document.getElementById('root')
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
