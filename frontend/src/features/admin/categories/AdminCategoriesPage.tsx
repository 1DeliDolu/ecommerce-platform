import { useMemo, useState, type ChangeEvent } from 'react';

type CategoryStatus = 'ACTIVE' | 'INACTIVE';

type Category = {
  id: number;
  name: string;
  slug: string;
  description: string;
  productCount: number;
  status: CategoryStatus;
  createdAt: string;
};

type CategoryFormState = {
  name: string;
  slug: string;
  description: string;
  status: CategoryStatus;
};

const initialCategories: Category[] = [
  {
    id: 1,
    name: 'Laptop',
    slug: 'laptop',
    description: 'Business laptops, ultrabooks, gaming laptops and developer machines.',
    productCount: 24,
    status: 'ACTIVE',
    createdAt: '2026-05-04',
  },
  {
    id: 2,
    name: 'Smartphone',
    slug: 'smartphone',
    description: 'Premium smartphones, secure mobile devices and accessories.',
    productCount: 18,
    status: 'ACTIVE',
    createdAt: '2026-05-04',
  },
  {
    id: 3,
    name: 'Monitor',
    slug: 'monitor',
    description: '4K monitors, office displays, gaming monitors and productivity screens.',
    productCount: 11,
    status: 'ACTIVE',
    createdAt: '2026-05-04',
  },
  {
    id: 4,
    name: 'Accessory',
    slug: 'accessory',
    description: 'Keyboards, mice, cables, docks, adapters and office accessories.',
    productCount: 42,
    status: 'ACTIVE',
    createdAt: '2026-05-04',
  },
  {
    id: 5,
    name: 'Networking',
    slug: 'networking',
    description: 'Routers, switches, firewalls and enterprise network equipment.',
    productCount: 0,
    status: 'INACTIVE',
    createdAt: '2026-05-04',
  },
];

const emptyForm: CategoryFormState = {
  name: '',
  slug: '',
  description: '',
  status: 'ACTIVE',
};

