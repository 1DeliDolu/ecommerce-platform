import { useEffect, useMemo, useState, type ChangeEvent } from 'react';

export type ProductImage = {
  id: number;
  url: string;
  fileName: string;
  relativePath: string;
  primary: boolean;
  imageOrder: number;
};

export type AdminProduct = {
  id: number;
  name: string;
  categoryName: string;
  slug: string;
  description: string;
  price: number;
  stockQuantity: number;
  active: boolean;
  images: ProductImage[];
};

type AdminProductCardProps = {
  product: AdminProduct;
  canUpdateProduct: boolean;
  canDeleteProduct: boolean;
  canUploadImage: boolean;
  canDeleteImage: boolean;
  canSetPrimaryImage: boolean;
  onEditProduct: (product: AdminProduct) => void;
  onDeleteProduct: (productId: number) => void;
  onUploadImages: (productId: number, files: FileList) => void;
  onDeleteImage: (productId: number, imageId: number) => void;
  onSetPrimaryImage: (productId: number, imageId: number) => void;
};

const PAGE_SIZE = 5;
const MAX_IMAGES = 5;

export default function AdminProductCard({
  product,
  canUpdateProduct,
  canDeleteProduct,
  canUploadImage,
  canDeleteImage,
  canSetPrimaryImage,
  onEditProduct,
  onDeleteProduct,
  onUploadImages,
  onDeleteImage,
  onSetPrimaryImage,
}: AdminProductCardProps) {
  const sortedImages = useMemo(() => {
    return [...product.images].sort((a, b) => {
      if (a.primary && !b.primary) return -1;
      if (!a.primary && b.primary) return 1;
      return a.imageOrder - b.imageOrder;
    });
  }, [product.images]);

  const defaultImage = sortedImages.find((image) => image.primary) ?? sortedImages[0];
  const [selectedImageId, setSelectedImageId] = useState<number | undefined>(defaultImage?.id);
  const [page, setPage] = useState(1);

  useEffect(() => {
    if (!sortedImages.some((image) => image.id === selectedImageId)) {
      setSelectedImageId(defaultImage?.id);
    }
  }, [defaultImage?.id, selectedImageId, sortedImages]);

  const selectedImage = sortedImages.find((image) => image.id === selectedImageId) ?? defaultImage;
  const totalPages = Math.max(1, Math.ceil(sortedImages.length / PAGE_SIZE));
  const paginatedImages = sortedImages.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);
  const canAddMoreImages = product.images.length < MAX_IMAGES;

  const handleUpload = (event: ChangeEvent<HTMLInputElement>) => {
    if (!event.target.files || event.target.files.length === 0) return;

    const remainingSlots = MAX_IMAGES - product.images.length;
    if (event.target.files.length > remainingSlots) {
      window.alert(`Bu ürün için en fazla ${remainingSlots} fotoğraf daha yükleyebilirsin.`);
      event.target.value = '';
      return;
    }

    onUploadImages(product.id, event.target.files);
    event.target.value = '';
  };

  return (
    <article className="card admin-product-card border-0 shadow-sm overflow-hidden h-100">
      <div className="position-relative bg-light">
        {selectedImage ? (
          <img src={selectedImage.url} alt={product.name} className="card-img-top admin-product-image" />
        ) : (
          <div className="admin-product-empty-image d-flex align-items-center justify-content-center text-muted">
            <div className="text-center">
              <i className="bi bi-image fs-1 d-block mb-2" aria-hidden="true"></i>
              No product image
            </div>
          </div>
        )}

        <span className="badge bg-dark position-absolute top-0 start-0 m-3">{product.categoryName}</span>
        <span className={`badge position-absolute top-0 end-0 m-3 ${product.active ? 'bg-success' : 'bg-secondary'}`}>
          {product.active ? 'Active' : 'Inactive'}
        </span>
      </div>

      <div className="card-body">
        <div className="d-flex align-items-start justify-content-between gap-3">
          <div>
            <h2 className="h5 card-title fw-bold mb-1">{product.name}</h2>
            <div className="text-muted small">{product.slug}</div>
          </div>

          <div className="dropdown">
            <button className="btn btn-light btn-sm rounded-circle" type="button" data-bs-toggle="dropdown" aria-expanded="false" aria-label={`${product.name} actions`}>
              <i className="bi bi-three-dots-vertical" aria-hidden="true"></i>
            </button>
            <ul className="dropdown-menu dropdown-menu-end shadow border-0">
              {canUpdateProduct && (
                <li>
                  <button className="dropdown-item" type="button" onClick={() => onEditProduct(product)}>
                    <i className="bi bi-pencil-square me-2" aria-hidden="true"></i>
                    Edit Product
                  </button>
                </li>
              )}
              {canDeleteProduct && (
                <li>
                  <button className="dropdown-item text-danger" type="button" onClick={() => onDeleteProduct(product.id)}>
                    <i className="bi bi-trash me-2" aria-hidden="true"></i>
                    Delete Product
                  </button>
                </li>
              )}
            </ul>
          </div>
        </div>

        <p className="card-text text-muted mt-3 mb-3">{product.description}</p>

        <div className="d-flex justify-content-between align-items-center mb-3">
          <div>
            <div className="small text-muted">Price</div>
            <div className="fw-bold fs-5">€{product.price.toFixed(2)}</div>
          </div>
          <div className="text-end">
            <div className="small text-muted">Stock</div>
            <div className="fw-bold">{product.stockQuantity}</div>
          </div>
        </div>

        <div className="border-top pt-3">
          <div className="d-flex align-items-center justify-content-between mb-2">
            <span className="fw-semibold">Images {product.images.length}/{MAX_IMAGES}</span>

            {canUploadImage && canAddMoreImages && (
              <label className="btn btn-sm btn-outline-primary mb-0">
                <i className="bi bi-upload me-1" aria-hidden="true"></i>
                Upload
                <input type="file" accept="image/png,image/jpeg,image/webp" multiple hidden onChange={handleUpload} />
              </label>
            )}
          </div>

          {paginatedImages.length > 0 ? (
            <div className="d-flex gap-2 flex-wrap">
              {paginatedImages.map((image) => {
                const selected = selectedImage?.id === image.id;

                return (
                  <div key={image.id} className={`admin-product-thumb position-relative border p-1 ${selected ? 'border-primary border-2' : 'border-light'}`}>
                    <button type="button" className="border-0 bg-transparent p-0 w-100" onClick={() => setSelectedImageId(image.id)}>
                      <img src={image.url} alt={image.fileName} className="rounded-1 admin-product-thumb-image" />
                    </button>

                    {image.primary && (
                      <span className="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-warning text-dark">
                        Main
                      </span>
                    )}

                    <div className="d-flex gap-1 mt-1">
                      {canSetPrimaryImage && !image.primary && (
                        <button type="button" className="btn btn-sm btn-outline-warning flex-fill py-0" title="Set primary" onClick={() => onSetPrimaryImage(product.id, image.id)}>
                          <i className="bi bi-star" aria-hidden="true"></i>
                        </button>
                      )}
                      {canDeleteImage && (
                        <button type="button" className="btn btn-sm btn-outline-danger flex-fill py-0" title="Delete image" onClick={() => onDeleteImage(product.id, image.id)}>
                          <i className="bi bi-x" aria-hidden="true"></i>
                        </button>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          ) : (
            <div className="alert alert-light border small mb-0">Bu ürün için fotoğraf yok.</div>
          )}

          {selectedImage && (
            <div className="admin-image-path mt-3">
              <span>Storage path</span>
              <code>{selectedImage.relativePath}</code>
            </div>
          )}

          {totalPages > 1 && (
            <nav className="mt-3" aria-label={`${product.name} image pages`}>
              <ul className="pagination pagination-sm mb-0">
                <li className={`page-item ${page === 1 ? 'disabled' : ''}`}>
                  <button className="page-link" type="button" onClick={() => setPage((current) => Math.max(1, current - 1))}>
                    Previous
                  </button>
                </li>
                {Array.from({ length: totalPages }).map((_, index) => (
                  <li key={index + 1} className={`page-item ${page === index + 1 ? 'active' : ''}`}>
                    <button className="page-link" type="button" onClick={() => setPage(index + 1)}>
                      {index + 1}
                    </button>
                  </li>
                ))}
                <li className={`page-item ${page === totalPages ? 'disabled' : ''}`}>
                  <button className="page-link" type="button" onClick={() => setPage((current) => Math.min(totalPages, current + 1))}>
                    Next
                  </button>
                </li>
              </ul>
            </nav>
          )}
        </div>
      </div>

      <div className="card-footer bg-white border-0 d-flex gap-2">
        {canUpdateProduct && (
          <button type="button" className="btn btn-primary flex-fill" onClick={() => onEditProduct(product)}>
            <i className="bi bi-pencil-square me-2" aria-hidden="true"></i>
            Edit
          </button>
        )}
        {canDeleteProduct && (
          <button type="button" className="btn btn-outline-danger" onClick={() => onDeleteProduct(product.id)} aria-label={`Delete ${product.name}`}>
            <i className="bi bi-trash" aria-hidden="true"></i>
          </button>
        )}
      </div>
    </article>
  );
}
