<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Organization Registration | AutoHeal Engine</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/theme.css" rel="stylesheet">
</head>
<body>

    <!-- Navbar -->
    <nav class="navbar navbar-saas">
        <div class="container-fluid px-lg-5">
            <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/">
                <div class="brand-icon-wrapper">
                    <i class="bi bi-cpu-fill fs-5"></i>
                </div>
                <span class="brand-gradient">AutoHeal Engine</span>
            </a>
            <div class="d-flex align-items-center gap-3">
                <button type="button" class="btn-theme-toggle" title="Toggle Theme">
                    <i class="bi bi-sun-fill text-warning"></i>
                </button>
                <div class="d-flex align-items-center">
                    <span class="text-muted me-2 small d-none d-sm-inline">Already registered?</span>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-saas-outline btn-sm">Sign In</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Signup Form Wrapper -->
    <div class="auth-wrapper">
        <div class="hero-glow"></div>
        <div class="auth-card">
            <div class="text-center mb-4">
                <div class="d-inline-flex align-items-center justify-content-center p-3 rounded-circle mb-3" style="background: rgba(99, 102, 241, 0.15);">
                    <i class="bi bi-building-add text-primary fs-2"></i>
                </div>
                <h3 class="fw-bold">Register Organization</h3>
                <p class="text-muted small">Create your multi-tenant workspace and Owner administrative vault</p>
            </div>

            <!-- Error Banner -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger bg-danger bg-opacity-10 border-danger text-danger rounded-3 d-flex align-items-center gap-2 mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                    <div><c:out value="${error}" /></div>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/signup" method="POST" id="signupForm" class="needs-validation" novalidate>
                <!-- Organization Name -->
                <div class="mb-3">
                    <label class="form-label-custom" for="orgName">Organization Name <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-buildings"></i></span>
                        <input type="text" class="form-control form-control-saas" id="orgName" name="orgName" placeholder="e.g. Acme Cloud Corp" required>
                        <div class="invalid-feedback">Organization Name is required.</div>
                    </div>
                </div>

                <!-- Owner Full Name -->
                <div class="mb-3">
                    <label class="form-label-custom" for="fullName">Owner Full Name <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-person"></i></span>
                        <input type="text" class="form-control form-control-saas" id="fullName" name="fullName" placeholder="Sarah Connor" required>
                        <div class="invalid-feedback">Full Name is required.</div>
                    </div>
                </div>

                <!-- Owner Email -->
                <div class="mb-3">
                    <label class="form-label-custom" for="email">Work Email <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                        <input type="email" class="form-control form-control-saas" id="email" name="email" placeholder="owner@acme.com" required>
                        <div class="invalid-feedback">Please enter a valid email address.</div>
                    </div>
                </div>

                <!-- Password with Strength Meter & Eye Toggle -->
                <div class="mb-4">
                    <label class="form-label-custom" for="signupPassword">Account Master Password <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-lock"></i></span>
                        <input type="password" class="form-control form-control-saas" id="signupPassword" name="password" placeholder="••••••••••••" required minlength="8">
                        <button class="btn btn-saas-outline btn-toggle-password" type="button" data-target="signupPassword">
                            <i class="bi bi-eye"></i>
                        </button>
                        <div class="invalid-feedback">Password must be at least 8 characters long.</div>
                    </div>
                    <div class="strength-meter mt-2">
                        <div class="strength-bar" id="strengthBar"></div>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mt-1">
                        <span class="text-muted small" id="strengthText">Min. 8 characters</span>
                        <span class="text-muted small"><i class="bi bi-shield-check text-success me-1"></i>BCrypt Hash Vault</span>
                    </div>
                </div>

                <!-- Submit Button -->
                <button type="submit" class="btn btn-saas-primary w-100 py-2.5">
                    <i class="bi bi-arrow-right-circle me-1"></i> Initialize Organization &amp; Account
                </button>
            </form>

            <div class="mt-4 pt-3 border-top border-secondary border-opacity-20 text-center">
                <span class="text-muted small">By registering, you agree to multi-tenant isolation and security guardrail policies.</span>
            </div>
        </div>
    </div>

    <!-- Toast Notifications Container -->
    <div id="toastContainer"></div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
