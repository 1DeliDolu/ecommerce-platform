import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import './styles.css';

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
    <main className="page">
      <section className="hero">
        <p className="eyebrow">Docker + Java + TypeScript + PostgreSQL + Monitoring</p>
        <h1>Modern Ecommerce Platform</h1>
        <p>Backend status: <strong>{health}</strong></p>
        <button onClick={loginAsAdmin}>Demo Admin JWT Al</button>
      </section>

      {token && (
        <section className="card">
          <h2>JWT Token</h2>
          <code>{token}</code>
        </section>
      )}

      <section className="grid">
        {products.map((product) => (
          <article className="card" key={product.id}>
            <h2>{product.name}</h2>
            <p>{product.description}</p>
            <strong>€{Number(product.price).toFixed(2)}</strong>
            <span>Stock: {product.stock}</span>
          </article>
        ))}
      </section>
    </main>
  );
}

createRoot(document.getElementById('root')!).render(<App />);
