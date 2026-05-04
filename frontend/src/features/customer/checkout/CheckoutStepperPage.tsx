import React, { useMemo, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  CircularProgress,
  Container,
  Divider,
  Grid,
  Step,
  StepButton,
  Stepper,
  Stack,
  TextField,
  Typography,
} from '@mui/material';

import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CreditCardIcon from '@mui/icons-material/CreditCard';
import LocalShippingIcon from '@mui/icons-material/LocalShipping';
import ReceiptLongIcon from '@mui/icons-material/ReceiptLong';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';

import { CartItem, PaymentInfo, ShippingAddress } from '../shop/customerTypes';
import { placeOrderApi } from '../shop/customerApi';

const STEPS = ['Sepet', 'Teslimat Adresi', 'Ödeme', 'Onay'];
const PLACEHOLDER_IMG = 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=300';

type Props = {
  cartItems: CartItem[];
  userEmail: string;
  onBackToShop: () => void;
  onIncreaseQuantity: (productId: number) => void;
  onDecreaseQuantity: (productId: number) => void;
  onRemoveFromCart: (productId: number) => void;
  onOrderCompleted: () => void;
};

const initialShipping: ShippingAddress = {
  fullName: '', email: '', phone: '', street: '', city: '', postalCode: '', country: 'Türkiye',
};

const initialPayment: PaymentInfo = {
  cardHolder: '', cardNumber: '', expiry: '', cvv: '',
};

