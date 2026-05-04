import React, { useMemo, useState } from 'react';
import {
  AppBar,
  Avatar,
  Box,
  Button,
  Chip,
  Container,
  Divider,
  Drawer,
  IconButton,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Menu,
  MenuItem,
  Stack,
  Toolbar,
  Tooltip,
  Typography,
} from '@mui/material';
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings';
import CategoryIcon from '@mui/icons-material/Category';
import HomeIcon from '@mui/icons-material/Home';
import Inventory2Icon from '@mui/icons-material/Inventory2';
import LoginIcon from '@mui/icons-material/Login';
import LogoutIcon from '@mui/icons-material/Logout';
import MenuIcon from '@mui/icons-material/Menu';
import ReceiptLongIcon from '@mui/icons-material/ReceiptLong';
import ShoppingBagIcon from '@mui/icons-material/ShoppingBag';
import StorefrontIcon from '@mui/icons-material/Storefront';
import { Link as RouterLink, NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../features/auth/AuthContext';

type NavItem = {
  label: string;
  to: string;
  icon: React.ReactNode;
  visible: boolean;
};

export default function ModernNavbar() {
  const auth = useAuth();
  const navigate = useNavigate();
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [accountAnchor, setAccountAnchor] = useState<HTMLElement | null>(null);

  const adminVisible = auth.hasAnyPermission(['PRODUCT_READ', 'CATEGORY_READ']);

  const navItems = useMemo<NavItem[]>(
    () => [
      { label: 'Home', to: '/', icon: <HomeIcon />, visible: true },
      { label: 'Products', to: '/products', icon: <StorefrontIcon />, visible: true },
      { label: 'Checkout', to: '/checkout', icon: <ShoppingBagIcon />, visible: auth.isAuthenticated },
      { label: 'Orders', to: '/orders', icon: <ReceiptLongIcon />, visible: auth.isAuthenticated },
      { label: 'Admin Products', to: '/admin/products', icon: <Inventory2Icon />, visible: auth.hasPermission('PRODUCT_READ') },
      { label: 'Admin Categories', to: '/admin/categories', icon: <CategoryIcon />, visible: auth.hasPermission('CATEGORY_READ') },
    ],
    [auth]
  );

  const visibleItems = navItems.filter((item) => item.visible);

  const logout = () => {
    auth.logout();
    setAccountAnchor(null);
    setDrawerOpen(false);
    navigate('/');
  };

  return (
    <AppBar
      position="sticky"
      elevation={0}
      sx={{
        bgcolor: 'rgba(255,255,255,0.92)',
        color: 'text.primary',
        borderBottom: '1px solid',
        borderColor: 'divider',
        backdropFilter: 'blur(16px)',
      }}
    >
      <Container maxWidth="xl">
        <Toolbar disableGutters sx={{ minHeight: 72, gap: 2 }}>
          <IconButton
            edge="start"
            sx={{ display: { xs: 'inline-flex', lg: 'none' } }}
            onClick={() => setDrawerOpen(true)}
            aria-label="Open navigation"
          >
            <MenuIcon />
          </IconButton>

          <Stack
            component={RouterLink}
            to="/"
            direction="row"
            spacing={1.25}
            sx={{ alignItems: 'center', color: 'inherit', textDecoration: 'none', minWidth: { lg: 240 } }}
          >
            <Avatar sx={{ bgcolor: '#111827', width: 42, height: 42 }}>
              <ShoppingBagIcon />
            </Avatar>
            <Box>
              <Typography sx={{ fontWeight: 900, lineHeight: 1 }}>Enterprise Shop</Typography>
              <Typography variant="caption" color="text.secondary">Java 25 commerce lab</Typography>
            </Box>
          </Stack>

          <Stack
            direction="row"
            spacing={0.5}
            sx={{ display: { xs: 'none', lg: 'flex' }, alignItems: 'center', flexGrow: 1 }}
          >
            {visibleItems.slice(0, adminVisible ? visibleItems.length : 3).map((item) => (
              <Button
                key={item.to}
                component={NavLink}
                to={item.to}
                startIcon={item.icon}
                sx={{
                  color: 'text.secondary',
                  borderRadius: 2,
                  px: 1.5,
                  '&.active': {
                    color: 'primary.main',
                    bgcolor: 'action.selected',
                  },
                }}
              >
                {item.label}
              </Button>
            ))}
          </Stack>

          <Stack direction="row" spacing={1} sx={{ alignItems: 'center', ml: 'auto' }}>
            {auth.isAuthenticated && (
              <Chip
                icon={<AdminPanelSettingsIcon />}
                label={auth.user?.role}
                variant="outlined"
                sx={{ display: { xs: 'none', sm: 'inline-flex' }, fontWeight: 800 }}
              />
            )}

            {auth.isAuthenticated ? (
              <>
                <Tooltip title="Account">
                  <IconButton onClick={(event) => setAccountAnchor(event.currentTarget)} aria-label="Account menu">
                    <Avatar sx={{ width: 36, height: 36, bgcolor: 'primary.main', fontSize: 14 }}>
                      {auth.user?.fullName?.slice(0, 1).toUpperCase() ?? 'U'}
                    </Avatar>
                  </IconButton>
                </Tooltip>
                <Menu
                  anchorEl={accountAnchor}
                  open={Boolean(accountAnchor)}
                  onClose={() => setAccountAnchor(null)}
                  anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
                  transformOrigin={{ vertical: 'top', horizontal: 'right' }}
                >
                  <Box sx={{ px: 2, py: 1 }}>
                    <Typography sx={{ fontWeight: 900 }}>{auth.user?.fullName}</Typography>
                    <Typography variant="body2" color="text.secondary">{auth.user?.email}</Typography>
                  </Box>
                  <Divider />
                  <MenuItem component={RouterLink} to="/orders" onClick={() => setAccountAnchor(null)}>
                    <ListItemIcon><ReceiptLongIcon fontSize="small" /></ListItemIcon>
                    My Orders
                  </MenuItem>
                  <MenuItem onClick={logout}>
                    <ListItemIcon><LogoutIcon fontSize="small" /></ListItemIcon>
                    Logout
                  </MenuItem>
                </Menu>
              </>
            ) : (
              <Button component={RouterLink} to="/login" variant="contained" startIcon={<LoginIcon />}>
                Login
              </Button>
            )}
          </Stack>
        </Toolbar>
      </Container>

      <Drawer open={drawerOpen} onClose={() => setDrawerOpen(false)}>
        <Box sx={{ width: 300, p: 2 }}>
          <Stack direction="row" spacing={1.25} sx={{ alignItems: 'center', mb: 2 }}>
            <Avatar sx={{ bgcolor: '#111827' }}><ShoppingBagIcon /></Avatar>
            <Box>
              <Typography sx={{ fontWeight: 900 }}>Enterprise Shop</Typography>
              <Typography variant="caption" color="text.secondary">Navigation</Typography>
            </Box>
          </Stack>
          <Divider />
          <List>
            {visibleItems.map((item) => (
              <ListItemButton
                key={item.to}
                component={NavLink}
                to={item.to}
                onClick={() => setDrawerOpen(false)}
                sx={{ borderRadius: 2, my: 0.5, '&.active': { bgcolor: 'action.selected', color: 'primary.main' } }}
              >
                <ListItemIcon sx={{ color: 'inherit' }}>{item.icon}</ListItemIcon>
                <ListItemText primary={item.label} />
              </ListItemButton>
            ))}
          </List>
          <Divider sx={{ my: 1 }} />
          {auth.isAuthenticated ? (
            <Button fullWidth color="error" startIcon={<LogoutIcon />} onClick={logout}>
              Logout
            </Button>
          ) : (
            <Button fullWidth component={RouterLink} to="/login" variant="contained" startIcon={<LoginIcon />} onClick={() => setDrawerOpen(false)}>
              Login
            </Button>
          )}
        </Box>
      </Drawer>
    </AppBar>
  );
}
