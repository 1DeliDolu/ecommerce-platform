export type CategoryStatus = 'ACTIVE' | 'INACTIVE';

export type Category = {
  id: number;
  name: string;
  slug: string;
  description: string;
  productCount: number;
  status: CategoryStatus;
  createdAt: string;
};

export type CreateCategoryRequest = {
  name: string;
  slug: string;
  description: string;
  status: CategoryStatus;
};

export type UpdateCategoryRequest = CreateCategoryRequest;
