import { LoginRequest, LoginResponse } from "./authTypes";

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8080";

export async function login(request: LoginRequest): Promise<LoginResponse> {
  const response = await fetch(`${API_BASE_URL}/api/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(request),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(text || `Login failed: ${response.status}`);
  }

  return response.json() as Promise<LoginResponse>;
}
