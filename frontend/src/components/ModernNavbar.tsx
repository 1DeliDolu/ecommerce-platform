import React, { useMemo, useState } from 'react';
import {
  AppBar,
  Avatar,
  Badge,
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
import DeleteForeverIcon from '@mui/icons-material/DeleteForever';
import HomeIcon from '@mui/icons-material/Home';
import Inventory2Icon from '@mui/icons-material/Inventory2';
import LoginIcon from '@mui/icons-material/Login';
import LogoutIcon from '@mui/icons-material/Logout';
import MenuIcon from '@mui/icons-material/Menu';
import ReceiptLongIcon from '@mui/icons-material/ReceiptLong';
import ShoppingBagIcon from '@mui/icons-material/ShoppingBag';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import ShoppingCartCheckoutIcon from '@mui/icons-material/ShoppingCartCheckout';
import StorefrontIcon from '@mui/icons-material/Storefront';
import { Link as RouterLink, NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../features/auth/AuthContext';
import { useCart } from '../features/customer/CartContext';

const PLACEHOLDER_IMG = 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=120';

type NavItem = {
  label: string;
  to: string;
  icon: React.ReactNode;
  visible: boolean;
};

export default function ModernNavbar() {
  const auth = useAuth();
  const navigate = useNavigate();
  const {
    cartItems,
    cartItemCount,
    cartTotal,
    cartDrawerOpen,
    openCartDrawer,
    closeCartDrawer,
    increaseQuantity,
    decreaseQuantity,
    removeFromCart,
  } = useCart();

  const [navDrawerOpen, setNavDrawerOpen] = useState(false);
  const [accountAnchor, setAccountAnchor] = useState<HTMLElement | null>(null);

  const adminVisible = auth.hasRole(['ADMIN']);

  const navItems = useMemo<NavItem[]>(
    () => [
      { label: 'Home', to: '/', icon: <HomeIcon />, visible: true },
      { label: 'Products', to: '/products', icon: <StorefrontIcon />, visible: true },
      { label: 'My Order', to: '/orders', icon: <ReceiptLongIcon />, visible: auth.isAuthenticated },
      { label: 'Admin Products', to: '/admin/products', icon: <Inventory2Icon />, visible: adminVisible },
      { label: 'Admin Categories', to: '/admin/categories', icon: <CategoryIcon />, visible: adminVisible },
    ],
    [adminVisible, auth]
  );

  const visibleItems = navItems.filter((item) => item.visible);

  const logout = () => {
    auth.logout();
    setAccountAnchor(null);
    setNavDrawerOpen(false);
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
            onClick={() => setNavDrawerOpen(true)}
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

            {/* Cart Icon Button */}
            <Tooltip title={`Sepet (${cartItemCount})`}>
              <IconButton onClick={openCartDrawer} aria-label="Sepeti aç" color="inherit">
                <Badge badgeContent={cartItemCount} color="error" max={99}>
                  <ShoppingCartIcon />
                </Badge>
              </IconButton>
            </Tooltip>

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

      {/* Mobile Nav Drawer */}
      <Drawer open={navDrawerOpen} onClose={() => setNavDrawerOpen(false)}>
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
                onClick={() => setNavDrawerOpen(false)}
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
            <Button fullWidth component={RouterLink} to="/login" variant="contained" startIcon={<LoginIcon />} onClick={() => setNavDrawerOpen(false)}>
              Login
            </Button>
          )}
        </Box>
      </Drawer>

      {/* Cart Drawer */}
      <Drawer
        anchor="right"
        open={cartDrawerOpen}
        onClose={closeCartDrawer}
        slotProps={{ paper: { sx: { width: { xs: '100%', sm: 420 } } } }}
      >
        <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
          {/* Header */}
          <Box sx={{ p: 2.5, borderBottom: '1px solid', borderColor: 'divider' }}>
            <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center' }}>
              <Stack direction="row" spacing={1} sx={{ alignItems: 'center' }}>
                <ShoppingCartIcon color="primary" />
                <Typography variant="h6" sx={{ fontWeight: 900 }}>Sepet</Typography>
                {cartItemCount > 0 && (
                  <Chip label={cartItemCount} size="small" color="primary" />
                )}
              </Stack>
              <Button size="small" onClick={closeCartDrawer} sx={{ color: 'text.secondary' }}>
                Kapat
              </Button>
            </Stack>
          </Box>

          {/* Cart Items */}
          <Box sx={{ flexGrow: 1, overflowY: 'auto', p: 2 }}>
            {cartItems.length === 0 ? (
              <Stack sx={{ alignItems: 'center', justifyContent: 'center', height: 200 }} spacing={2}>
                <ShoppingCartIcon sx={{ fontSize: 64, color: 'text.disabled' }} />
                <Typography color="text.secondary">Sepetin boş.</Typography>
                <Button variant="outlined" onClick={() => { closeCartDrawer(); navigate('/products'); }}>
                  Ürünlere Göz At
                </Button>
              </Stack>
            ) : (
              <Stack spacing={2}>
                {cartItems.map((item) => (
                  <Box key={item.product.id} sx={{ pb: 2, borderBottom: '1px solid', borderColor: 'divider' }}>
                    <Stack direction="row" spacing={1.5}>
                      <Box
                        component="img"
                        src={item.product.images[0]?.url || PLACEHOLDER_IMG}
                        alt={item.product.name}
                        onError={(e) => { (e.target as HTMLImageElement).src = PLACEHOLDER_IMG; }}
                        sx={{ width: 72, height: 72, objectFit: 'cover', borderRadius: 2, flexShrink: 0 }}
                      />
                      <Box sx={{ flexGrow: 1, minWidth: 0 }}>
                        <Typography sx={{ fontWeight: 800, fontSize: 14 }} noWrap>
                          {item.product.name}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          {item.product.categoryName}
                        </Typography>
                        <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mt: 0.5 }}>
                          <Typography variant="body2" color="primary" sx={{ fontWeight: 800 }}>
                            ₺{(item.product.price * item.quantity).toFixed(2)}
                          </Typography>
                          <Stack direction="row" spacing={0.5} sx={{ alignItems: 'center' }}>
                            <IconButton size="small" onClick={() => decreaseQuantity(item.product.id)}
                              sx={{ border: '1px solid', borderColor: 'divider', width: 26, height: 26 }}>
                              <Typography sx={{ lineHeight: 1, fontSize: 16 }}>−</Typography>
                            </IconButton>
                            <Typography sx={{ minWidth: 24, textAlign: 'center', fontWeight: 800 }}>
                              {item.quantity}
                            </Typography>
                            <IconButton size="small" onClick={() => increaseQuantity(item.product.id)}
                              sx={{ border: '1px solid', borderColor: 'divider', width: 26, height: 26 }}>
                              <Typography sx={{ lineHeight: 1, fontSize: 16 }}>+</Typography>
                            </IconButton>
                            <IconButton size="small" color="error" onClick={() => removeFromCart(item.product.id)}>
                              <DeleteForeverIcon fontSize="small" />
                            </IconButton>
                          </Stack>
                        </Stack>
                      </Box>
                    </Stack>
                  </Box>
                ))}
              </Stack>
            )}
          </Box>

          {/* Footer */}
          {cartItems.length > 0 && (
            <Box sx={{ p: 2.5, borderTop: '1px solid', borderColor: 'divider', bgcolor: 'background.paper' }}>
              <Stack direction="row" sx={{ justifyContent: 'space-between', mb: 2 }}>
                <Typography sx={{ fontWeight: 900 }}>Toplam</Typography>
                <Typography sx={{ fontWeight: 900, color: 'primary.main' }}>
                  ₺{cartTotal.toFixed(2)}
                </Typography>
              </Stack>
              <Button
                fullWidth
                variant="contained"
                size="large"
                startIcon={<ShoppingCartCheckoutIcon />}
                onClick={() => { closeCartDrawer(); navigate('/checkout'); }}
              >
                Ödemeye Geç
              </Button>
            </Box>
          )}
        </Box>
      </Drawer>
    </AppBar>
  );
}
