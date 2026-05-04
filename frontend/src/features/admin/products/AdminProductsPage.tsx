import { useMemo, useState } from 'react';
import AdminProductCard, { AdminProduct } from './AdminProductCard';

type ProductFormState = {
  name: string;
  categoryName: string;
  description: string;
  price: string;
  stockQuantity: string;
  active: boolean;
};

const emptyForm: ProductFormState = {
  name: '',
  categoryName: 'Accessories',
  description: '',
  price: '',
  stockQuantity: '',
  active: true,
};

const categoryOptions = ['Laptop', 'Smartphone', 'Accessories', 'Monitoring', 'Security'];

function slugify(value: string) {
  return value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');
}

function timestampSuffix() {
  return new Date().toISOString().replace(/[-:T.Z]/g, '').slice(0, 14);
}

function buildImagePath(categoryName: string, productSlug: string, imageOrder: number, fileName: string) {
  const extension = fileName.split('.').pop()?.toLowerCase() || 'webp';
  const categorySlug = slugify(categoryName);
  const slot = imageOrder === 1 ? 'main' : String(imageOrder);

  return `uploads/products/${categorySlug}/${productSlug}/${productSlug}-${slot}-${timestampSuffix()}.${extension}`;
}

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
        relativePath: 'uploads/products/laptop/lenovo-thinkpad-x1-carbon/lenovo-thinkpad-x1-carbon-main-20260504161230.webp',
        primary: true,
        imageOrder: 1,
      },
      {
        id: 102,
        url: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=900&q=80',
        fileName: 'lenovo-thinkpad-x1-carbon-2.webp',
        relativePath: 'uploads/products/laptop/lenovo-thinkpad-x1-carbon/lenovo-thinkpad-x1-carbon-2-20260504161231.webp',
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
        relativePath: 'uploads/products/smartphone/iphone-15-pro/iphone-15-pro-main-20260504161230.webp',
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
  const [query, setQuery] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('All');
  const [statusFilter, setStatusFilter] = useState('All');
  const [role, setRole] = useState<'ADMIN' | 'EMPLOYEE'>('ADMIN');
  const [employeeCrudEnabled, setEmployeeCrudEnabled] = useState(true);
  const [editingProduct, setEditingProduct] = useState<AdminProduct | null>(null);
  const [form, setForm] = useState<ProductFormState>(emptyForm);

  const permissions = role === 'ADMIN'
    ? {
        canUpdateProduct: true,
        canDeleteProduct: true,
        canUploadImage: true,
        canDeleteImage: true,
        canSetPrimaryImage: true,
      }
    : {
        canUpdateProduct: employeeCrudEnabled,
        canDeleteProduct: false,
        canUploadImage: employeeCrudEnabled,
        canDeleteImage: false,
        canSetPrimaryImage: employeeCrudEnabled,
      };

  const stats = useMemo(() => {
    return {
      total: products.length,
      active: products.filter((product) => product.active).length,
      images: products.reduce((total, product) => total + product.images.length, 0),
    };
  }, [products]);

  const filteredProducts = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();

    return products.filter((product) => {
      const matchesQuery = !normalizedQuery
        || product.name.toLowerCase().includes(normalizedQuery)
        || product.slug.toLowerCase().includes(normalizedQuery)
        || product.categoryName.toLowerCase().includes(normalizedQuery);
      const matchesCategory = categoryFilter === 'All' || product.categoryName === categoryFilter;
      const matchesStatus = statusFilter === 'All'
        || (statusFilter === 'Active' && product.active)
        || (statusFilter === 'Inactive' && !product.active);

      return matchesQuery && matchesCategory && matchesStatus;
    });
  }, [categoryFilter, products, query, statusFilter]);

  const handleEditProduct = (product: AdminProduct) => {
    setEditingProduct(product);
    setForm({
      name: product.name,
      categoryName: product.categoryName,
      description: product.description,
      price: String(product.price),
      stockQuantity: String(product.stockQuantity),
      active: product.active,
    });
    setLastAction(`Editing ${product.name}.`);
  };

  const handleCreateProduct = () => {
    setEditingProduct(null);
    setForm(emptyForm);
    setLastAction('Creating a new product draft.');
  };

  const handleCancelForm = () => {
    setEditingProduct(null);
    setForm(emptyForm);
    setLastAction('Product form cancelled.');
  };

  const handleSaveProduct = () => {
    const name = form.name.trim();
    const categoryName = form.categoryName.trim();
    const description = form.description.trim();
    const price = Number(form.price);
    const stockQuantity = Number(form.stockQuantity);

    if (!name || !categoryName || !description || Number.isNaN(price) || Number.isNaN(stockQuantity)) {
      window.alert('Ürün adı, kategori, açıklama, fiyat ve stok alanlarını doldur.');
      return;
    }

    const baseSlug = slugify(name);
    const existingSlug = products.some((product) =>
      product.id !== editingProduct?.id && product.categoryName === categoryName && product.slug === baseSlug
    );
    const slug = existingSlug ? `${baseSlug}-${timestampSuffix()}` : baseSlug;

    if (editingProduct) {
      setProducts((current) =>
        current.map((product) =>
          product.id === editingProduct.id
            ? { ...product, name, categoryName, slug, description, price, stockQuantity, active: form.active }
            : product
        )
      );
      setLastAction(`${name} updated.`);
    } else {
      setProducts((current) => [
        {
          id: Date.now(),
          name,
          categoryName,
          slug,
          description,
          price,
          stockQuantity,
          active: form.active,
          images: [],
        },
        ...current,
      ]);
      setLastAction(`${name} created.`);
    }

    setEditingProduct(null);
    setForm(emptyForm);
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
          relativePath: buildImagePath(product.categoryName, product.slug, existingCount + index + 1, file.name),
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

      <section className="admin-product-toolbar mb-4" aria-label="Product filters and permissions">
        <div className="input-group">
          <span className="input-group-text bg-white border-0">
            <i className="bi bi-search" aria-hidden="true"></i>
          </span>
          <input
            className="form-control border-0"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Search product, slug or category"
            aria-label="Search products"
          />
        </div>

        <select className="form-select" value={categoryFilter} onChange={(event) => setCategoryFilter(event.target.value)} aria-label="Filter by category">
          <option>All</option>
          {categoryOptions.map((category) => (
            <option key={category}>{category}</option>
          ))}
        </select>

        <select className="form-select" value={statusFilter} onChange={(event) => setStatusFilter(event.target.value)} aria-label="Filter by status">
          <option>All</option>
          <option>Active</option>
          <option>Inactive</option>
        </select>

        <div className="btn-group" role="group" aria-label="Permission role">
          <button type="button" className={`btn ${role === 'ADMIN' ? 'btn-dark' : 'btn-outline-dark'}`} onClick={() => setRole('ADMIN')}>
            Admin
          </button>
          <button type="button" className={`btn ${role === 'EMPLOYEE' ? 'btn-dark' : 'btn-outline-dark'}`} onClick={() => setRole('EMPLOYEE')}>
            Employee
          </button>
        </div>

        <label className="permission-toggle form-check form-switch mb-0">
          <input
            className="form-check-input"
            type="checkbox"
            checked={employeeCrudEnabled}
            disabled={role === 'ADMIN'}
            onChange={(event) => setEmployeeCrudEnabled(event.target.checked)}
          />
          <span className="form-check-label">Employee CRUD</span>
        </label>
      </section>

      <section className="admin-product-form mb-4" aria-label="Create or edit product">
        <div className="row g-3 align-items-end">
          <div className="col-12 col-lg-3">
            <label className="form-label">Product name</label>
            <input className="form-control" value={form.name} onChange={(event) => setForm({ ...form, name: event.target.value })} />
          </div>
          <div className="col-12 col-lg-2">
            <label className="form-label">Category</label>
            <select className="form-select" value={form.categoryName} onChange={(event) => setForm({ ...form, categoryName: event.target.value })}>
              {categoryOptions.map((category) => (
                <option key={category}>{category}</option>
              ))}
            </select>
          </div>
          <div className="col-12 col-lg-3">
            <label className="form-label">Description</label>
            <input className="form-control" value={form.description} onChange={(event) => setForm({ ...form, description: event.target.value })} />
          </div>
          <div className="col-6 col-lg-1">
            <label className="form-label">Price</label>
            <input className="form-control" type="number" min="0" step="0.01" value={form.price} onChange={(event) => setForm({ ...form, price: event.target.value })} />
          </div>
          <div className="col-6 col-lg-1">
            <label className="form-label">Stock</label>
            <input className="form-control" type="number" min="0" value={form.stockQuantity} onChange={(event) => setForm({ ...form, stockQuantity: event.target.value })} />
          </div>
          <div className="col-12 col-lg-2 d-flex gap-2">
            <button className="btn btn-primary flex-fill" type="button" onClick={handleSaveProduct}>
              {editingProduct ? 'Update' : 'Save'}
            </button>
            <button className="btn btn-outline-secondary" type="button" onClick={handleCancelForm}>
              Clear
            </button>
          </div>
          <div className="col-12">
            <label className="form-check">
              <input className="form-check-input" type="checkbox" checked={form.active} onChange={(event) => setForm({ ...form, active: event.target.checked })} />
              <span className="form-check-label">Product is active</span>
            </label>
            <div className="small text-muted mt-1">
              Slug preview: <code className="d-inline">{slugify(form.name) || 'product-slug'}</code>
            </div>
          </div>
        </div>
      </section>

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
        {filteredProducts.map((product) => (
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

      {filteredProducts.length === 0 && (
        <div className="alert alert-light border mt-4 mb-0">No products match the current filters.</div>
      )}
    </main>
  );
}
