import { Product, ProductImage, ProductRequest } from './productTypes';
import { tokenStorage } from '../../../security/token-storage';

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080';

function getJsonHeaders(): HeadersInit {
  return {
    'Content-Type': 'application/json',
    ...tokenStorage.authHeader(),
  };
}

function getAuthHeaders(): HeadersInit {
  return tokenStorage.authHeader();
}

function withAbsoluteImageUrls(product: Product): Product {
  return {
    ...product,
    images: product.images.map((image) => ({
      ...image,
      url: image.url.startsWith('http')
        ? image.url
        : `${API_BASE_URL}${image.url}`,
    })),
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

export async function getProducts(): Promise<Product[]> {
  const response = await fetch(`${API_BASE_URL}/api/admin/products`, {
    method: 'GET',
    headers: getJsonHeaders(),
  });

  const data = await handleResponse<Product[]>(response);
  return data.map(withAbsoluteImageUrls);
}

export async function createProduct(request: ProductRequest): Promise<Product> {
  const response = await fetch(`${API_BASE_URL}/api/admin/products`, {
    method: 'POST',
    headers: getJsonHeaders(),
    body: JSON.stringify(request),
  });

  const data = await handleResponse<Product>(response);
  return withAbsoluteImageUrls(data);
}

export async function updateProduct(
  id: number,
  request: ProductRequest
): Promise<Product> {
  const response = await fetch(`${API_BASE_URL}/api/admin/products/${id}`, {
    method: 'PUT',
    headers: getJsonHeaders(),
    body: JSON.stringify(request),
  });

  const data = await handleResponse<Product>(response);
  return withAbsoluteImageUrls(data);
}

export async function deleteProduct(id: number): Promise<void> {
  const response = await fetch(`${API_BASE_URL}/api/admin/products/${id}`, {
    method: 'DELETE',
    headers: getJsonHeaders(),
  });

  return handleResponse<void>(response);
}

export async function uploadProductImages(
  productId: number,
  files: FileList
): Promise<ProductImage[]> {
  const formData = new FormData();

  Array.from(files).forEach((file) => {
    formData.append('files', file);
  });

  const response = await fetch(
    `${API_BASE_URL}/api/admin/products/${productId}/images`,
    {
      method: 'POST',
      headers: getAuthHeaders(),
      body: formData,
    }
  );

  const data = await handleResponse<ProductImage[]>(response);

  return data.map((image) => ({
    ...image,
    url: image.url.startsWith('http') ? image.url : `${API_BASE_URL}${image.url}`,
  }));
}

export async function deleteProductImage(
  productId: number,
  imageId: number
): Promise<void> {
  const response = await fetch(
    `${API_BASE_URL}/api/admin/products/${productId}/images/${imageId}`,
    {
      method: 'DELETE',
      headers: getJsonHeaders(),
    }
  );

  return handleResponse<void>(response);
}

export async function setPrimaryProductImage(
  productId: number,
  imageId: number
): Promise<ProductImage> {
  const response = await fetch(
    `${API_BASE_URL}/api/admin/products/${productId}/images/${imageId}/primary`,
    {
      method: 'PATCH',
      headers: getJsonHeaders(),
    }
  );

  const image = await handleResponse<ProductImage>(response);

  return {
    ...image,
    url: image.url.startsWith('http') ? image.url : `${API_BASE_URL}${image.url}`,
  };
}
