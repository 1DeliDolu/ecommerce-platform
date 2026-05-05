import React from 'react';
import { NavLink, Outlet } from 'react-router-dom';
import { Box, Container, Paper, Stack, Typography } from '@mui/material';

export default function AdminLayout() {
  return (
    <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh' }}>
      <Box sx={{ bgcolor: '#0f172a', color: 'white', py: 3, mb: 4 }}>
        <Container maxWidth="xl">
          <Stack
            direction={{ xs: 'column', md: 'row' }}
            sx={{ justifyContent: 'space-between', alignItems: { xs: 'flex-start', md: 'center' } }}
            spacing={2}
          >
            <Box>
              <Typography variant="h5" sx={{ fontWeight: 900 }}>
                Admin Console
              </Typography>
              <Typography sx={{ color: 'rgba(255,255,255,0.65)' }}>
                Product, category, image and permission management
              </Typography>
            </Box>

            <Paper
              elevation={0}
              sx={{ p: 1, borderRadius: 3, bgcolor: 'rgba(255,255,255,0.08)' }}
            >
              <Stack direction="row" spacing={1} sx={{ flexWrap: 'wrap' }}>
                <NavLink
                  to="/admin/products"
                  className={({ isActive }) => isActive ? 'admin-tab admin-tab-active' : 'admin-tab'}
                >
                  Products
                </NavLink>
                <NavLink
                  to="/admin/categories"
                  className={({ isActive }) => isActive ? 'admin-tab admin-tab-active' : 'admin-tab'}
                >
                  Categories
                </NavLink>
                <NavLink
                  to="/admin/orders"
                  className={({ isActive }) => isActive ? 'admin-tab admin-tab-active' : 'admin-tab'}
                >
                  Orders
                </NavLink>
                <NavLink
                  to="/admin/audit-logs"
                  className={({ isActive }) => isActive ? 'admin-tab admin-tab-active' : 'admin-tab'}
                >
                  Audit Logs
                </NavLink>
              </Stack>
            </Paper>
          </Stack>
        </Container>
      </Box>

      <Outlet />
    </Box>
  );
}
