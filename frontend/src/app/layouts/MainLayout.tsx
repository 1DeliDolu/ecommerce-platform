import React from 'react';
import { Outlet } from 'react-router-dom';
import ModernNavbar from '../../components/ModernNavbar';

export default function MainLayout() {
  return (
    <>
      <ModernNavbar />
      <Outlet />
    </>
  );
}
