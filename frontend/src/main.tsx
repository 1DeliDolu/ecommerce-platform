import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap-icons/font/bootstrap-icons.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import './styles.css';
import ModernNavbar from './components/ModernNavbar';
import AdminProductsPage from './features/admin/products/AdminProductsPage';

type Product = {
  id: number;
  name: string;
  description: string;
  price: number;
  stock: number;
};

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080';

function App() {
  const [health, setHealth] = useState<string>('checking...');
  const [products, setProducts] = useState<Product[]>([]);
  const [token, setToken] = useState<string>('');

  useEffect(() => {
    fetch(`${API_BASE_URL}/api/health`)
      .then((r) => r.json())
      .then((data) => setHealth(data.status))
      .catch(() => setHealth('DOWN'));

    fetch(`${API_BASE_URL}/api/products`)
      .then((r) => r.json())
      .then(setProducts)
      .catch(() => setProducts([]));
  }, []);

  async function loginAsAdmin() {
    const res = await fetch(`${API_BASE_URL}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'admin@example.com', password: 'admin123' })
    });
    const data = await res.json();
    setToken(data.accessToken);
  }

  return (
    <>
      <ModernNavbar />

      <section className="app-status-bar">
        <span>Backend: <strong>{health}</strong></span>
        <span>Catalog API: <strong>{products.length}</strong> products</span>
        <button className="btn btn-sm btn-warning fw-bold" onClick={loginAsAdmin}>Demo Admin JWT Al</button>
      </section>

      {token && (
        <section className="token-panel">
          <h2>JWT Token</h2>
          <code>{token}</code>
        </section>
      )}

      <AdminProductsPage />
    </>
  );
}

createRoot(document.getElementById('root')!).render(<App />);