export default function AdminCategoriesPage() {
  const [categories, setCategories] = useState<Category[]>(initialCategories);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<'ALL' | CategoryStatus>('ALL');
  const [role, setRole] = useState<'ADMIN' | 'EMPLOYEE'>('ADMIN');
  const [employeeCategoryCrud, setEmployeeCategoryCrud] = useState(true);
  const [editingCategory, setEditingCategory] = useState<Category | null>(null);
  const [form, setForm] = useState<CategoryFormState>(emptyForm);
  const [lastAction, setLastAction] = useState('Category manager ready.');

  const permissions = role === 'ADMIN'
    ? { canCreateCategory: true, canUpdateCategory: true, canDeleteCategory: true }
    : {
        canCreateCategory: employeeCategoryCrud,
        canUpdateCategory: employeeCategoryCrud,
        canDeleteCategory: false,
      };

  const filteredCategories = useMemo(() => {
    const normalizedSearch = search.trim().toLowerCase();

    return categories.filter((category) => {
      const matchesSearch = !normalizedSearch
        || category.name.toLowerCase().includes(normalizedSearch)
        || category.slug.toLowerCase().includes(normalizedSearch)
        || category.description.toLowerCase().includes(normalizedSearch);
      const matchesStatus = statusFilter === 'ALL' || category.status === statusFilter;

      return matchesSearch && matchesStatus;
    });
  }, [categories, search, statusFilter]);

  const activeCount = categories.filter((category) => category.status === 'ACTIVE').length;
  const inactiveCount = categories.filter((category) => category.status === 'INACTIVE').length;
  const totalProductCount = categories.reduce((total, category) => total + category.productCount, 0);

  const handleCreateOpen = () => {
    setEditingCategory(null);
    setForm(emptyForm);
    setLastAction('Creating a new category draft.');
  };

  const handleEditOpen = (category: Category) => {
    setEditingCategory(category);
    setForm({
      name: category.name,
      slug: category.slug,
      description: category.description,
      status: category.status,
    });
    setLastAction(`Editing ${category.name}.`);
  };

  const handleChange = (field: keyof CategoryFormState) => (event: ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const value = event.target.value;

    setForm((current) => {
      if (field === 'name') {
        return { ...current, name: value, slug: slugify(value) };
      }

      return { ...current, [field]: value };
    });
  };

  const handleSubmit = () => {
    const name = form.name.trim();
    const slug = form.slug.trim();
    const description = form.description.trim();

    if (!name || !slug || !description) {
      window.alert('Category name, slug and description are required.');
      return;
    }

    const slugExists = categories.some((category) => category.slug === slug && category.id !== editingCategory?.id);
    if (slugExists) {
      window.alert('Bu slug zaten kullanılıyor. Farklı bir kategori adı seç.');
      return;
    }

    if (editingCategory) {
      setCategories((current) =>
        current.map((category) =>
          category.id === editingCategory.id
            ? { ...category, name, slug, description, status: form.status }
            : category
        )
      );
      setLastAction(`${name} category updated.`);
    } else {
      setCategories((current) => [
        {
          id: Date.now(),
          name,
          slug,
          description,
          status: form.status,
          productCount: 0,
          createdAt: new Date().toISOString().slice(0, 10),
        },
        ...current,
      ]);
      setLastAction(`${name} category created.`);
    }

    setEditingCategory(null);
    setForm(emptyForm);
  };

  const handleDelete = (category: Category) => {
    if (category.productCount > 0) {
      window.alert('Bu kategoriye bağlı ürünler var. Önce ürünleri başka kategoriye taşımalısın.');
      return;
    }

    const confirmed = window.confirm(`${category.name} kategorisini silmek istiyor musun?`);
    if (!confirmed) return;

    setCategories((current) => current.filter((item) => item.id !== category.id));
    setLastAction(`${category.name} category deleted.`);
  };

  const handleClearForm = () => {
    setEditingCategory(null);
    setForm(emptyForm);
    setLastAction('Category form cleared.');
  };

  return (
    <main className="admin-categories-page container-fluid py-4">
      <div className="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-4">
        <div>
          <h1 className="fw-bold mb-1">Category Management</h1>
          <p className="text-muted mb-0">
            Ürün kategorilerini yönet, slug yapısını kontrol et ve ürün/fotoğraf klasörleme mantığını hazırla.
          </p>
        </div>

        {permissions.canCreateCategory && (
          <button className="btn btn-success" type="button" onClick={handleCreateOpen}>
            <i className="bi bi-plus-circle me-2" aria-hidden="true"></i>
            Create Category
          </button>
        )}
      </div>

      <section className="category-summary mb-4" aria-label="Category summary">
        <SummaryCard icon="bi-tags" title="Total Categories" value={String(categories.length)} />
        <SummaryCard icon="bi-eye" title="Active" value={String(activeCount)} />
        <SummaryCard icon="bi-eye-slash" title="Inactive" value={String(inactiveCount)} />
        <SummaryCard icon="bi-box-seam" title="Total Products" value={String(totalProductCount)} />
      </section>

      <section className="category-toolbar mb-4" aria-label="Category filters and permissions">
        <div className="input-group">
          <span className="input-group-text bg-white border-0">
            <i className="bi bi-search" aria-hidden="true"></i>
          </span>
          <input
            className="form-control border-0"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            placeholder="Search by name, slug or description"
            aria-label="Search categories"
          />
        </div>

        <select className="form-select" value={statusFilter} onChange={(event) => setStatusFilter(event.target.value as 'ALL' | CategoryStatus)} aria-label="Filter categories by status">
          <option value="ALL">All Statuses</option>
          <option value="ACTIVE">Active</option>
          <option value="INACTIVE">Inactive</option>
        </select>

        <div className="btn-group" role="group" aria-label="Category permission role">
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
            checked={employeeCategoryCrud}
            disabled={role === 'ADMIN'}
            onChange={(event) => setEmployeeCategoryCrud(event.target.checked)}
          />
          <span className="form-check-label">Employee category CRUD</span>
        </label>
      </section>

      <section className="category-form mb-4" aria-label="Create or edit category">
        <div className="row g-3 align-items-end">
          <div className="col-12 col-md-3">
            <label className="form-label">Category name</label>
            <input className="form-control" value={form.name} onChange={handleChange('name')} placeholder="Example: Laptop" />
          </div>
          <div className="col-12 col-md-3">
            <label className="form-label">Slug</label>
            <input className="form-control" value={form.slug} onChange={handleChange('slug')} placeholder="category-slug" />
          </div>
          <div className="col-12 col-md-3">
            <label className="form-label">Status</label>
            <select className="form-select" value={form.status} onChange={handleChange('status')}>
              <option value="ACTIVE">Active</option>
              <option value="INACTIVE">Inactive</option>
            </select>
          </div>
          <div className="col-12 col-md-3 d-flex gap-2">
            <button className="btn btn-primary flex-fill" type="button" onClick={handleSubmit}>
              {editingCategory ? 'Update' : 'Save'}
            </button>
            <button className="btn btn-outline-secondary" type="button" onClick={handleClearForm}>
              Clear
            </button>
          </div>
          <div className="col-12">
            <label className="form-label">Description</label>
            <textarea className="form-control" rows={3} value={form.description} onChange={handleChange('description')} />
            <div className="small text-muted mt-2">
              Upload folder preview: <code className="d-inline">uploads/products/{form.slug || 'category-slug'}/product-slug/</code>
            </div>
          </div>
        </div>
      </section>

      <section className="category-summary mb-4" aria-label="Last category action">
        <div className="summary-item summary-action">
          <span>Last action</span>
          <strong>{lastAction}</strong>
        </div>
      </section>

      <div className="row g-4">
        {filteredCategories.map((category) => (
          <div className="col-12 col-md-6 col-xl-4" key={category.id}>
            <CategoryCard
              category={category}
              canUpdate={permissions.canUpdateCategory}
              canDelete={permissions.canDeleteCategory}
              onEdit={handleEditOpen}
              onDelete={handleDelete}
            />
          </div>
        ))}
      </div>

      {filteredCategories.length === 0 && (
        <div className="category-empty-state mt-4">
          <i className="bi bi-tags" aria-hidden="true"></i>
          <h2 className="h5 fw-bold">No categories found</h2>
          <p className="text-muted mb-0">Arama veya filtre kriterlerine uygun kategori bulunamadı.</p>
        </div>
      )}
    </main>
  );
}

