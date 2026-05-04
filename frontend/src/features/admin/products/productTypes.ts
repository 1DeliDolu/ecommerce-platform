export type ProductStatus = 'ACTIVE' | 'INACTIVE';

export type ProductImage = {
  id: number;
  originalFileName: string;
  storedFileName: string;
  relativePath: string;
  url: string;
  contentType: string;
  fileSize: number;
  imageOrder: number;
  primary: boolean;
};

export type Product = {
  id: number;
  categoryId: number;
  categoryName: string;
  categorySlug: string;
  name: string;
  slug: string;
  description: string;
  price: number;
  stockQuantity: number;
  status: ProductStatus;
  createdAt: string;
  updatedAt?: string;
  images: ProductImage[];
};

export type ProductRequest = {
  categoryId: number;
  name: string;
  slug: string;
  description: string;
  price: number;
  stockQuantity: number;
  status: ProductStatus;
};

export type CategoryOption = {
  id: number;
  name: string;
  slug: string;
  status: 'ACTIVE' | 'INACTIVE';
};
