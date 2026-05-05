import React from 'react';
import { Navigate, RouteObject } from 'react-router-dom';

import MainLayout from './layouts/MainLayout';
import AdminLayout from './layouts/AdminLayout';

import HomePage from '../features/home/HomePage';
import CustomerProductsPage from '../features/customer/shop/CustomerProductsPage';
import CustomerProductDetailPage from '../features/customer/shop/CustomerProductDetailPage';
import CustomerCartPage from '../features/customer/cart/CustomerCartPage';
import CustomerCheckoutPage from '../features/customer/checkout/CustomerCheckoutPage';
import CustomerOrdersPage from '../features/customer/orders/CustomerOrdersPage';
import AdminCategoriesPage from '../features/admin/categories/AdminCategoriesPage';
import AdminProductsCrudPage from '../features/admin/products/AdminProductsCrudPage';
import AdminOrdersPage from '../features/admin/orders/AdminOrdersPage';
import AdminAuditLogsPage from '../features/admin/audit/AdminAuditLogsPage';

import LoginPage from '../features/auth/LoginPage';
import RegisterPage from '../features/auth/RegisterPage';
import ProfilePage from '../features/auth/ProfilePage';
import RequireAuth from '../features/auth/RequireAuth';

export const appRoutes: RouteObject[] = [
  {
    path: '/',
    element: <MainLayout />,
    children: [
      { index: true, element: <HomePage /> },
      { path: 'login', element: <LoginPage /> },
      { path: 'register', element: <RegisterPage /> },
      { path: 'products', element: <CustomerProductsPage /> },
      { path: 'products/:id', element: <CustomerProductDetailPage /> },
      {
        element: <RequireAuth />,
        children: [
          { path: 'cart', element: <CustomerCartPage /> },
          { path: 'orders', element: <CustomerOrdersPage /> },
          { path: 'checkout', element: <CustomerCheckoutPage /> },
          { path: 'profile', element: <ProfilePage /> },
        ],
      },
    ],
  },
  {
    path: '/admin',
    element: <MainLayout />,
    children: [
      {
        element: <RequireAuth roles={['ADMIN', 'EMPLOYEE', 'SECURITY_AUDITOR']} />,
        children: [
          {
            element: <AdminLayout />,
            children: [
              { index: true, element: <Navigate to="/admin/products" replace /> },
              {
                path: 'products',
                element: <RequireAuth roles={['ADMIN', 'EMPLOYEE']} permissions={['PRODUCT_READ']} />,
                children: [{ index: true, element: <AdminProductsCrudPage /> }],
              },
              {
                path: 'categories',
                element: <RequireAuth roles={['ADMIN', 'EMPLOYEE']} permissions={['CATEGORY_READ']} />,
                children: [{ index: true, element: <AdminCategoriesPage /> }],
              },
              {
                path: 'orders',
                element: <RequireAuth roles={['ADMIN']} permissions={['ORDER_READ_ALL']} />,
                children: [{ index: true, element: <AdminOrdersPage /> }],
              },
              {
                path: 'audit-logs',
                element: <RequireAuth roles={['ADMIN', 'SECURITY_AUDITOR']} permissions={['AUDIT_READ']} />,
                children: [{ index: true, element: <AdminAuditLogsPage /> }],
              },
            ],
          },
        ],
      },
    ],
  },
  { path: '*', element: <Navigate to="/" replace /> },
];