function SummaryCard({ icon, title, value }: { icon: string; title: string; value: string }) {
  return (
    <div className="summary-item">
      <span>{title}</span>
      <div className="d-flex justify-content-between align-items-center gap-3">
        <strong>{value}</strong>
        <i className={`bi ${icon} summary-icon`} aria-hidden="true"></i>
      </div>
    </div>
  );
}

function CategoryCard({
  category,
  canUpdate,
  canDelete,
  onEdit,
  onDelete,
}: {
  category: Category;
  canUpdate: boolean;
  canDelete: boolean;
  onEdit: (category: Category) => void;
  onDelete: (category: Category) => void;
}) {
  return (
    <article className="category-card h-100">
      <div className="d-flex justify-content-between align-items-start gap-3">
        <div className="category-icon">
          <i className="bi bi-tag" aria-hidden="true"></i>
        </div>
        <span className={`badge ${category.status === 'ACTIVE' ? 'text-bg-success' : 'text-bg-secondary'}`}>
          {category.status}
        </span>
      </div>

      <h2 className="h5 fw-bold mt-3 mb-1">{category.name}</h2>
      <div className="text-muted small mb-3">/{category.slug}</div>
      <p className="text-muted category-description">{category.description}</p>

      <div className="d-flex flex-wrap gap-2 mb-3">
        <span className="badge rounded-pill text-bg-light border">
          <i className="bi bi-box-seam me-1" aria-hidden="true"></i>
          {category.productCount} products
        </span>
        <span className="badge rounded-pill text-bg-light border">Created {category.createdAt}</span>
      </div>

      <div className="category-folder mb-3">
        <span>Upload folder</span>
        <code>uploads/products/{category.slug}/product-slug/</code>
      </div>

      <div className="d-flex gap-2">
        {canUpdate && (
          <button className="btn btn-primary flex-fill" type="button" onClick={() => onEdit(category)}>
            <i className="bi bi-pencil-square me-2" aria-hidden="true"></i>
            Edit
          </button>
        )}
        {canDelete && (
          <button
            className="btn btn-outline-danger"
            type="button"
            onClick={() => onDelete(category)}
            disabled={category.productCount > 0}
            aria-label={`Delete ${category.name}`}
            title={category.productCount > 0 ? 'Move products before deleting this category' : 'Delete category'}
          >
            <i className="bi bi-trash" aria-hidden="true"></i>
          </button>
        )}
      </div>
    </article>
  );
}

function slugify(value: string) {
  return value
    .toLowerCase()
    .trim()
    .replace(/ğ/g, 'g')
    .replace(/ü/g, 'u')
    .replace(/ş/g, 's')
    .replace(/ı/g, 'i')
    .replace(/ö/g, 'o')
    .replace(/ç/g, 'c')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}
