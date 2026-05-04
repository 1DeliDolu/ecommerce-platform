import React, { useEffect, useMemo, useState } from 'react';
import {
  Box,
  Button,
  Card,
  CardActions,
  CardContent,
  CardMedia,
  Chip,
  Container,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Grid,
  IconButton,
  MenuItem,
  Stack,
  TextField,
  Typography,
} from '@mui/material';

import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import ImageIcon from '@mui/icons-material/Image';
import StarIcon from '@mui/icons-material/Star';
import StarBorderIcon from '@mui/icons-material/StarBorder';
import UploadIcon from '@mui/icons-material/Upload';

import {
  createProduct,
  deleteProduct,
  deleteProductImage,
  getProducts,
  setPrimaryProductImage,
  updateProduct,
  uploadProductImages,
} from './productApi';

import { Product, ProductImage, ProductRequest, ProductStatus } from './productTypes';

import { getCategories } from '../categories/categoryApi';
import { Category } from '../categories/categoryTypes';

type ProductFormState = {
  categoryId: string;
  name: string;
  slug: string;
  description: string;
  price: string;
  stockQuantity: string;
  status: ProductStatus;
};

const emptyForm: ProductFormState = {
  categoryId: '',
  name: '',
  slug: '',
  description: '',
  price: '',
  stockQuantity: '0',
  status: 'ACTIVE',
};

