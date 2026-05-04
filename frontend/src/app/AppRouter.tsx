import React from 'react';
import { BrowserRouter, useRoutes } from 'react-router-dom';
import { AuthProvider } from '../features/auth/AuthContext';
import { CartProvider } from '../features/customer/CartContext';
import { appRoutes } from './routes';

function AppRoutes() {
  return useRoutes(appRoutes);
}

export default function AppRouter() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <CartProvider>
          <AppRoutes />
        </CartProvider>
      </AuthProvider>
    </BrowserRouter>
  );
}
