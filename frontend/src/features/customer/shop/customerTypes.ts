export type StoreProductImage = {
  id: number;
  url: string;
  primary: boolean;
};

export type StoreProduct = {
  id: number;
  name: string;
  slug: string;
  categoryName: string;
  description: string;
  price: number;
  stockQuantity: number;
  images: StoreProductImage[];
};

export type CartItem = {
  product: StoreProduct;
  quantity: number;
};

export type ShippingAddress = {
  fullName: string;
  email: string;
  phone: string;
  street: string;
  city: string;
  postalCode: string;
  country: string;
};

export type PaymentInfo = {
  cardHolder: string;
  cardNumber: string;
  expiry: string;
  cvv: string;
};

export type OrderSummary = {
  orderNumber: string;
  totalAmount: number;
  itemCount: number;
};