export default function AdminProductsCrudPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [selectedImageByProduct, setSelectedImageByProduct] = useState<Record<number, number>>({});
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [form, setForm] = useState<ProductFormState>(emptyForm);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadPageData();
  }, []);

  async function loadPageData() {
    try {
      setLoading(true);
      const [productData, categoryData] = await Promise.all([
        getProducts(),
        getCategories(),
      ]);
      setProducts(productData);
      setCategories(categoryData);
    } catch (error) {
      alert(error instanceof Error ? error.message : 'Data could not be loaded.');
    } finally {
      setLoading(false);
    }
  }

  const activeCategories = useMemo(
    () => categories.filter((c) => c.status === 'ACTIVE'),
    [categories]
  );

  const handleCreateOpen = () => {
    setEditingProduct(null);
    setForm(emptyForm);
    setDialogOpen(true);
  };

  const handleEditOpen = (product: Product) => {
    setEditingProduct(product);
    setForm({
      categoryId: String(product.categoryId),
      name: product.name,
      slug: product.slug,
      description: product.description,
      price: String(product.price),
      stockQuantity: String(product.stockQuantity),
      status: product.status,
    });
    setDialogOpen(true);
  };

  const handleClose = () => {
    setEditingProduct(null);
    setForm(emptyForm);
    setDialogOpen(false);
  };

  const handleChange =
    (field: keyof ProductFormState) =>
    (event: React.ChangeEvent<HTMLInputElement>) => {
      const value = event.target.value;
      setForm((current) => {
        if (field === 'name') {
          return { ...current, name: value, slug: slugify(value) };
        }
        return { ...current, [field]: value };
      });
    };

  const handleSubmit = async () => {
    if (!form.categoryId) { alert('Category is required.'); return; }
    if (!form.name.trim()) { alert('Product name is required.'); return; }
    if (!form.slug.trim()) { alert('Product slug is required.'); return; }

    const request: ProductRequest = {
      categoryId: Number(form.categoryId),
      name: form.name,
      slug: form.slug,
      description: form.description,
      price: Number(form.price),
      stockQuantity: Number(form.stockQuantity),
      status: form.status,
    };

    try {
      if (editingProduct) {
        const updated = await updateProduct(editingProduct.id, request);
        setProducts((current) =>
          current.map((p) => (p.id === updated.id ? updated : p))
        );
      } else {
        const created = await createProduct(request);
        setProducts((current) => [created, ...current]);
      }
      handleClose();
    } catch (error) {
      alert(error instanceof Error ? error.message : 'Product save failed.');
    }
  };

  const handleDeleteProduct = async (product: Product) => {
    if (!confirm(`${product.name} ürününü silmek istiyor musun?`)) return;
    try {
      await deleteProduct(product.id);
      setProducts((current) => current.filter((item) => item.id !== product.id));
    } catch (error) {
      alert(error instanceof Error ? error.message : 'Product delete failed.');
    }
  };

  const handleUploadImages = async (product: Product, files: FileList | null) => {
    if (!files || files.length === 0) return;
    if (product.images.length + files.length > 5) {
      alert(`Bu ürün için en fazla ${5 - product.images.length} fotoğraf daha yükleyebilirsin.`);
      return;
    }
    try {
      const updatedImages = await uploadProductImages(product.id, files);
      setProducts((current) =>
        current.map((item) =>
          item.id === product.id ? { ...item, images: updatedImages } : item
        )
      );
    } catch (error) {
      alert(error instanceof Error ? error.message : 'Image upload failed.');
    }
  };

  const handleDeleteImage = async (product: Product, image: ProductImage) => {
    if (!confirm(`${image.originalFileName} silinsin mi?`)) return;
    try {
      await deleteProductImage(product.id, image.id);
      await reloadProductList();
    } catch (error) {
      alert(error instanceof Error ? error.message : 'Image delete failed.');
    }
  };

  const handleSetPrimaryImage = async (product: Product, image: ProductImage) => {
    try {
      await setPrimaryProductImage(product.id, image.id);
      await reloadProductList();
    } catch (error) {
      alert(error instanceof Error ? error.message : 'Set primary image failed.');
    }
  };

  async function reloadProductList() {
    const productData = await getProducts();
    setProducts(productData);
  }

  function getSelectedImage(product: Product): ProductImage | undefined {
    const selectedImageId = selectedImageByProduct[product.id];
    if (selectedImageId) {
      return product.images.find((img) => img.id === selectedImageId);
    }
    return product.images.find((img) => img.primary) ?? product.images[0];
  }

  return (
    <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh', py: 4 }}>
      <Container maxWidth="xl">
        <Stack
          direction={{ xs: 'column', md: 'row' }}
          sx={{ justifyContent: 'space-between', alignItems: { xs: 'stretch', md: 'center' }, mb: 4 }}
          spacing={2}
        >
          <Box>
            <Typography variant="h4" sx={{ fontWeight: 900 }}>
              Product Management
            </Typography>
            <Typography color="text.secondary">
              Product CRUD, max 5 image upload, primary image and category-based folder structure.
            </Typography>
          </Box>

          <Button variant="contained" size="large" startIcon={<AddIcon />} onClick={handleCreateOpen}>
            Create Product
          </Button>
        </Stack>

        {loading && (
          <Card sx={{ mb: 4, borderRadius: 4 }}>
            <CardContent>Products loading...</CardContent>
          </Card>
        )}

        <Grid container spacing={3}>
          {products.map((product) => {
            const selectedImage = getSelectedImage(product);

            return (
              <Grid key={product.id} size={{ xs: 12, md: 6, xl: 4 }}>
                <Card
                  elevation={0}
                  sx={{ height: '100%', borderRadius: 4, overflow: 'hidden', border: '1px solid', borderColor: 'divider' }}
                >
                  {selectedImage ? (
                    <CardMedia
                      component="img"
                      height="260"
                      image={selectedImage.url}
                      alt={product.name}
                      sx={{ objectFit: 'cover' }}
                    />
                  ) : (
                    <Box sx={{ height: 260, display: 'flex', alignItems: 'center', justifyContent: 'center', bgcolor: '#eef2f7', color: 'text.secondary' }}>
                      <Stack sx={{ alignItems: 'center' }}>
                        <ImageIcon fontSize="large" />
                        <Typography>No image</Typography>
                      </Stack>
                    </Box>
                  )}

                  <CardContent>
                    <Stack direction="row" sx={{ justifyContent: 'space-between' }} spacing={2}>
                      <Box>
                        <Typography variant="h6" sx={{ fontWeight: 900 }}>
                          {product.name}
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                          /{product.categorySlug}/{product.slug}
                        </Typography>
                      </Box>

                      <Chip
                        label={product.status}
                        color={product.status === 'ACTIVE' ? 'success' : 'default'}
                        size="small"
                      />
                    </Stack>

                    <Typography color="text.secondary" sx={{ mt: 2, minHeight: 48 }}>
                      {product.description}
                    </Typography>

                    <Stack direction="row" sx={{ justifyContent: 'space-between', mt: 2 }}>
                      <Box>
                        <Typography variant="caption" color="text.secondary">Price</Typography>
                        <Typography sx={{ fontWeight: 900 }}>€{Number(product.price).toFixed(2)}</Typography>
                      </Box>
                      <Box sx={{ textAlign: 'right' }}>
                        <Typography variant="caption" color="text.secondary">Stock</Typography>
                        <Typography sx={{ fontWeight: 900 }}>{product.stockQuantity}</Typography>
                      </Box>
                    </Stack>

                    <Box sx={{ mt: 3 }}>
                      <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
                        <Typography sx={{ fontWeight: 800 }}>Images {product.images.length}/5</Typography>
                        <Button
                          component="label"
                          size="small"
                          startIcon={<UploadIcon />}
                          disabled={product.images.length >= 5}
                        >
                          Upload
                          <input
                            hidden
                            type="file"
                            accept="image/jpeg,image/png,image/webp"
                            multiple
                            onChange={(event) => handleUploadImages(product, event.target.files)}
                          />
                        </Button>
                      </Stack>

                      <Stack direction="row" spacing={1} sx={{ flexWrap: 'wrap' }}>
                        {product.images.map((image) => {
                          const selected = selectedImage?.id === image.id;
                          return (
                            <Box
                              key={image.id}
                              sx={{
                                width: 76,
                                border: '2px solid',
                                borderColor: selected ? 'primary.main' : 'divider',
                                borderRadius: 2,
                                p: 0.5,
                              }}
                            >
                              <Box
                                component="img"
                                src={image.url}
                                alt={image.originalFileName}
                                onClick={() =>
                                  setSelectedImageByProduct((current) => ({
                                    ...current,
                                    [product.id]: image.id,
                                  }))
                                }
                                sx={{ width: '100%', height: 52, objectFit: 'cover', borderRadius: 1, cursor: 'pointer' }}
                              />

                              <Stack direction="row" sx={{ justifyContent: 'center' }} spacing={0.5}>
                                <IconButton
                                  size="small"
                                  color={image.primary ? 'warning' : 'default'}
                                  onClick={() => handleSetPrimaryImage(product, image)}
                                >
                                  {image.primary ? <StarIcon fontSize="small" /> : <StarBorderIcon fontSize="small" />}
                                </IconButton>

                                <IconButton size="small" color="error" onClick={() => handleDeleteImage(product, image)}>
                                  <DeleteIcon fontSize="small" />
                                </IconButton>
                              </Stack>
                            </Box>
                          );
                        })}
                      </Stack>
                    </Box>
                  </CardContent>

                  <CardActions sx={{ px: 2, pb: 2 }}>
                    <Button variant="contained" startIcon={<EditIcon />} onClick={() => handleEditOpen(product)}>
                      Edit
                    </Button>
                    <IconButton color="error" onClick={() => handleDeleteProduct(product)}>
                      <DeleteIcon />
                    </IconButton>
                  </CardActions>
                </Card>
              </Grid>
            );
          })}
        </Grid>

        <ProductDialog
          open={dialogOpen}
          editingProduct={editingProduct}
          form={form}
          categories={activeCategories}
          onChange={handleChange}
          onClose={handleClose}
          onSubmit={handleSubmit}
        />
      </Container>
    </Box>
  );
}

