import { CartItem, CustomerOrder, PaymentInfo, ShippingAddress, StoreProduct } from '../shop/customerTypes';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080';

function getCustomerEmail(): string {
  const rawUser = localStorage.getItem('authUser');
  if (rawUser) {
    try {
      const user = JSON.parse(rawUser) as { email?: string };
      if (user.email) return user.email;
    } catch {
      // Fall back to the development customer below.
    }
  }

  return localStorage.getItem('userEmail') || 'customer@example.com';
}

function getJsonHeaders(): HeadersInit {
  return {
    'Content-Type': 'application/json',
    'X-User-Email': getCustomerEmail(),
  };
}

async function handleResponse<T>(response: Response): Promise<T> {
  if (!response.ok) {
    const message = await response.text();
    throw new Error(message || `Request failed with status ${response.status}`);
  }
  if (response.status === 204) {
    return undefined as T;
  }
  return response.json() as Promise<T>;
}

type BackendProductImage = { id: number; url: string; primary: boolean };

type BackendProduct = {
  id: number;
  name: string;
  slug: string;
  categoryName: string;
  description: string;
  price: number;
  stockQuantity: number;
  images: BackendProductImage[];
};

type BackendCartItem = { product: BackendProduct; quantity: number };

type BackendCartResponse = {
  items: BackendCartItem[];
  itemCount: number;
  subtotal: number;
};

function normalizeImageUrl(url: string): string {
  if (!url) return '';
  if (url.startsWith('http')) return url;
  return `${API_BASE_URL}${url}`;
}

function mapProduct(product: BackendProduct): StoreProduct {
  return {
    id: product.id,
    name: product.name,
    slug: product.slug,
    categoryName: product.categoryName,
    description: product.description,
    price: Number(product.price),
    stockQuantity: product.stockQuantity,
    images: product.images.map((img) => ({
      id: img.id,
      url: normalizeImageUrl(img.url),
      primary: img.primary,
    })),
  };
}

function mapCart(data: BackendCartResponse): CartItem[] {
  return data.items.map((item) => ({
    product: mapProduct(item.product),
    quantity: item.quantity,
  }));
}

export async function getStoreProducts(): Promise<StoreProduct[]> {
  const response = await fetch(`${API_BASE_URL}/api/products`);
  const data = await handleResponse<BackendProduct[]>(response);
  return data.map(mapProduct);
}

export async function getCart(): Promise<CartItem[]> {
  const response = await fetch(`${API_BASE_URL}/api/cart`, {
    headers: getJsonHeaders(),
  });
  const data = await handleResponse<BackendCartResponse>(response);
  return mapCart(data);
}

export async function addCartItem(
  productId: number,
  quantity: number
): Promise<CartItem[]> {
  const response = await fetch(`${API_BASE_URL}/api/cart/items`, {
    method: 'POST',
    headers: getJsonHeaders(),
    body: JSON.stringify({ productId, quantity }),
  });
  const data = await handleResponse<BackendCartResponse>(response);
  return mapCart(data);
}

export async function updateCartItem(
  productId: number,
  quantity: number
): Promise<CartItem[]> {
  const response = await fetch(`${API_BASE_URL}/api/cart/items/${productId}`, {
    method: 'PATCH',
    headers: getJsonHeaders(),
    body: JSON.stringify({ quantity }),
  });
  const data = await handleResponse<BackendCartResponse>(response);
  return mapCart(data);
}

export async function removeCartItem(productId: number): Promise<CartItem[]> {
  const response = await fetch(`${API_BASE_URL}/api/cart/items/${productId}`, {
    method: 'DELETE',
    headers: getJsonHeaders(),
  });
  const data = await handleResponse<BackendCartResponse>(response);
  return mapCart(data);
}

export async function checkoutOrder(
  shippingAddress: ShippingAddress,
  payment: PaymentInfo
) {
  const response = await fetch(`${API_BASE_URL}/api/orders/checkout`, {
    method: 'POST',
    headers: getJsonHeaders(),
    body: JSON.stringify({ shippingAddress, payment }),
  });
  return handleResponse<{
    id: number;
    orderNumber: string;
    status: string;
    subtotal: number;
    shippingCost: number;
    tax: number;
    totalAmount: number;
    createdAt: string;
  }>(response);
}

export async function getMyOrders(): Promise<CustomerOrder[]> {
  const response = await fetch(`${API_BASE_URL}/api/orders/my`, {
    method: 'GET',
    headers: getJsonHeaders(),
  });
  const data = await handleResponse<CustomerOrder[]>(response);
  return data.map((order) => ({
    ...order,
    subtotal: Number(order.subtotal),
    shippingCost: Number(order.shippingCost),
    tax: Number(order.tax),
    totalAmount: Number(order.totalAmount),
    items: order.items.map((item) => ({
      ...item,
      unitPrice: Number(item.unitPrice),
      lineTotal: Number(item.lineTotal),
    })),
  }));
}
