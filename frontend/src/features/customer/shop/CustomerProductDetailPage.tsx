import { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  CardMedia,
  Chip,
  CircularProgress,
  Container,
  Stack,
  Typography,
} from '@mui/material';
import AddShoppingCartIcon from '@mui/icons-material/AddShoppingCart';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import { Link as RouterLink, useParams } from 'react-router-dom';
import { useCart } from '../CartContext';
import { getStoreProduct } from '../api/customerApi';
import { StoreProduct } from './customerTypes';

const PLACEHOLDER_IMG = 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200';

export default function CustomerProductDetailPage() {
  const { id } = useParams();
  const { addToCart, cartLoading } = useCart();
  const [product, setProduct] = useState<StoreProduct | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadProduct() {
      try {
        setLoading(true);
        setProduct(await getStoreProduct(Number(id)));
      } catch (err: any) {
        setError(err.message || 'Product could not be loaded.');
      } finally {
        setLoading(false);
      }
    }

    loadProduct();
  }, [id]);

  const image = product?.images.find((img) => img.primary) ?? product?.images[0];

  return (
    <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh', py: 5 }}>
      <Container maxWidth="lg">
        <Button component={RouterLink} to="/products" startIcon={<ArrowBackIcon />} sx={{ mb: 2 }}>
          Products
        </Button>

        {loading && <CircularProgress />}
        {error && <Alert severity="error">{error}</Alert>}

        {product && (
          <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider', overflow: 'hidden' }}>
            <Stack direction={{ xs: 'column', md: 'row' }}>
              <CardMedia
                component="img"
                image={image?.url || PLACEHOLDER_IMG}
                alt={product.name}
                sx={{ width: { xs: '100%', md: 460 }, height: { xs: 300, md: 520 }, objectFit: 'cover' }}
              />
              <CardContent sx={{ p: { xs: 3, md: 5 }, flex: 1 }}>
                <Stack spacing={2}>
                  <Chip label={product.categoryName} sx={{ alignSelf: 'flex-start' }} />
                  <Typography variant="h3" sx={{ fontWeight: 900 }}>
                    {product.name}
                  </Typography>
                  <Typography color="text.secondary">{product.description}</Typography>
                  <Typography variant="h4" color="primary" sx={{ fontWeight: 900 }}>
                    ₺{product.price.toFixed(2)}
                  </Typography>
                  <Typography color="text.secondary">Stock: {product.stockQuantity}</Typography>
                  <Button
                    size="large"
                    variant="contained"
                    startIcon={<AddShoppingCartIcon />}
                    disabled={product.stockQuantity <= 0 || cartLoading}
                    onClick={() => addToCart(product)}
                  >
                    Add To Cart
                  </Button>
                </Stack>
              </CardContent>
            </Stack>
          </Card>
        )}
      </Container>
    </Box>
  );
}
