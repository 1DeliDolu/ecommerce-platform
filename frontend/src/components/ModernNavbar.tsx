import React from 'react';
import { Link, NavLink } from 'react-router-dom';
import { useAuth } from '../features/auth/AuthContext';

export default function ModernNavbar() {
  const auth = useAuth();

  return (
    <nav className="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm sticky-top">
      <div className="container-fluid px-4">
        <Link className="navbar-brand fw-bold d-flex align-items-center gap-2" to="/">
          <i className="bi bi-bag-check-fill text-warning" aria-hidden="true"></i>
          Enterprise Shop
        </Link>

        <button
          className="navbar-toggler border-0"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#mainNavbar"
          aria-controls="mainNavbar"
          aria-expanded="false"
          aria-label="Toggle navigation"
        >
          <span className="navbar-toggler-icon"></span>
        </button>

        <div className="collapse navbar-collapse" id="mainNavbar">
          <ul className="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-4">
            <li className="nav-item">
              <NavLink className="nav-link" to="/" end>Home</NavLink>
            </li>

            <li className="nav-item">
              <NavLink className="nav-link" to="/products">Products</NavLink>
            </li>

            {auth.isAuthenticated && (
              <li className="nav-item">
                <NavLink className="nav-link" to="/orders">My Orders</NavLink>
              </li>
            )}

            {auth.hasAnyPermission(['PRODUCT_READ', 'CATEGORY_READ']) && (
              <li className="nav-item dropdown">
                <button
                  className="nav-link dropdown-toggle btn btn-link text-white"
                  data-bs-toggle="dropdown"
                  aria-expanded="false"
                >
                  Admin
                </button>
                <ul className="dropdown-menu">
                  <li>
                    <NavLink className="dropdown-item" to="/admin/products">
                      <i className="bi bi-box me-2" aria-hidden="true"></i>Products
                    </NavLink>
                  </li>
                  <li>
                    <NavLink className="dropdown-item" to="/admin/categories">
                      <i className="bi bi-tags me-2" aria-hidden="true"></i>Categories
                    </NavLink>
                  </li>
                </ul>
              </li>
            )}
          </ul>

          <div className="d-flex align-items-center gap-2">
            <Link className="btn btn-outline-warning position-relative" to="/products" aria-label="Cart">
              <i className="bi bi-cart3" aria-hidden="true"></i>
            </Link>

            {auth.isAuthenticated ? (
              <div className="dropdown">
                <button
                  className="btn btn-warning dropdown-toggle d-flex align-items-center gap-2"
                  type="button"
                  data-bs-toggle="dropdown"
                  aria-expanded="false"
                >
                  <i className="bi bi-person-circle" aria-hidden="true"></i>
                  <span className="d-none d-md-inline">{auth.user?.fullName}</span>
                </button>

                <ul className="dropdown-menu dropdown-menu-end shadow">
                  <li><h6 className="dropdown-header">{auth.user?.role}</h6></li>
                  <li>
                    <Link className="dropdown-item" to="/orders">
                      <i className="bi bi-receipt me-2" aria-hidden="true"></i>My Orders
                    </Link>
                  </li>
                  <li><hr className="dropdown-divider" /></li>
                  <li>
                    <button
                      className="dropdown-item text-danger"
                      type="button"
                      onClick={auth.logout}
                    >
                      <i className="bi bi-box-arrow-right me-2" aria-hidden="true"></i>Logout
                    </button>
                  </li>
                </ul>
              </div>
            ) : (
              <Link className="btn btn-warning" to="/login">
                <i className="bi bi-box-arrow-in-right me-2" aria-hidden="true"></i>Login
              </Link>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
}
