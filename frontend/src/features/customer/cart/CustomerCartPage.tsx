import { useEffect } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  CardMedia,
  Container,
  IconButton,
  Stack,
  Typography,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import RemoveIcon from '@mui/icons-material/Remove';
import DeleteForeverIcon from '@mui/icons-material/DeleteForever';
import ShoppingCartCheckoutIcon from '@mui/icons-material/ShoppingCartCheckout';
import { Link as RouterLink } from 'react-router-dom';
import { useCart } from '../CartContext';

export default function CustomerCartPage() {
  const { cartItems, cartTotal, loadCart, increaseQuantity, decreaseQuantity, removeFromCart } = useCart();

  useEffect(() => {
    loadCart();
  }, [loadCart]);

  return (
    <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh', py: 5 }}>
      <Container maxWidth="lg">
        <Stack direction={{ xs: 'column', md: 'row' }} sx={{ justifyContent: 'space-between', mb: 3 }} spacing={2}>
          <Box>
            <Typography variant="h4" sx={{ fontWeight: 900 }}>Cart</Typography>
            <Typography color="text.secondary">Sepetini kontrol et ve checkout akışına geç.</Typography>
          </Box>
          <Button component={RouterLink} to="/checkout" variant="contained" startIcon={<ShoppingCartCheckoutIcon />} disabled={cartItems.length === 0}>
            Checkout ₺{cartTotal.toFixed(2)}
          </Button>
        </Stack>

        {cartItems.length === 0 ? (
          <Alert severity="info">Sepetin boş.</Alert>
        ) : (
          <Stack spacing={2}>
            {cartItems.map((item) => (
              <Card key={item.product.id} elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 3 }}>
                <CardContent>
                  <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} sx={{ alignItems: { sm: 'center' } }}>
                    <CardMedia component="img" image={item.product.images[0]?.url} alt={item.product.name} sx={{ width: 120, height: 92, objectFit: 'cover', borderRadius: 2 }} />
                    <Box sx={{ flex: 1 }}>
                      <Typography sx={{ fontWeight: 900 }}>{item.product.name}</Typography>
                      <Typography color="text.secondary">₺{item.product.price.toFixed(2)}</Typography>
                    </Box>
                    <Stack direction="row" spacing={1} sx={{ alignItems: 'center' }}>
                      <IconButton onClick={() => decreaseQuantity(item.product.id)}><RemoveIcon /></IconButton>
                      <Typography sx={{ minWidth: 28, textAlign: 'center', fontWeight: 900 }}>{item.quantity}</Typography>
                      <IconButton onClick={() => increaseQuantity(item.product.id)}><AddIcon /></IconButton>
                      <IconButton color="error" onClick={() => removeFromCart(item.product.id)}><DeleteForeverIcon /></IconButton>
                    </Stack>
                    <Typography sx={{ fontWeight: 900, minWidth: 100, textAlign: { sm: 'right' } }}>
                      ₺{(item.product.price * item.quantity).toFixed(2)}
                    </Typography>
                  </Stack>
                </CardContent>
              </Card>
            ))}
          </Stack>
        )}
      </Container>
    </Box>
  );
}
