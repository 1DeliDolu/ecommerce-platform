import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { Box, Button, Card, CardContent, Container, Typography } from '@mui/material';
import { Permission, UserRole } from './authTypes';
import { useAuth } from './AuthContext';

type RequireAuthProps = {
  roles?: UserRole[];
  permissions?: Permission[];
};

export default function RequireAuth({ roles, permissions }: RequireAuthProps) {
  const auth = useAuth();

  if (!auth.isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  const roleAllowed = !roles || auth.hasRole(roles);
  const permissionAllowed = !permissions || auth.hasAnyPermission(permissions);

  if (!roleAllowed || !permissionAllowed) {
    return (
      <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh', py: 8 }}>
        <Container maxWidth="md">
          <Card elevation={0} sx={{ borderRadius: 5, border: '1px solid', borderColor: 'divider' }}>
            <CardContent sx={{ p: 5, textAlign: 'center' }}>
              <Typography variant="h4" sx={{ fontWeight: 900 }} gutterBottom>
                Access Denied
              </Typography>
              <Typography color="text.secondary" sx={{ mb: 3 }}>
                Bu sayfaya erişmek için gerekli role veya permission yok.
              </Typography>
              <Button href="/" variant="contained">
                Go Home
              </Button>
            </CardContent>
          </Card>
        </Container>
      </Box>
    );
  }

  return <Outlet />;
}
