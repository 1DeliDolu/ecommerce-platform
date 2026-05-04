export default function ModernNavbar() {
  return (
    <nav className="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm sticky-top">
      <div className="container-fluid px-4">
        <a className="navbar-brand fw-bold d-flex align-items-center gap-2" href="/">
          <i className="bi bi-bag-check-fill text-warning" aria-hidden="true"></i>
          Enterprise Shop
        </a>

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
              <a className="nav-link active" href="/" aria-current="page">
                Dashboard
              </a>
            </li>
            <li className="nav-item">
              <a className="nav-link" href="/products">
                Products
              </a>
            </li>
            <li className="nav-item">
              <a className="nav-link" href="/orders">
                Orders
              </a>
            </li>
            <li className="nav-item">
              <a className="nav-link" href="/monitoring">
                Monitoring
              </a>
            </li>
            <li className="nav-item">
              <a className="nav-link" href="/admin">
                Admin
              </a>
            </li>
          </ul>

          <form className="d-flex me-lg-3 my-3 my-lg-0 navbar-search" role="search">
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
            <button className="btn btn-outline-light position-relative" type="button" aria-label="Messages">
              <i className="bi bi-envelope" aria-hidden="true"></i>
              <span className="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                4
              </span>
            </button>

            <button className="btn btn-outline-light position-relative" type="button" aria-label="Notifications">
              <i className="bi bi-bell" aria-hidden="true"></i>
              <span className="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                17
              </span>
            </button>

            <button className="btn btn-outline-warning position-relative" type="button" aria-label="Cart">
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
                aria-expanded="false"
              >
                <i className="bi bi-person-circle" aria-hidden="true"></i>
                <span className="d-none d-md-inline">Musta</span>
              </button>

              <ul className="dropdown-menu dropdown-menu-end shadow">
                <li>
                  <h6 className="dropdown-header">Account</h6>
                </li>
                <li>
                  <a className="dropdown-item" href="/profile">
                    <i className="bi bi-person me-2" aria-hidden="true"></i>
                    Profile
                  </a>
                </li>
                <li>
                  <a className="dropdown-item" href="/orders">
                    <i className="bi bi-receipt me-2" aria-hidden="true"></i>
                    My Orders
                  </a>
                </li>
                <li>
                  <a className="dropdown-item" href="/settings">
                    <i className="bi bi-gear me-2" aria-hidden="true"></i>
                    Settings
                  </a>
                </li>
                <li>
                  <hr className="dropdown-divider" />
                </li>
                <li>
                  <button className="dropdown-item text-danger" type="button">
                    <i className="bi bi-box-arrow-right me-2" aria-hidden="true"></i>
                    Logout
                  </button>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </nav>
  );
}
