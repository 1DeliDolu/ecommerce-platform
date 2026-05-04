export type UserRole = 'CUSTOMER' | 'ADMIN' | 'EMPLOYEE';

export type Permission =
  | 'PRODUCT_READ'
  | 'PRODUCT_CREATE'
  | 'PRODUCT_UPDATE'
  | 'PRODUCT_DELETE'
  | 'PRODUCT_IMAGE_UPLOAD'
  | 'PRODUCT_IMAGE_DELETE'
  | 'PRODUCT_IMAGE_SET_PRIMARY'
  | 'CATEGORY_READ'
  | 'CATEGORY_CREATE'
  | 'CATEGORY_UPDATE'
  | 'CATEGORY_DELETE'
  | 'ORDER_READ_OWN'
  | 'ORDER_READ_ALL'
  | 'USER_MANAGE'
  | 'ROLE_MANAGE'
  | 'ADMIN_PANEL_ACCESS';

export type AuthUser = {
  email: string;
  fullName: string;
  role: UserRole;
  permissions: Permission[];
};

export type LoginRequest = {
  email: string;
  password: string;
};

export type LoginResponse = {
  accessToken: string;
  user: AuthUser;
};
