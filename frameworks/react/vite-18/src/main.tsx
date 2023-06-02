import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import { ErrorBoundary } from "@appsignal/react";
import './index.css'

import appsignal from "./appsignal.ts"

const FallbackComponent = () => (
  <div>An error was thrown</div>
);

const WrappedApp = () => (
  <ErrorBoundary
    instance={appsignal}
    fallback={(_error: any) => <FallbackComponent />}
  >
    <App />
  </ErrorBoundary>
);

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <WrappedApp />
  </React.StrictMode>,
)