function ProductDialog({
  open,
  editingProduct,
  form,
  categories,
  onChange,
  onClose,
  onSubmit,
}: {
  open: boolean;
  editingProduct: Product | null;
  form: ProductFormState;
  categories: Category[];
  onChange: (field: keyof ProductFormState) => (event: React.ChangeEvent<HTMLInputElement>) => void;
  onClose: () => void;
  onSubmit: () => void;
}) {
  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="md">
      <DialogTitle sx={{ fontWeight: 900 }}>
        {editingProduct ? 'Edit Product' : 'Create Product'}
      </DialogTitle>

      <DialogContent>
        <Grid container spacing={3} sx={{ mt: 1 }}>
          <Grid size={{ xs: 12, md: 6 }}>
            <TextField
              select
              fullWidth
              label="Category"
              value={form.categoryId}
              onChange={onChange('categoryId')}
              required
            >
              {categories.map((category) => (
                <MenuItem key={category.id} value={String(category.id)}>
                  {category.name}
                </MenuItem>
              ))}
            </TextField>
          </Grid>

          <Grid size={{ xs: 12, md: 6 }}>
            <TextField
              fullWidth
              label="Product Name"
              value={form.name}
              onChange={onChange('name')}
              required
            />
          </Grid>

          <Grid size={{ xs: 12 }}>
            <TextField
              fullWidth
              label="Slug"
              value={form.slug}
              onChange={onChange('slug')}
              required
              helperText="Used in URL and upload folder."
            />
          </Grid>

          <Grid size={{ xs: 12 }}>
            <TextField
              fullWidth
              multiline
              minRows={4}
              label="Description"
              value={form.description}
              onChange={onChange('description')}
            />
          </Grid>

          <Grid size={{ xs: 12, md: 4 }}>
            <TextField
              fullWidth
              label="Price"
              type="number"
              value={form.price}
              onChange={onChange('price')}
              required
            />
          </Grid>

          <Grid size={{ xs: 12, md: 4 }}>
            <TextField
              fullWidth
              label="Stock Quantity"
              type="number"
              value={form.stockQuantity}
              onChange={onChange('stockQuantity')}
              required
            />
          </Grid>

          <Grid size={{ xs: 12, md: 4 }}>
            <TextField
              select
              fullWidth
              label="Status"
              value={form.status}
              onChange={onChange('status')}
            >
              <MenuItem value="ACTIVE">Active</MenuItem>
              <MenuItem value="INACTIVE">Inactive</MenuItem>
            </TextField>
          </Grid>
        </Grid>
      </DialogContent>

      <DialogActions sx={{ px: 3, pb: 3 }}>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="contained" onClick={onSubmit}>
          {editingProduct ? 'Save Changes' : 'Create Product'}
        </Button>
      </DialogActions>
    </Dialog>
  );
}

function slugify(value: string): string {
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
