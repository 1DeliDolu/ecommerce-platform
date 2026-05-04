import React, { createContext, useCallback, useContext, useMemo, useState } from 'react';
import { CartItem, StoreProduct } from './shop/customerTypes';
import {
  addCartItem,
  getCart,
  removeCartItem,
  updateCartItem,
} from './api/customerApi';

type CartContextValue = {
  cartItems: CartItem[];
  cartItemCount: number;
  cartTotal: number;
  cartLoading: boolean;
  cartDrawerOpen: boolean;
  openCartDrawer: () => void;
  closeCartDrawer: () => void;
  loadCart: () => Promise<void>;
  addToCart: (product: StoreProduct) => Promise<void>;
  increaseQuantity: (productId: number) => Promise<void>;
  decreaseQuantity: (productId: number) => Promise<void>;
  removeFromCart: (productId: number) => Promise<void>;
};

const CartContext = createContext<CartContextValue | null>(null);

export function CartProvider({ children }: { children: React.ReactNode }) {
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [cartLoading, setCartLoading] = useState(false);
  const [cartDrawerOpen, setCartDrawerOpen] = useState(false);

  const loadCart = useCallback(async () => {
    try {
      const items = await getCart();
      setCartItems(items);
    } catch {
      // ignore — user might not be logged in
    }
  }, []);

  const addToCart = useCallback(async (product: StoreProduct) => {
    if (product.stockQuantity <= 0) return;
    setCartLoading(true);
    try {
      const updated = await addCartItem(product.id, 1);
      setCartItems(updated);
    } finally {
      setCartLoading(false);
    }
  }, []);

  const increaseQuantity = useCallback(async (productId: number) => {
    const item = cartItems.find((i) => i.product.id === productId);
    if (!item) return;
    setCartLoading(true);
    try {
      const updated = await updateCartItem(productId, item.quantity + 1);
      setCartItems(updated);
    } finally {
      setCartLoading(false);
    }
  }, [cartItems]);

  const decreaseQuantity = useCallback(async (productId: number) => {
    const item = cartItems.find((i) => i.product.id === productId);
    if (!item) return;
    setCartLoading(true);
    try {
      const updated =
        item.quantity <= 1
          ? await removeCartItem(productId)
          : await updateCartItem(productId, item.quantity - 1);
      setCartItems(updated);
    } finally {
      setCartLoading(false);
    }
  }, [cartItems]);

  const removeFromCart = useCallback(async (productId: number) => {
    setCartLoading(true);
    try {
      const updated = await removeCartItem(productId);
      setCartItems(updated);
    } finally {
      setCartLoading(false);
    }
  }, []);

  const cartItemCount = useMemo(
    () => cartItems.reduce((sum, item) => sum + item.quantity, 0),
    [cartItems]
  );

  const cartTotal = useMemo(
    () => cartItems.reduce((sum, item) => sum + item.product.price * item.quantity, 0),
    [cartItems]
  );

  const value = useMemo<CartContextValue>(
    () => ({
      cartItems,
      cartItemCount,
      cartTotal,
      cartLoading,
      cartDrawerOpen,
      openCartDrawer: () => setCartDrawerOpen(true),
      closeCartDrawer: () => setCartDrawerOpen(false),
      loadCart,
      addToCart,
      increaseQuantity,
      decreaseQuantity,
      removeFromCart,
    }),
    [cartItems, cartItemCount, cartTotal, cartLoading, cartDrawerOpen,
     loadCart, addToCart, increaseQuantity, decreaseQuantity, removeFromCart]
  );

  return <CartContext.Provider value={value}>{children}</CartContext.Provider>;
}

export function useCart(): CartContextValue {
  const ctx = useContext(CartContext);
  if (!ctx) throw new Error('useCart must be used inside <CartProvider>');
  return ctx;
}
