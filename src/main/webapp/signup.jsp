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
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/theme.css" rel="stylesheet">
</head>
<body>

    <!-- Navbar -->
    <nav class="navbar navbar-saas">
        <div class="container-fluid px-4">
            <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/">
                <i class="bi bi-cpu-fill text-primary fs-3"></i>
                <span class="brand-gradient">AutoHeal Engine</span>
            </a>
            <div>
                <span class="text-muted me-2 font-size-sm">Already registered?</span>
                <a href="${pageContext.request.contextPath}/login" class="btn btn-saas-outline btn-sm">Sign In</a>
            </div>
        </div>
    </nav>

    <!-- Signup Form Wrapper -->
    <div class="auth-wrapper">
        <div class="auth-card">
            <div class="text-center mb-4">
                <div class="d-inline-flex align-items-center justify-content-center p-3 rounded-circle mb-3" style="background: rgba(99, 102, 241, 0.15);">
                    <i class="bi bi-building-add text-primary fs-2"></i>
                </div>
                <h3 class="text-dark fw-bold">Register Organization</h3>
                <p class="text-muted small">Create your multi-tenant workspace and Owner account</p>
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
                    <label class="form-label-custom" for="orgName">Organization Name</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light border-secondary text-muted"><i class="bi bi-buildings"></i></span>
                        <input type="text" class="form-control form-control-saas" id="orgName" name="orgName" placeholder="e.g. Acme Cloud Solutions" required>
                        <div class="invalid-feedback">Organization Name is required.</div>
                    </div>
                </div>

                <!-- Owner Full Name -->
                <div class="mb-3">
                    <label class="form-label-custom" for="fullName">Owner Full Name</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light border-secondary text-muted"><i class="bi bi-person"></i></span>
                        <input type="text" class="form-control form-control-saas" id="fullName" name="fullName" placeholder="e.g. Sarah Connor" required>
                        <div class="invalid-feedback">Full Name is required.</div>
                    </div>
                </div>

                <!-- Owner Email -->
                <div class="mb-3">
                    <label class="form-label-custom" for="email">Work Email</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light border-secondary text-muted"><i class="bi bi-envelope"></i></span>
                        <input type="email" class="form-control form-control-saas" id="email" name="email" placeholder="owner@company.com" required>
                        <div class="invalid-feedback">Please enter a valid email address.</div>
                    </div>
                </div>

                <!-- Password with Strength Meter -->
                <div class="mb-4">
                    <label class="form-label-custom" for="signupPassword">Account Password</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light border-secondary text-muted"><i class="bi bi-lock"></i></span>
                        <input type="password" class="form-control form-control-saas" id="signupPassword" name="password" placeholder="â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢" required minlength="8">
                        <div class="invalid-feedback">Password must be at least 8 characters long.</div>
                    </div>
                    <div class="strength-meter mt-2">
                        <div class="strength-bar" id="strengthBar"></div>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mt-1">
                        <span class="text-muted small" id="strengthText">Min. 8 characters</span>
                        <span class="text-muted small">BCrypt Secured</span>
                    </div>
                </div>

                <!-- Submit Button -->
                <button type="submit" class="btn btn-saas-primary w-100 py-2.5">
                    <i class="bi bi-arrow-right-circle me-1"></i> Initialize Organization &amp; Account
                </button>
            </form>

            <div class="mt-4 pt-3 border-top border-secondary border-opacity-20 text-center">
                <span class="text-muted small">By registering, you agree to multi-tenant isolation policies.</span>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>

