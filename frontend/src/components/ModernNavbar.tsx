import { Link, NavLink, useNavigate } from "react-router-dom";
import { tokenStorage } from "../security/token-storage";

export default function ModernNavbar() {
  const navigate = useNavigate();

  const handleLogout = () => {
    tokenStorage.remove();
    navigate("/login");
  };

  const isLoggedIn = Boolean(tokenStorage.get());

  return (
    <nav className="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm sticky-top">
      <div className="container-fluid px-4">
        <Link
          className="navbar-brand fw-bold d-flex align-items-center gap-2"
          to="/">
          <i
            className="bi bi-bag-check-fill text-warning"
            aria-hidden="true"></i>
          Enterprise Shop
        </Link>

        <button
          className="navbar-toggler border-0"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#mainNavbar"
          aria-controls="mainNavbar"
          aria-expanded="false"
          aria-label="Toggle navigation">
          <span className="navbar-toggler-icon"></span>
        </button>

        <div className="collapse navbar-collapse" id="mainNavbar">
          <ul className="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-4">
            <li className="nav-item">
              <NavLink className="nav-link" to="/" end>
                Home
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink className="nav-link" to="/products">
                Products
              </NavLink>
            </li>
            <li className="nav-item dropdown">
              <button
                className="nav-link dropdown-toggle btn btn-link text-white"
                data-bs-toggle="dropdown"
                aria-expanded="false">
                Admin
              </button>
              <ul className="dropdown-menu">
                <li>
                  <Link className="dropdown-item" to="/admin/products">
                    <i className="bi bi-box me-2"></i>Products
                  </Link>
                </li>
                <li>
                  <Link className="dropdown-item" to="/admin/categories">
                    <i className="bi bi-tags me-2"></i>Categories
                  </Link>
                </li>
              </ul>
            </li>
          </ul>

          <form
            className="d-flex me-lg-3 my-3 my-lg-0 navbar-search"
            role="search">
            <div className="input-group">
              <span className="input-group-text bg-light border-0">
                <i className="bi bi-search" aria-hidden="true"></i>
              </span>
              <input
                className="form-control border-0"
                type="search"
                placeholder="Search products..."
                aria-label="Search products"
              />
            </div>
          </form>

          <div className="d-flex align-items-center gap-2">
            <button
              className="btn btn-outline-light position-relative"
              type="button"
              aria-label="Messages">
              <i className="bi bi-envelope" aria-hidden="true"></i>
              <span className="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                4
              </span>
            </button>

            <button
              className="btn btn-outline-light position-relative"
              type="button"
              aria-label="Notifications">
              <i className="bi bi-bell" aria-hidden="true"></i>
              <span className="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                17
              </span>
            </button>

            <button
              className="btn btn-outline-warning position-relative"
              type="button"
              aria-label="Cart">
              <i className="bi bi-cart3" aria-hidden="true"></i>
              <span className="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-success">
                3
              </span>
            </button>

            <div className="dropdown">
              <button
                className="btn btn-warning dropdown-toggle d-flex align-items-center gap-2"
                type="button"
                data-bs-toggle="dropdown"
                aria-expanded="false">
                <i className="bi bi-person-circle" aria-hidden="true"></i>
                <span className="d-none d-md-inline">Musta</span>
              </button>

              <ul className="dropdown-menu dropdown-menu-end shadow">
                <li>
                  <h6 className="dropdown-header">Account</h6>
                </li>
                <li>
                  <Link className="dropdown-item" to="/profile">
                    <i className="bi bi-person me-2" aria-hidden="true"></i>
                    Profile
                  </Link>
                </li>
                <li>
                  <Link className="dropdown-item" to="/orders">
                    <i className="bi bi-receipt me-2" aria-hidden="true"></i>
                    My Orders
                  </Link>
                </li>
                <li>
                  <Link className="dropdown-item" to="/settings">
                    <i className="bi bi-gear me-2" aria-hidden="true"></i>
                    Settings
                  </Link>
                </li>
                <li>
                  <hr className="dropdown-divider" />
                </li>
                <li>
                  {isLoggedIn ? (
                    <button className="dropdown-item text-danger" type="button" onClick={handleLogout}>
                      <i className="bi bi-box-arrow-right me-2" aria-hidden="true"></i>
                      Logout
                    </button>
                  ) : (
                    <Link className="dropdown-item" to="/login">
                      <i className="bi bi-box-arrow-in-right me-2" aria-hidden="true"></i>
                      Login
                    </Link>
                  )}
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </nav>
  );
}
