import { LoginRequest, LoginResponse, Permission, UserRole } from "./authTypes";

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8080";

type BackendLoginResponse = {
  accessToken: string;
  tokenType: string;
  role: UserRole;
};

const ROLE_PERMISSIONS: Record<UserRole, Permission[]> = {
  ADMIN: [
    "ADMIN_PANEL_ACCESS",
    "PRODUCT_READ",
    "PRODUCT_CREATE",
    "PRODUCT_UPDATE",
    "PRODUCT_DELETE",
    "PRODUCT_IMAGE_UPLOAD",
    "PRODUCT_IMAGE_DELETE",
    "PRODUCT_IMAGE_SET_PRIMARY",
    "CATEGORY_READ",
    "CATEGORY_CREATE",
    "CATEGORY_UPDATE",
    "CATEGORY_DELETE",
    "ORDER_READ_OWN",
    "ORDER_READ_ALL",
    "USER_MANAGE",
    "ROLE_MANAGE",
  ],
  EMPLOYEE: [
    "ADMIN_PANEL_ACCESS",
    "PRODUCT_READ",
    "PRODUCT_CREATE",
    "PRODUCT_UPDATE",
    "PRODUCT_IMAGE_UPLOAD",
    "PRODUCT_IMAGE_SET_PRIMARY",
    "CATEGORY_READ",
    "ORDER_READ_OWN",
  ],
  CUSTOMER: ["PRODUCT_READ", "ORDER_READ_OWN"],
};

export async function login(request: LoginRequest): Promise<LoginResponse> {
  // Use demo fallback for @example.com addresses (dev/test convenience)
  if (request.email.endsWith("@example.com")) {
    return demoLogin(request);
  }

  const response = await fetch(`${API_BASE_URL}/api/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(request),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(text || `Login failed: ${response.status}`);
  }

  const data: BackendLoginResponse = await response.json();
  const role = data.role as UserRole;

  return {
    accessToken: data.accessToken,
    user: {
      email: request.email,
      fullName: request.email.split("@")[0],
      role,
      permissions: ROLE_PERMISSIONS[role] ?? ROLE_PERMISSIONS.CUSTOMER,
    },
  };
}

function demoLogin(request: LoginRequest): LoginResponse {
  let role: UserRole = "CUSTOMER";
  let fullName = "Customer User";

  if (request.email === "admin@example.com") {
    role = "ADMIN";
    fullName = "Admin User";
  } else if (request.email === "employee@example.com") {
    role = "EMPLOYEE";
    fullName = "Employee User";
  }

  return {
    accessToken: `demo-${role.toLowerCase()}-token`,
    user: {
      email: request.email,
      fullName,
      role,
      permissions: ROLE_PERMISSIONS[role],
    },
  };
}
