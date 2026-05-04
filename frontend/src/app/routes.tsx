import React from 'react';
import { Navigate, RouteObject } from 'react-router-dom';

import MainLayout from './layouts/MainLayout';
import AdminLayout from './layouts/AdminLayout';

import HomePage from '../features/home/HomePage';
import CustomerProductsPage from '../features/customer/shop/CustomerProductsPage';
import CustomerOrdersPage from '../features/customer/orders/CustomerOrdersPage';
import AdminCategoriesPage from '../features/admin/categories/AdminCategoriesPage';
import AdminProductsCrudPage from '../features/admin/products/AdminProductsCrudPage';

import LoginPage from '../features/auth/LoginPage';
import RequireAuth from '../features/auth/RequireAuth';

export const appRoutes: RouteObject[] = [
  {
    path: '/',
    element: <MainLayout />,
    children: [
      { index: true, element: <HomePage /> },
      { path: 'login', element: <LoginPage /> },
      { path: 'products', element: <CustomerProductsPage /> },
      {
        element: <RequireAuth roles={['CUSTOMER', 'ADMIN', 'EMPLOYEE']} />,
        children: [
          { path: 'orders', element: <CustomerOrdersPage /> },
        ],
      },
      { path: 'profile', element: <Navigate to="/" replace /> },
    ],
  },
  {
    path: '/admin',
    element: <MainLayout />,
    children: [
      {
        element: <RequireAuth roles={['ADMIN', 'EMPLOYEE']} permissions={['ADMIN_PANEL_ACCESS']} />,
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
            ],
          },
        ],
      },
    ],
  },
  { path: '*', element: <Navigate to="/" replace /> },
];
