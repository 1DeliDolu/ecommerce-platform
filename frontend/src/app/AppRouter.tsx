import React from 'react';
import { BrowserRouter, useRoutes } from 'react-router-dom';
import { AuthProvider } from '../features/auth/AuthContext';
import { appRoutes } from './routes';

function AppRoutes() {
  return useRoutes(appRoutes);
}

export default function AppRouter() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </BrowserRouter>
  );
}
