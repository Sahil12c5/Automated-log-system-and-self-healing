<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AutoHeal | Autonomous Log Aggregation &amp; Self-Healing Platform</title>
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
                <!-- Live System Indicator -->
                <div class="d-none d-md-flex align-items-center gap-2 px-3 py-1.5 rounded-pill" style="background: rgba(16, 185, 129, 0.12); border: 1px solid rgba(16, 185, 129, 0.25);">
                    <span class="pulse-indicator"></span>
                    <span class="small fw-semibold" style="color: #34d399;">Multi-Tenant Live</span>
                </div>

                <!-- Theme Switcher Toggle -->
                <button type="button" class="btn-theme-toggle" title="Toggle Theme">
                    <i class="bi bi-sun-fill text-warning"></i>
                </button>

                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-saas-primary">
                            <i class="bi bi-speedometer2"></i> Console Dashboard
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-saas-outline">Sign In</a>
                        <a href="${pageContext.request.contextPath}/signup" class="btn btn-saas-primary">
                            <i class="bi bi-rocket-takeoff-fill"></i> Get Started
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <div class="position-relative overflow-hidden pt-5 pb-4">
        <div class="hero-glow"></div>
        <div class="container py-4">
            <div class="row align-items-center justify-content-center text-center">
                <div class="col-lg-10 col-xl-9">
                    <div class="d-inline-flex align-items-center gap-2 px-3.5 py-1.5 rounded-pill mb-4" style="background: rgba(99, 102, 241, 0.12); border: 1px solid rgba(99, 102, 241, 0.3);">
                        <i class="bi bi-shield-check text-primary"></i>
                        <span class="small fw-semibold text-primary">Autonomous SRE &amp; Self-Healing Infrastructure</span>
                    </div>

                    <h1 class="display-3 fw-bold mb-4" style="letter-spacing: -0.035em; line-height: 1.15;">
                        Intelligent Log Ingestion &amp; <br>
                        <span class="brand-gradient">Instant Self-Healing</span>
                    </h1>

                    <p class="lead text-muted mb-5 mx-auto" style="max-width: 680px; font-size: 1.15rem;">
                        Eliminate manual incident triage. Ingest multi-tenant service logs in real time, diagnose root causes with Gemini AI, and trigger deterministic recovery scripts automatically.
                    </p>

                    <div class="d-flex justify-content-center gap-3 flex-wrap mb-5">
                        <a href="${pageContext.request.contextPath}/signup" class="btn btn-saas-primary btn-lg px-4 py-3">
                            <i class="bi bi-rocket-takeoff-fill me-1"></i> Register Organization Free
                        </a>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-saas-outline btn-lg px-4 py-3">
                            <i class="bi bi-key-fill me-1"></i> Sign In to Console
                        </a>
                    </div>
                </div>
            </div>

            <!-- Interactive Architecture Preview Window -->
            <div class="row justify-content-center mt-3">
                <div class="col-lg-11 col-xl-10">
                    <div class="terminal-window">
                        <div class="terminal-header">
                            <div class="terminal-dots">
                                <span class="terminal-dot dot-red"></span>
                                <span class="terminal-dot dot-yellow"></span>
                                <span class="terminal-dot dot-green"></span>
                            </div>
                            <span class="terminal-title"><i class="bi bi-terminal me-1"></i> autoheal-agent-stream -- live telemetry</span>
                            <span class="badge badge-status-active"><i class="bi bi-broadcast me-1"></i> Ingesting (Port 8080)</span>
                        </div>
                        <div class="terminal-body" style="font-size: 0.85rem; max-height: 240px;">
                            <div class="text-muted">[20:25:01.120] [AGENT] Connected to cluster api.payment-service.internal with API Key: 9f8e4b2...</div>
                            <div class="text-warning">[20:25:02.404] [WARN] Connection pool usage reached 88% (44/50 active connections)</div>
                            <div class="text-danger">[20:25:03.011] [ERROR] org.postgresql.util.PSQLException: FATAL - Connection pool exhausted!</div>
                            <div style="color: #38bdf8;">[20:25:03.025] [AUTOHEAL] Pattern matched: "Connection pool exhausted" in Rule #104</div>
                            <div style="color: #34d399; font-weight: 600;">[20:25:03.090] [SUCCESS] Autonomous Recovery Executed: RESTART_SERVICE -> pool recycled in 68ms</div>
                            <div class="text-muted">[20:25:04.100] [AUDIT] Log saved to immutable tenant audit trail. Status: AUTO_HEALED</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Features Highlights Grid -->
            <div class="row g-4 mt-5">
                <div class="col-md-4">
                    <div class="saas-card p-4 h-100">
                        <div class="stat-card-icon mb-3">
                            <i class="bi bi-shield-lock"></i>
                        </div>
                        <h5 class="fw-bold mb-2">Multi-Tenant Vault</h5>
                        <p class="text-muted small mb-0">Strict organization boundaries with role-based access control (Owner, Manager, Senior Dev, Dev) and complete data isolation.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="saas-card p-4 h-100">
                        <div class="stat-card-icon mb-3" style="background: rgba(20, 184, 166, 0.14); color: var(--accent-teal);">
                            <i class="bi bi-robot"></i>
                        </div>
                        <h5 class="fw-bold mb-2">Gemini AI Diagnostics</h5>
                        <p class="text-muted small mb-0">Unknown errors automatically invoke Gemini LLM to parse stack traces, extract root causes, and propose remediation scripts.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="saas-card p-4 h-100">
                        <div class="stat-card-icon mb-3" style="background: rgba(217, 70, 239, 0.14); color: #d946ef;">
                            <i class="bi bi-lightning-charge"></i>
                        </div>
                        <h5 class="fw-bold mb-2">Sub-Second Recovery</h5>
                        <p class="text-muted small mb-0">Deterministic rules execute recovery scripts in milliseconds with loop guardrails and command blacklisting protection.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="py-4 border-top border-secondary border-opacity-20 text-center text-muted small mt-5">
        <div class="container d-flex flex-wrap justify-content-between align-items-center gap-2">
            <span>&copy; 2026 AutoHeal Platform. Automated Multi-Tenant Log System &amp; Self-Healing Engine.</span>
            <div class="d-flex align-items-center gap-3">
                <span class="pulse-indicator"></span>
                <span>All Systems Operational</span>
            </div>
        </div>
    </footer>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
