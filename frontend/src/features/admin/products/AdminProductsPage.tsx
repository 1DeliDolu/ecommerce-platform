import { useMemo, useState } from 'react';
import AdminProductCard, { AdminProduct } from './AdminProductCard';

const demoProducts: AdminProduct[] = [
  {
    id: 1,
    name: 'Lenovo ThinkPad X1 Carbon',
    categoryName: 'Laptop',
    slug: 'lenovo-thinkpad-x1-carbon',
    description: 'Enterprise business laptop with strong security, lightweight body and long battery life.',
    price: 1899.99,
    stockQuantity: 12,
    active: true,
    images: [
      {
        id: 101,
        url: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=900&q=80',
        fileName: 'lenovo-thinkpad-x1-carbon-main.webp',
        primary: true,
        imageOrder: 1,
      },
      {
        id: 102,
        url: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=900&q=80',
        fileName: 'lenovo-thinkpad-x1-carbon-2.webp',
        primary: false,
        imageOrder: 2,
      },
    ],
  },
  {
    id: 2,
    name: 'iPhone 15 Pro',
    categoryName: 'Smartphone',
    slug: 'iphone-15-pro',
    description: 'Premium smartphone with advanced camera, fast processor and secure mobile experience.',
    price: 1199.99,
    stockQuantity: 28,
    active: true,
    images: [
      {
        id: 201,
        url: 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=900&q=80',
        fileName: 'iphone-15-pro-main.webp',
        primary: true,
        imageOrder: 1,
      },
    ],
  },
  {
    id: 3,
    name: 'USB-C Productivity Dock',
    categoryName: 'Accessories',
    slug: 'usb-c-productivity-dock',
    description: 'Multi-port dock for ecommerce operations desks, support stations and hybrid work setups.',
    price: 89.9,
    stockQuantity: 40,
    active: false,
    images: [],
  },
];

export default function AdminProductsPage() {
  const [products, setProducts] = useState<AdminProduct[]>(demoProducts);
  const [lastAction, setLastAction] = useState('Ready for product management.');

  const permissions = {
    canUpdateProduct: true,
    canDeleteProduct: true,
    canUploadImage: true,
    canDeleteImage: true,
    canSetPrimaryImage: true,
  };

  const stats = useMemo(() => {
    return {
      total: products.length,
      active: products.filter((product) => product.active).length,
      images: products.reduce((total, product) => total + product.images.length, 0),
    };
  }, [products]);

  const handleEditProduct = (product: AdminProduct) => {
    setLastAction(`Edit queued for ${product.name}.`);
  };

  const handleCreateProduct = () => {
    setLastAction('Create product flow is ready for backend integration.');
  };

  const handleDeleteProduct = (productId: number) => {
    const product = products.find((item) => item.id === productId);
    const confirmed = window.confirm('Bu ürünü silmek istediğine emin misin?');
    if (!confirmed) return;

    setProducts((current) => current.filter((item) => item.id !== productId));
    setLastAction(product ? `${product.name} deleted from the admin list.` : 'Product deleted.');
  };

  const handleUploadImages = (productId: number, files: FileList) => {
    setProducts((current) =>
      current.map((product) => {
        if (product.id !== productId) return product;

        const existingCount = product.images.length;
        const newImages = Array.from(files).map((file, index) => ({
          id: Date.now() + index,
          url: URL.createObjectURL(file),
          fileName: file.name,
          primary: existingCount === 0 && index === 0,
          imageOrder: existingCount + index + 1,
        }));

        setLastAction(`${newImages.length} image(s) added to ${product.name}.`);
        return { ...product, images: [...product.images, ...newImages] };
      })
    );
  };

  const handleDeleteImage = (productId: number, imageId: number) => {
    setProducts((current) =>
      current.map((product) => {
        if (product.id !== productId) return product;

        const remainingImages = product.images.filter((image) => image.id !== imageId);
        if (!remainingImages.some((image) => image.primary) && remainingImages.length > 0) {
          remainingImages[0] = { ...remainingImages[0], primary: true };
        }

        setLastAction(`Image removed from ${product.name}.`);
        return { ...product, images: remainingImages };
      })
    );
  };

  const handleSetPrimaryImage = (productId: number, imageId: number) => {
    setProducts((current) =>
      current.map((product) => {
        if (product.id !== productId) return product;

        setLastAction(`Primary image updated for ${product.name}.`);
        return {
          ...product,
          images: product.images.map((image) => ({ ...image, primary: image.id === imageId })),
        };
      })
    );
  };

  return (
    <main className="admin-products-page container-fluid py-4">
      <div className="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-4">
        <div>
          <h1 className="fw-bold mb-1">Admin Product Management</h1>
          <p className="text-muted mb-0">
            Ürün CRUD, fotoğraf yönetimi, primary image ve permission kontrollü admin panel.
          </p>
        </div>

        <button className="btn btn-success" type="button" onClick={handleCreateProduct}>
          <i className="bi bi-plus-circle me-2" aria-hidden="true"></i>
          Create Product
        </button>
      </div>

      <section className="admin-product-summary mb-4" aria-label="Product management summary">
        <div className="summary-item">
          <span>Total products</span>
          <strong>{stats.total}</strong>
        </div>
        <div className="summary-item">
          <span>Active products</span>
          <strong>{stats.active}</strong>
        </div>
        <div className="summary-item">
          <span>Managed images</span>
          <strong>{stats.images}</strong>
        </div>
        <div className="summary-item summary-action">
          <span>Last action</span>
          <strong>{lastAction}</strong>
        </div>
      </section>

      <div className="row g-4">
        {products.map((product) => (
          <div className="col-12 col-md-6 col-xl-4" key={product.id}>
            <AdminProductCard
              product={product}
              canUpdateProduct={permissions.canUpdateProduct}
              canDeleteProduct={permissions.canDeleteProduct}
              canUploadImage={permissions.canUploadImage}
              canDeleteImage={permissions.canDeleteImage}
              canSetPrimaryImage={permissions.canSetPrimaryImage}
              onEditProduct={handleEditProduct}
              onDeleteProduct={handleDeleteProduct}
              onUploadImages={handleUploadImages}
              onDeleteImage={handleDeleteImage}
              onSetPrimaryImage={handleSetPrimaryImage}
            />
          </div>
        ))}
      </div>
    </main>
  );
}