export default function CheckoutStepperPage({
  cartItems, userEmail, onBackToShop, onIncreaseQuantity, onDecreaseQuantity, onRemoveFromCart, onOrderCompleted,
}: Props) {
  const [activeStep, setActiveStep] = useState(0);
  const [completed, setCompleted] = useState<Record<number, boolean>>({});
  const [shipping, setShipping] = useState<ShippingAddress>(initialShipping);
  const [payment, setPayment] = useState<PaymentInfo>(initialPayment);
  const [orderNumber, setOrderNumber] = useState<string | null>(null);
  const [orderTotal, setOrderTotal] = useState<number>(0);
  const [placing, setPlacing] = useState(false);
  const [placeError, setPlaceError] = useState<string | null>(null);

  const subtotal = useMemo(
    () => cartItems.reduce((s, i) => s + i.product.price * i.quantity, 0),
    [cartItems]
  );
  const shippingCost = subtotal > 500 || subtotal === 0 ? 0 : 49.9;
  const tax = subtotal * 0.18;
  const total = subtotal + shippingCost + tax;
  const allDone = Object.keys(completed).length === STEPS.length;

  const validate = (): boolean => {
    if (activeStep === 0) return cartItems.length > 0;
    if (activeStep === 1) {
      const fields: (keyof ShippingAddress)[] = ['fullName', 'email', 'phone', 'street', 'city', 'postalCode', 'country'];
      return fields.every((f) => shipping[f].trim() !== '');
    }
    if (activeStep === 2) {
      return payment.cardHolder.trim() !== '' && payment.cardNumber.trim() !== '' &&
        payment.expiry.trim() !== '' && payment.cvv.trim() !== '';
    }
    return true;
  };

  const completeStep = () => {
    if (!validate()) {
      alert(activeStep === 0 ? 'Sepet boş.' : activeStep === 1 ? 'Tüm teslimat alanlarını doldur.' : 'Tüm ödeme bilgilerini gir.');
      return;
    }
    setCompleted((c) => ({ ...c, [activeStep]: true }));
    if (activeStep < STEPS.length - 1) setActiveStep((s) => s + 1);
  };

  const placeOrder = async () => {
    if (!validate()) { alert('Tüm ödeme bilgilerini gir.'); return; }
    setPlacing(true);
    setPlaceError(null);
    try {
      const order = await placeOrderApi(userEmail, shipping, payment);
      setOrderNumber(order.orderNumber);
      setOrderTotal(order.totalAmount);
      setCompleted({ 0: true, 1: true, 2: true, 3: true });
      setActiveStep(3);
      onOrderCompleted();
    } catch (err: any) {
      setPlaceError(err.message);
    } finally {
      setPlacing(false);
    }
  };

  const handleShippingChange = (field: keyof ShippingAddress) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setShipping((s) => ({ ...s, [field]: e.target.value }));

  const handlePaymentChange = (field: keyof PaymentInfo) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setPayment((p) => ({ ...p, [field]: e.target.value }));

  return (
    <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh', py: 4 }}>
      <Container maxWidth="xl">
        <Stack
          direction={{ xs: 'column', md: 'row' }}
          sx={{ justifyContent: 'space-between', alignItems: { xs: 'stretch', md: 'center' }, mb: 4 }}
          spacing={2}
        >
          <Box>
            <Typography variant="h4" sx={{ fontWeight: 900 }}>Ödeme</Typography>
            <Typography color="text.secondary">Sepet → Adres → Ödeme → Onay</Typography>
          </Box>
          <Button variant="outlined" startIcon={<ArrowBackIcon />} onClick={onBackToShop}>
            Alışverişe Dön
          </Button>
        </Stack>

        <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider', mb: 4 }}>
          <CardContent>
            <Stepper nonLinear activeStep={activeStep}>
              {STEPS.map((label, i) => (
                <Step key={label} completed={completed[i]}>
                  <StepButton onClick={() => setActiveStep(i)}>{label}</StepButton>
                </Step>
              ))}
            </Stepper>
          </CardContent>
        </Card>

        <Grid container spacing={3}>
          <Grid size={{ xs: 12, lg: 8 }}>
            <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider' }}>
              <CardContent sx={{ p: { xs: 2, md: 4 } }}>
                {allDone && orderNumber ? (
                  <OrderCompletedView orderNumber={orderNumber} total={orderTotal} onBackToShop={onBackToShop} />
                ) : (
                  <>
                    {activeStep === 0 && (
                      <CartReviewStep
                        cartItems={cartItems}
                        onIncrease={onIncreaseQuantity}
                        onDecrease={onDecreaseQuantity}
                        onRemove={onRemoveFromCart}
                      />
                    )}
                    {activeStep === 1 && <ShippingStep shipping={shipping} onChange={handleShippingChange} />}
                    {activeStep === 2 && <PaymentStep payment={payment} onChange={handlePaymentChange} />}
                    {activeStep === 3 && (
                      <ConfirmationStep cartItems={cartItems} shipping={shipping} payment={payment} total={total} />
                    )}

                    {placeError && <Alert severity="error" sx={{ mt: 2 }}>{placeError}</Alert>}

                    <Divider sx={{ my: 4 }} />

                    <Stack direction="row" sx={{ justifyContent: 'space-between' }}>
                      <Button color="inherit" disabled={activeStep === 0 || placing} onClick={() => setActiveStep((s) => Math.max(0, s - 1))}>
                        Geri
                      </Button>
                      <Stack direction="row" spacing={2}>
                        {activeStep < STEPS.length - 1 && (
                          <>
                            <Button variant="outlined" onClick={completeStep} disabled={placing}>Adımı Tamamla</Button>
                            <Button variant="contained" onClick={completeStep} disabled={placing}>İleri</Button>
                          </>
                        )}
                        {activeStep === STEPS.length - 1 && (
                          <Button
                            variant="contained"
                            color="success"
                            startIcon={placing ? <CircularProgress size={18} color="inherit" /> : <CheckCircleIcon />}
                            onClick={placeOrder}
                            disabled={placing}
                          >
                            {placing ? 'İşleniyor...' : 'Siparişi Ver'}
                          </Button>
                        )}
                      </Stack>
                    </Stack>
                  </>
                )}
              </CardContent>
            </Card>
          </Grid>

          <Grid size={{ xs: 12, lg: 4 }}>
            <OrderSummaryCard subtotal={subtotal} shippingCost={shippingCost} tax={tax} total={total} />
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
}

function CartReviewStep({ cartItems, onIncrease, onDecrease, onRemove }: {
  cartItems: CartItem[];
  onIncrease: (id: number) => void;
  onDecrease: (id: number) => void;
  onRemove: (id: number) => void;
}) {
  return (
    <Box>
      <Stack direction="row" sx={{ alignItems: 'center', mb: 3 }} spacing={1}>
        <ShoppingCartIcon color="primary" />
        <Typography variant="h5" sx={{ fontWeight: 900 }}>Sepet</Typography>
      </Stack>

      {cartItems.length === 0 ? (
        <Alert severity="warning">Sepetin boş.</Alert>
      ) : (
        <Stack spacing={2}>
          {cartItems.map((item) => (
            <Card key={item.product.id} variant="outlined" sx={{ borderRadius: 3 }}>
              <CardContent>
                <Stack direction={{ xs: 'column', sm: 'row' }} sx={{ alignItems: 'center' }} spacing={2}>
                  <Box
                    component="img"
                    src={item.product.images[0]?.url ? `/uploads/${item.product.images[0].url}` : PLACEHOLDER_IMG}
                    alt={item.product.name}
                    sx={{ width: 100, height: 80, objectFit: 'cover', borderRadius: 2 }}
                  />
                  <Box sx={{ flexGrow: 1 }}>
                    <Typography sx={{ fontWeight: 900 }}>{item.product.name}</Typography>
                    <Typography color="text.secondary">{item.product.categoryName}</Typography>
                    <Typography sx={{ fontWeight: 800 }}>₺{item.product.price.toFixed(2)}</Typography>
                  </Box>
                  <Stack direction="row" sx={{ alignItems: 'center' }} spacing={1}>
                    <Button variant="outlined" onClick={() => onDecrease(item.product.id)} sx={{ minWidth: 36 }}>−</Button>
                    <Button variant="outlined" disabled sx={{ minWidth: 36 }}>{item.quantity}</Button>
                    <Button variant="outlined" onClick={() => onIncrease(item.product.id)} sx={{ minWidth: 36 }}>+</Button>
                    <Button color="error" onClick={() => onRemove(item.product.id)}>Sil</Button>
                  </Stack>
                </Stack>
              </CardContent>
            </Card>
          ))}
        </Stack>
      )}
    </Box>
  );
}

function ShippingStep({ shipping, onChange }: {
  shipping: ShippingAddress;
  onChange: (f: keyof ShippingAddress) => (e: React.ChangeEvent<HTMLInputElement>) => void;
}) {
  return (
    <Box>
      <Stack direction="row" sx={{ alignItems: 'center', mb: 3 }} spacing={1}>
        <LocalShippingIcon color="primary" />
        <Typography variant="h5" sx={{ fontWeight: 900 }}>Teslimat Adresi</Typography>
      </Stack>
      <Grid container spacing={3}>
        <Grid size={{ xs: 12, md: 6 }}><TextField fullWidth label="Ad Soyad" value={shipping.fullName} onChange={onChange('fullName')} /></Grid>
        <Grid size={{ xs: 12, md: 6 }}><TextField fullWidth label="E-posta" value={shipping.email} onChange={onChange('email')} /></Grid>
        <Grid size={{ xs: 12, md: 6 }}><TextField fullWidth label="Telefon" value={shipping.phone} onChange={onChange('phone')} /></Grid>
        <Grid size={{ xs: 12, md: 6 }}><TextField fullWidth label="Ülke" value={shipping.country} onChange={onChange('country')} /></Grid>
        <Grid size={{ xs: 12 }}><TextField fullWidth label="Adres" value={shipping.street} onChange={onChange('street')} /></Grid>
        <Grid size={{ xs: 12, md: 6 }}><TextField fullWidth label="Şehir" value={shipping.city} onChange={onChange('city')} /></Grid>
        <Grid size={{ xs: 12, md: 6 }}><TextField fullWidth label="Posta Kodu" value={shipping.postalCode} onChange={onChange('postalCode')} /></Grid>
      </Grid>
    </Box>
  );
}

function PaymentStep({ payment, onChange }: {
  payment: PaymentInfo;
  onChange: (f: keyof PaymentInfo) => (e: React.ChangeEvent<HTMLInputElement>) => void;
}) {
  return (
    <Box>
      <Stack direction="row" sx={{ alignItems: 'center', mb: 3 }} spacing={1}>
        <CreditCardIcon color="primary" />
        <Typography variant="h5" sx={{ fontWeight: 900 }}>Ödeme</Typography>
      </Stack>
      <Alert severity="info" sx={{ mb: 3 }}>Demo ödeme ekranı — gerçek kart bilgisi girme.</Alert>
      <Grid container spacing={3}>
        <Grid size={{ xs: 12 }}><TextField fullWidth label="Kart Sahibi" value={payment.cardHolder} onChange={onChange('cardHolder')} /></Grid>
        <Grid size={{ xs: 12 }}><TextField fullWidth label="Kart Numarası" placeholder="4242 4242 4242 4242" value={payment.cardNumber} onChange={onChange('cardNumber')} /></Grid>
        <Grid size={{ xs: 12, md: 6 }}><TextField fullWidth label="Son Kullanma" placeholder="12/29" value={payment.expiry} onChange={onChange('expiry')} /></Grid>
        <Grid size={{ xs: 12, md: 6 }}><TextField fullWidth label="CVV" placeholder="123" value={payment.cvv} onChange={onChange('cvv')} /></Grid>
      </Grid>
    </Box>
  );
}

function ConfirmationStep({ cartItems, shipping, payment, total }: {
  cartItems: CartItem[];
  shipping: ShippingAddress;
  payment: PaymentInfo;
  total: number;
}) {
  return (
    <Box>
      <Stack direction="row" sx={{ alignItems: 'center', mb: 3 }} spacing={1}>
        <ReceiptLongIcon color="primary" />
        <Typography variant="h5" sx={{ fontWeight: 900 }}>Sipariş Özeti</Typography>
      </Stack>
      <Grid container spacing={3}>
        <Grid size={{ xs: 12, md: 6 }}>
          <Card variant="outlined" sx={{ borderRadius: 3 }}>
            <CardContent>
              <Typography sx={{ fontWeight: 900 }} gutterBottom>Teslimat</Typography>
              <Typography>{shipping.fullName}</Typography>
              <Typography color="text.secondary">{shipping.email}</Typography>
              <Typography color="text.secondary">{shipping.phone}</Typography>
              <Typography color="text.secondary">
                {shipping.street}, {shipping.postalCode} {shipping.city}, {shipping.country}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid size={{ xs: 12, md: 6 }}>
          <Card variant="outlined" sx={{ borderRadius: 3 }}>
            <CardContent>
              <Typography sx={{ fontWeight: 900 }} gutterBottom>Ödeme</Typography>
              <Typography>{payment.cardHolder}</Typography>
              <Typography color="text.secondary">**** **** **** {payment.cardNumber.slice(-4) || '----'}</Typography>
              <Typography color="text.secondary">Toplam: ₺{total.toFixed(2)}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid size={{ xs: 12 }}>
          <Card variant="outlined" sx={{ borderRadius: 3 }}>
            <CardContent>
              <Typography sx={{ fontWeight: 900 }} gutterBottom>Ürünler</Typography>
              <Stack spacing={1}>
                {cartItems.map((item) => (
                  <Stack key={item.product.id} direction="row" sx={{ justifyContent: 'space-between' }}>
                    <Typography>{item.product.name} × {item.quantity}</Typography>
                    <Typography sx={{ fontWeight: 800 }}>₺{(item.product.price * item.quantity).toFixed(2)}</Typography>
                  </Stack>
                ))}
              </Stack>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}

function OrderSummaryCard({ subtotal, shippingCost, tax, total }: {
  subtotal: number; shippingCost: number; tax: number; total: number;
}) {
  return (
    <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider', position: { lg: 'sticky' }, top: { lg: 24 } }}>
      <CardContent>
        <Typography variant="h6" sx={{ fontWeight: 900 }} gutterBottom>Sipariş Özeti</Typography>
        <Stack spacing={2}>
          <SummaryRow label="Ara Toplam" value={subtotal} />
          <SummaryRow label={subtotal > 500 ? 'Kargo (Ücretsiz)' : 'Kargo'} value={shippingCost} />
          <SummaryRow label="KDV %18" value={tax} />
          <Divider />
          <Stack direction="row" sx={{ justifyContent: 'space-between' }}>
            <Typography sx={{ fontWeight: 900 }}>Toplam</Typography>
            <Typography sx={{ fontWeight: 900 }}>₺{total.toFixed(2)}</Typography>
          </Stack>
        </Stack>
      </CardContent>
    </Card>
  );
}

function SummaryRow({ label, value }: { label: string; value: number }) {
  return (
    <Stack direction="row" sx={{ justifyContent: 'space-between' }}>
      <Typography color="text.secondary">{label}</Typography>
      <Typography sx={{ fontWeight: 800 }}>₺{value.toFixed(2)}</Typography>
    </Stack>
  );
}

function OrderCompletedView({ orderNumber, total, onBackToShop }: {
  orderNumber: string; total: number; onBackToShop: () => void;
}) {
  return (
    <Box sx={{ textAlign: 'center', py: 6 }}>
      <CheckCircleIcon color="success" sx={{ fontSize: 80, mb: 2 }} />
      <Typography variant="h4" sx={{ fontWeight: 900 }} gutterBottom>Sipariş Tamamlandı!</Typography>
      <Typography color="text.secondary" sx={{ mb: 3 }}>Siparişin başarıyla oluşturuldu.</Typography>
      <Card variant="outlined" sx={{ maxWidth: 420, mx: 'auto', borderRadius: 3, mb: 4 }}>
        <CardContent>
          <Typography color="text.secondary">Sipariş Numarası</Typography>
          <Typography sx={{ fontWeight: 900 }}>{orderNumber}</Typography>
          <Divider sx={{ my: 2 }} />
          <Typography color="text.secondary">Ödenen Tutar</Typography>
          <Typography sx={{ fontWeight: 900 }}>₺{total.toFixed(2)}</Typography>
        </CardContent>
      </Card>
      <Button variant="contained" size="large" onClick={onBackToShop}>Alışverişe Devam Et</Button>
    </Box>
  );
}
