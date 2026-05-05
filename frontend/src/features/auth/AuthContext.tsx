import React, { createContext, useContext, useMemo, useState } from 'react';
import { clearAuth, getAuthUser, saveAuth } from './authStorage';
import { login as loginApi } from './authApi';
import { AuthUser, LoginRequest, Permission, UserRole } from './authTypes';

type AuthContextValue = {
  user: AuthUser | null;
  isAuthenticated: boolean;
  login: (request: LoginRequest) => Promise<void>;
  logout: () => void;
  hasRole: (roles: UserRole[]) => boolean;
  hasPermission: (permission: Permission) => boolean;
  hasAnyPermission: (permissions: Permission[]) => boolean;
};

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(() => getAuthUser());

  const value = useMemo<AuthContextValue>(
    () => ({
      user,
      isAuthenticated: Boolean(user),

      login: async (request: LoginRequest) => {
        const response = await loginApi(request);
        saveAuth(response.accessToken, response.user, response.refreshToken);
        setUser(response.user);
      },

      logout: () => {
        clearAuth();
        setUser(null);
      },

      hasRole: (roles: UserRole[]) => (user ? roles.includes(user.role) : false),

      hasPermission: (permission: Permission) =>
        user ? user.permissions.includes(permission) : false,

      hasAnyPermission: (permissions: Permission[]) =>
        user ? permissions.some((p) => user.permissions.includes(p)) : false,
    }),
    [user]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used inside AuthProvider');
  return context;
}
