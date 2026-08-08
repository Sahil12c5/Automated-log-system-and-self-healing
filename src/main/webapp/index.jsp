<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AutoHeal | Automated Log System &amp; Self-Healing Platform</title>
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
            <div class="d-flex align-items-center gap-3">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-saas-primary">
                            <i class="bi bi-speedometer2 me-1"></i> Go to Dashboard
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-saas-outline">Sign In</a>
                        <a href="${pageContext.request.contextPath}/signup" class="btn btn-saas-primary">Get Started</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <div class="container py-5 my-4">
        <div class="row align-items-center justify-content-center text-center">
            <div class="col-lg-10">
                <span class="badge bg-primary bg-opacity-20 text-primary border border-primary border-opacity-30 rounded-pill px-3 py-2 mb-3">
                    <i class="bi bi-shield-check me-1"></i> Phase 1 Multi-Tenant Engine Live
                </span>
                <h1 class="display-4 fw-bold text-dark mb-3">
                    Next-Gen Automated Log Aggregation <br>&amp; Autonomous Self-Healing
                </h1>
                <p class="lead text-muted max-w-2xl mx-auto mb-5">
                    Isolate multi-tenant logs, register domains, issue secure API keys, and manage granular tenant developer permissions with zero friction.
                </p>
                <div class="d-flex justify-content-center gap-3 flex-wrap">
                    <a href="${pageContext.request.contextPath}/signup" class="btn btn-saas-primary btn-lg px-4 py-3">
                        <i class="bi bi-rocket-takeoff-fill me-2"></i> Register Organization
                    </a>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-saas-outline btn-lg px-4 py-3">
                        <i class="bi bi-key-fill me-2"></i> Sign In to Account
                    </a>
                </div>
            </div>
        </div>

        <!-- Highlights Grid -->
        <div class="row g-4 mt-5">
            <div class="col-md-4">
                <div class="saas-card p-4 h-100">
                    <div class="stat-card-icon mb-3">
                        <i class="bi bi-buildings"></i>
                    </div>
                    <h5 class="text-dark mb-2">Multi-Tenant Isolation</h5>
                    <p class="text-muted mb-0">Strict organization boundaries with role-based access control (Owner, Manager, Senior Dev, Dev).</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="saas-card p-4 h-100">
                    <div class="stat-card-icon mb-3" style="background: rgba(20, 184, 166, 0.12); color: var(--accent-teal);">
                        <i class="bi bi-key"></i>
                    </div>
                    <h5 class="text-dark mb-2">Domain &amp; API Key Vault</h5>
                    <p class="text-muted mb-0">Register microservice domains and instantly generate secure UUID API keys with 1-click clipboard actions.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="saas-card p-4 h-100">
                    <div class="stat-card-icon mb-3" style="background: rgba(217, 70, 239, 0.12); color: #d946ef;">
                        <i class="bi bi-phone-vibrate"></i>
                    </div>
                    <h5 class="text-dark mb-2">Passwordless &amp; OTP Auth</h5>
                    <p class="text-muted mb-0">Enterprise passwordless login via 4-digit OTP codes and BCrypt-secured owner credential vaults.</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>

