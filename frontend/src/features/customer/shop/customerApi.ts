import { CartItem, ShippingAddress, PaymentInfo, StoreProduct } from './customerTypes';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080';
const API_BASE = `${API_BASE_URL}/api`;

export type BackendCartResponse = {
  items: Array<{
    id: number;
    product: StoreProduct & { status: string; categoryId: number };
    quantity: number;
    lineTotal: number;
  }>;
  itemCount: number;
  subtotal: number;
};

export type BackendOrderResponse = {
  id: number;
  orderNumber: string;
  status: string;
  subtotal: number;
  shippingCost: number;
  tax: number;
  totalAmount: number;
  createdAt: string;
};

function headers(userEmail?: string): Record<string, string> {
  const h: Record<string, string> = { 'Content-Type': 'application/json' };
  if (userEmail) h['X-User-Email'] = userEmail;
  return h;
}

export async function fetchStoreProducts(): Promise<StoreProduct[]> {
  const res = await fetch(`${API_BASE}/products`);
  if (!res.ok) throw new Error(`Failed to load products: ${res.status}`);
  return res.json();
}

export async function fetchCart(userEmail: string): Promise<BackendCartResponse> {
  const res = await fetch(`${API_BASE}/cart`, { headers: headers(userEmail) });
  if (!res.ok) throw new Error(`Failed to load cart: ${res.status}`);
  return res.json();
}

export async function addToCartApi(userEmail: string, productId: number, quantity: number): Promise<BackendCartResponse> {
  const res = await fetch(`${API_BASE}/cart/items`, {
    method: 'POST',
    headers: headers(userEmail),
    body: JSON.stringify({ productId, quantity }),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error((err as any).message || `Failed to add to cart: ${res.status}`);
  }
  return res.json();
}

export async function updateCartItemApi(userEmail: string, productId: number, quantity: number): Promise<BackendCartResponse> {
  const res = await fetch(`${API_BASE}/cart/items/${productId}`, {
    method: 'PATCH',
    headers: headers(userEmail),
    body: JSON.stringify({ quantity }),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error((err as any).message || `Failed to update cart: ${res.status}`);
  }
  return res.json();
}

export async function removeCartItemApi(userEmail: string, productId: number): Promise<BackendCartResponse> {
  const res = await fetch(`${API_BASE}/cart/items/${productId}`, {
    method: 'DELETE',
    headers: headers(userEmail),
  });
  if (!res.ok) throw new Error(`Failed to remove from cart: ${res.status}`);
  return res.json();
}

export async function placeOrderApi(
  userEmail: string,
  shippingAddress: ShippingAddress,
  payment: PaymentInfo,
): Promise<BackendOrderResponse> {
  const res = await fetch(`${API_BASE}/orders/checkout`, {
    method: 'POST',
    headers: headers(userEmail),
    body: JSON.stringify({ shippingAddress, payment }),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error((err as any).message || `Checkout failed: ${res.status}`);
  }
  return res.json();
}

export function backendCartToLocalCart(backend: BackendCartResponse): CartItem[] {
  return backend.items.map((i) => ({ product: i.product as unknown as StoreProduct, quantity: i.quantity }));
}

export function getUserEmail(): string {
  const rawUser = localStorage.getItem('authUser');
  if (rawUser) {
    try {
      const user = JSON.parse(rawUser) as { email?: string };
      if (user.email) return user.email;
    } catch {
      // Fall back to the development customer below.
    }
  }

  return localStorage.getItem('userEmail') || 'customer@demo.com';
}
