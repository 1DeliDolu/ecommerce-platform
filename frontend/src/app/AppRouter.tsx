import React from 'react';
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';

import ModernNavbar from '../components/ModernNavbar';
import HomePage from '../features/home/HomePage';
import AdminCategoriesPage from '../features/admin/categories/AdminCategoriesPage';
import AdminProductsCrudPage from '../features/admin/products/AdminProductsCrudPage';
import CustomerProductsPage from '../features/customer/shop/CustomerProductsPage';
import LoginPage from '../features/auth/LoginPage';
import { tokenStorage } from '../security/token-storage';

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  if (!tokenStorage.get()) {
    return <Navigate to="/login" replace />;
  }
  return <>{children}</>;
}

export default function AppRouter() {
  return (
    <BrowserRouter>
      <ModernNavbar />
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/shop" element={<CustomerProductsPage />} />
        <Route path="/products" element={<CustomerProductsPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route
          path="/admin/products"
          element={
            <ProtectedRoute>
              <AdminProductsCrudPage />
            </ProtectedRoute>
          }
        />
        <Route
          path="/admin/categories"
          element={
            <ProtectedRoute>
              <AdminCategoriesPage />
            </ProtectedRoute>
          }
        />
        <Route path="/admin" element={<Navigate to="/admin/products" replace />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
