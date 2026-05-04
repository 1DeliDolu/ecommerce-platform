import React from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap-icons/font/bootstrap-icons.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import './styles.css';
import ModernNavbar from './components/ModernNavbar';
import AdminProductsCrudPage from './features/admin/products/AdminProductsCrudPage';
import AdminCategoriesPage from './features/admin/categories/AdminCategoriesPage';
import HomePage from './features/home/HomePage';
import LoginPage from './features/auth/LoginPage';
import { tokenStorage } from './security/token-storage';

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  if (!tokenStorage.get()) {
    return <Navigate to="/login" replace />;
  }
  return <>{children}</>;
}

function AppLayout() {
  return (
    <>
      <ModernNavbar />
      <Routes>
        <Route path="/" element={<HomePage health="" productCount={0} onLoginAsAdmin={() => {}} />} />
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
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </>
  );
}

createRoot(document.getElementById('root')!).render(
  <BrowserRouter>
    <AppLayout />
  </BrowserRouter>
);
