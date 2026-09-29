<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tenant Dashboard | AutoHeal Engine</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/theme.css" rel="stylesheet">
</head>
<body>

    <!-- Top Dashboard Navbar -->
    <nav class="navbar navbar-saas">
        <div class="container-fluid px-lg-4">
            <div class="d-flex align-items-center gap-3 gap-lg-4">
                <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/dashboard">
                    <div class="brand-icon-wrapper">
                        <i class="bi bi-cpu-fill fs-5"></i>
                    </div>
                    <span class="brand-gradient">AutoHeal Console</span>
                </a>

                <!-- Main Navigation Links -->
                <div class="d-none d-md-flex align-items-center gap-1">
                    <a href="${pageContext.request.contextPath}/dashboard" class="nav-link-saas active">
                        <i class="bi bi-speedometer2"></i> Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/logs" class="nav-link-saas">
                        <i class="bi bi-terminal-fill"></i> Live Logs
                    </a>
                    <a href="${pageContext.request.contextPath}/rules" class="nav-link-saas">
                        <i class="bi bi-magic"></i> Healing Rules
                    </a>
                    
                    <!-- AI & Approvals Dropdown -->
                    <div class="dropdown">
                        <button class="nav-link-saas dropdown-toggle border-0 bg-transparent" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-robot"></i> AI Engine
                        </button>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/diagnostics"><i class="bi bi-search text-primary"></i> Diagnostics</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/approvals"><i class="bi bi-check2-square text-warning"></i> Approvals Queue</a></li>
                        </ul>
                    </div>

                    <!-- Administration Dropdown -->
                    <div class="dropdown">
                        <button class="nav-link-saas dropdown-toggle border-0 bg-transparent" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-shield-lock"></i> Admin
                        </button>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/team"><i class="bi bi-people text-info"></i> Team Management</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/audit"><i class="bi bi-clock-history text-secondary"></i> Audit Trail</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/guardrails"><i class="bi bi-shield-lock text-danger"></i> Guardrails</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/simulation"><i class="bi bi-play-circle text-success"></i> Simulation Console</a></li>
                        </ul>
                    </div>
                </div>
            </div>
            
            <div class="d-flex align-items-center gap-3">
                <!-- Theme Switcher Toggle -->
                <button type="button" class="btn-theme-toggle" title="Toggle Theme">
                    <i class="bi bi-sun-fill text-warning"></i>
                </button>

                <!-- Tenant Org Badge -->
                <div class="d-none d-lg-flex align-items-center gap-2 px-3 py-1.5 rounded-pill" style="background: rgba(99, 102, 241, 0.1); border: 1px solid rgba(99, 102, 241, 0.25);">
                    <i class="bi bi-buildings text-primary"></i>
                    <span class="small fw-semibold"><c:out value="${sessionScope.orgName}" default="Organization" /></span>
                </div>

                <!-- User Profile & Role -->
                <div class="dropdown">
                    <button class="btn btn-saas-outline d-flex align-items-center gap-2 py-1.5 px-3 dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <div class="rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width:28px; height:28px; font-size:12px; background: var(--primary-gradient); color: #ffffff;">
                            <c:out value="${sessionScope.user.fullName.substring(0, 1)}" default="U" />
                        </div>
                        <span class="small fw-medium d-none d-sm-inline"><c:out value="${sessionScope.user.fullName}" default="User" /></span>
                        <span class="badge badge-role role-${sessionScope.user.role}"><c:out value="${sessionScope.user.role}" default="MEMBER" /></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><h6 class="dropdown-header text-muted"><c:out value="${sessionScope.user.email}" /></h6></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right"></i> Sign Out</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Container -->
    <div class="container-fluid px-lg-4 py-4">
        
        <!-- Welcome Alert Banner -->
        <c:if test="${param.welcome eq 'true'}">
            <div class="alert alert-success bg-success bg-opacity-15 border-success text-success rounded-3 d-flex align-items-center justify-content-between p-3 mb-4" role="alert">
                <div class="d-flex align-items-center gap-3">
                    <i class="bi bi-stars text-success fs-3"></i>
                    <div>
                        <h6 class="mb-0 fw-bold">Welcome to AutoHeal Platform!</h6>
                        <span class="small">Your organization account is initialized. Start by registering your first microservice domain.</span>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Metric Summary Cards -->
        <div class="row g-3 mb-4">
            <!-- Card 1: Total Domains -->
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="stat-card-metric">
                    <div class="stat-card-icon">
                        <i class="bi bi-globe2"></i>
                    </div>
                    <div>
                        <span class="text-muted small text-uppercase fw-semibold">Registered Domains</span>
                        <h3 class="fw-bold mb-0 mt-1"><c:out value="${totalDomains}" default="0" /></h3>
                    </div>
                </div>
            </div>

            <!-- Card 2: Active API Keys -->
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="stat-card-metric">
                    <div class="stat-card-icon" style="background: rgba(20, 184, 166, 0.15); color: var(--accent-teal);">
                        <i class="bi bi-key-fill"></i>
                    </div>
                    <div>
                        <span class="text-muted small text-uppercase fw-semibold">Active API Keys</span>
                        <h3 class="fw-bold mb-0 mt-1"><c:out value="${activeApiKeys}" default="0" /></h3>
                    </div>
                </div>
            </div>

            <!-- Card 3: Ingested Logs -->
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="stat-card-metric">
                    <div class="stat-card-icon" style="background: rgba(6, 182, 212, 0.15); color: var(--accent-cyan);">
                        <i class="bi bi-terminal-fill"></i>
                    </div>
                    <div>
                        <span class="text-muted small text-uppercase fw-semibold">Ingested Logs</span>
                        <h3 class="fw-bold mb-0 mt-1"><c:out value="${totalLogs}" default="0" /></h3>
                    </div>
                </div>
            </div>

            <!-- Card 4: Auto-Healed Events -->
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="stat-card-metric">
                    <div class="stat-card-icon" style="background: rgba(16, 185, 129, 0.15); color: var(--success-text);">
                        <i class="bi bi-magic"></i>
                    </div>
                    <div>
                        <span class="text-muted small text-uppercase fw-semibold">Auto-Healed Recoveries</span>
                        <h3 class="fw-bold mb-0 mt-1"><c:out value="${autoHealedLogs}" default="0" /></h3>
                    </div>
                </div>
            </div>
        </div>

        <!-- Domain Management & Data Table -->
        <div class="saas-card mb-4">
            <div class="p-3.5 px-4 border-bottom border-secondary border-opacity-20 d-flex flex-wrap align-items-center justify-content-between gap-3">
                <div>
                    <h5 class="fw-bold mb-0"><i class="bi bi-hdd-network text-primary me-2"></i> Registered Domains &amp; API Keys</h5>
                    <span class="text-muted small">Manage microservice endpoints and security keys routing to AutoHeal</span>
                </div>
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <div class="input-group" style="width: 240px;">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control form-control-saas" id="tableSearchInput" placeholder="Filter domains...">
                    </div>
                    <button type="button" class="btn btn-saas-outline" onclick="showDeploymentModal('${not empty domains ? domains[0].apiKey : ''}', '${not empty domains ? domains[0].domainName : 'All Domains'}')" title="Agent Deployment Guides">
                        <i class="bi bi-book me-1 text-info"></i> Deployment Guide
                    </button>
                    <button type="button" class="btn btn-saas-primary" data-bs-toggle="modal" data-bs-target="#addDomainModal">
                        <i class="bi bi-plus-lg"></i> Add New Domain
                    </button>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-saas">
                    <thead>
                        <tr>
                            <th>Domain Name</th>
                            <th>Status</th>
                            <th>GitHub Integration</th>
                            <th>Creation Date</th>
                            <th>API Key Vault</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty domains}">
                                <c:forEach var="dom" items="${domains}">
                                    <c:set var="fullKey" value="${dom.apiKey}" />
                                    <c:set var="maskedKey" value="${dom.apiKey.substring(0, 12)}...${dom.apiKey.substring(dom.apiKey.length() - 4)}" />
                                    
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <i class="bi bi-hdd-network text-primary fs-5"></i>
                                                <span class="fw-semibold"><c:out value="${dom.domainName}" /></span>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge badge-status-active">
                                                <i class="bi bi-check-circle-fill"></i> Active
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty dom.githubRepo}">
                                                    <span class="badge bg-dark border border-secondary text-light">
                                                        <i class="bi bi-github me-1"></i> <c:out value="${dom.githubRepo}" />
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted small fst-italic">Not Linked</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-muted small">
                                            <fmt:formatDate value="${dom.createdAt}" pattern="MMM dd, yyyy HH:mm" />
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="api-key-box" id="key-elem-${dom.id}" data-full-key="${fullKey}" data-masked-key="${maskedKey}">${maskedKey}</div>
                                                
                                                <!-- Toggle Eye Button -->
                                                <button type="button" class="btn btn-saas-outline btn-sm btn-toggle-key py-1 px-2" data-target="key-elem-${dom.id}" title="Toggle View API Key">
                                                    <i class="bi bi-eye"></i>
                                                </button>
                                                
                                                <!-- Copy Button -->
                                                <button type="button" class="btn btn-saas-outline btn-sm btn-copy-key py-1 px-2" data-key="${fullKey}" title="Copy API Key">
                                                    <i class="bi bi-clipboard"></i> Copy
                                                </button>
                                            </div>
                                        </td>
                                        <td class="text-end text-nowrap">
                                            <button type="button" class="btn btn-saas-primary btn-sm px-2.5 py-1 me-1" onclick="showDeploymentModal('${fullKey}', '${dom.domainName}')" title="Deployment Guide">
                                                <i class="bi bi-rocket-takeoff"></i> Deploy Agent
                                            </button>
                                            <button type="button" class="btn btn-outline-danger btn-sm px-2.5 py-1" onclick="deleteDomain(${dom.id}, '${dom.domainName}')" title="Revoke &amp; Delete">
                                                <i class="bi bi-trash3"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary"></i>
                                        No registered domains found. Click <strong>"Add New Domain"</strong> to generate your first API key.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Audit Trail Table -->
        <div class="saas-card">
            <div class="p-3.5 px-4 border-bottom border-secondary border-opacity-20 d-flex align-items-center justify-content-between">
                <div>
                    <h5 class="fw-bold mb-0"><i class="bi bi-journal-text text-primary me-2"></i> Tenant Security &amp; Activity Log</h5>
                    <span class="text-muted small">Real-time security and domain activity events</span>
                </div>
                <a href="${pageContext.request.contextPath}/audit" class="btn btn-sm btn-saas-outline">
                    View Full Trail <i class="bi bi-arrow-right ms-1"></i>
                </a>
            </div>
            <div class="table-responsive">
                <table class="table table-saas">
                    <thead>
                        <tr>
                            <th>Action</th>
                            <th>Details</th>
                            <th>Timestamp</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty auditLogs}">
                                <c:forEach var="log" items="${auditLogs}">
                                    <tr>
                                        <td>
                                            <span class="badge bg-secondary bg-opacity-25 border border-secondary border-opacity-40 text-main">
                                                <c:out value="${log.action}" />
                                            </span>
                                        </td>
                                        <td class="small"><c:out value="${log.details}" /></td>
                                        <td class="text-muted small">
                                            <fmt:formatDate value="${log.createdAt}" pattern="MMM dd, yyyy HH:mm:ss" />
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="3" class="text-center py-4 text-muted small">No audit activity recorded yet.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <!-- Modal: Add New Domain -->
    <div class="modal fade" id="addDomainModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content modal-content-saas">
                <div class="modal-header modal-header-saas">
                    <h5 class="modal-title fw-bold"><i class="bi bi-plus-circle text-primary me-2"></i> Register New Domain</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="addDomainForm" class="needs-validation" novalidate>
                    <div class="modal-body p-4">
                        <p class="text-muted small mb-3">Registering a domain auto-generates a secure UUID API Key for sending logs to AutoHeal platform.</p>
                        <div class="mb-3">
                            <label class="form-label-custom" for="domainNameInput">Domain Name <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-globe"></i></span>
                                <input type="text" class="form-control form-control-saas" id="domainNameInput" name="domainName" placeholder="api.service.internal" required>
                                <div class="invalid-feedback">Please enter a valid domain name.</div>
                            </div>
                            <span class="text-muted small d-block mt-1">Example: <code>api.payment-service.internal</code></span>
                        </div>
                        
                        <hr class="border-secondary border-opacity-30 my-4">
                        
                        <h6 class="fw-bold mb-3"><i class="bi bi-github text-primary me-2"></i> GitHub Integration (Auto-PR Remediation)</h6>
                        <div class="mb-3">
                            <label class="form-label-custom" for="githubRepoInput">Repository (Optional)</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-journal-code"></i></span>
                                <input type="text" class="form-control form-control-saas" id="githubRepoInput" name="githubRepo" placeholder="owner/repo">
                            </div>
                            <span class="text-muted small d-block mt-1">Format: <code>organization/repository</code></span>
                        </div>
                        <div class="mb-3">
                            <label class="form-label-custom" for="githubTokenInput">Personal Access Token (PAT) (Optional)</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-key-fill"></i></span>
                                <input type="password" class="form-control form-control-saas" id="githubTokenInput" name="githubToken" placeholder="ghp_xxxxxxxxxxxx">
                            </div>
                            <span class="text-muted small d-block mt-1">Requires <code>repo</code> scope for automated pull requests.</span>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-saas">
                        <button type="button" class="btn btn-saas-outline" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-saas-primary">
                            <i class="bi bi-plus-circle me-1"></i> Register Domain
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Toast Notifications Container -->
    <div id="toastContainer"></div>

    <!-- Modal: Comprehensive Multi-Platform Deployment Guide -->
    <div class="modal fade" id="deploymentModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content modal-content-saas">
                <div class="modal-header modal-header-saas">
                    <div class="d-flex align-items-center gap-3">
                        <div class="brand-icon-wrapper" style="width: 42px; height: 42px;">
                            <i class="bi bi-rocket-takeoff-fill fs-5"></i>
                        </div>
                        <div>
                            <h5 class="modal-title fw-bold mb-0">Agent Deployment &amp; Cloud Integration Guide</h5>
                            <span class="text-muted small">Step-by-step setup for Render, AWS, Hostinger, Vercel, Docker &amp; Linux servers</span>
                        </div>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body p-4">
                    <!-- Key Vault Banner -->
                    <div class="p-3.5 rounded-3 mb-4" style="background: rgba(99, 102, 241, 0.08); border: 1px solid rgba(99, 102, 241, 0.25);">
                        <div class="row align-items-center g-3">
                            <div class="col-md-7">
                                <span class="badge" style="background: rgba(99, 102, 241, 0.2); color: #a5b4fc; font-weight: 600;">Target Domain</span>
                                <h6 class="fw-bold text-main mt-1 mb-1" id="modalTargetDomain">Select a domain</h6>
                                <p class="text-muted small mb-0">Every log sent with this API Key will be routed to your organization and auto-healed according to your rules.</p>
                            </div>
                            <div class="col-md-5">
                                <label class="form-label-custom mb-1"><i class="bi bi-key-fill text-warning me-1"></i> Domain API Key (Inject into Server)</label>
                                <div class="d-flex gap-2">
                                    <input type="text" class="form-control form-control-saas font-monospace small" id="modalActiveApiKey" readonly>
                                    <button class="btn btn-saas-primary btn-sm px-3" onclick="copySnippet('modalActiveApiKey', true)" title="Copy Key">
                                        <i class="bi bi-clipboard"></i> Copy
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Step 1: Download Jar -->
                    <div class="d-flex flex-wrap align-items-center justify-content-between p-3 rounded-3 mb-4" style="background: rgba(16, 185, 129, 0.08); border: 1px solid rgba(16, 185, 129, 0.25);">
                        <div class="mb-2 mb-md-0">
                            <h6 class="fw-bold text-success mb-1"><i class="bi bi-download me-2"></i> Step 1: Get the Standalone Agent JAR</h6>
                            <span class="text-muted small">Requires Java 17+. Lightweight, zero-config tailing daemon that detects errors and runs remediation commands.</span>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <a href="${pageContext.request.contextPath}/download/agent" class="btn btn-success btn-sm px-3 py-1.5 fw-semibold">
                                <i class="bi bi-cloud-arrow-down-fill me-1"></i> Download log-agent.jar
                            </a>
                        </div>
                    </div>

                    <!-- Step 2: Choose Platform Tabs -->
                    <h6 class="fw-bold mb-3"><i class="bi bi-hdd-stack text-primary me-2"></i> Step 2: Deploy on Your Cloud Platform</h6>
                    <ul class="nav nav-pills mb-3 gap-2" id="deployTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active fw-semibold" id="render-tab" data-bs-toggle="pill" data-bs-target="#tab-render" type="button" role="tab">
                                <i class="bi bi-cloud-arrow-up me-1 text-primary"></i> Render
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-semibold" id="aws-tab" data-bs-toggle="pill" data-bs-target="#tab-aws" type="button" role="tab">
                                <i class="bi bi-boxes me-1 text-warning"></i> AWS (EC2 / Beanstalk)
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-semibold" id="hostinger-tab" data-bs-toggle="pill" data-bs-target="#tab-hostinger" type="button" role="tab">
                                <i class="bi bi-hdd-network me-1 text-info"></i> Hostinger (VPS)
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-semibold" id="vercel-tab" data-bs-toggle="pill" data-bs-target="#tab-vercel" type="button" role="tab">
                                <i class="bi bi-triangle-fill me-1 text-white"></i> Vercel (Next.js)
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-semibold" id="docker-tab" data-bs-toggle="pill" data-bs-target="#tab-docker" type="button" role="tab">
                                <i class="bi bi-box-seam me-1 text-info"></i> Docker
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-semibold" id="linux-tab" data-bs-toggle="pill" data-bs-target="#tab-linux" type="button" role="tab">
                                <i class="bi bi-terminal me-1 text-success"></i> Linux / VM (CLI)
                            </button>
                        </li>
                    </ul>

                    <div class="tab-content saas-card p-4" id="deployTabsContent">
                        <!-- ==================== RENDER TAB ==================== -->
                        <div class="tab-pane fade show active" id="tab-render" role="tabpanel">
                            <div class="d-flex align-items-center gap-2 mb-3">
                                <span class="badge" style="background: rgba(99, 102, 241, 0.2); color: #a5b4fc;">Platform: Render.com Web Service / Worker</span>
                            </div>

                            <div class="alert alert-info bg-info bg-opacity-10 border-info border-opacity-25 text-main small p-3 mb-3">
                                <strong><i class="bi bi-info-circle-fill me-1"></i> Where to add the API Key on Render:</strong><br>
                                Open your <strong>Render Dashboard</strong> &rarr; Select your Web Service &rarr; Click <strong>Environment</strong> in the left sidebar &rarr; Click <strong>Add Environment Variable</strong>:<br>
                                <span class="font-monospace text-warning">AUTOHEAL_API_KEY</span> = <span class="font-monospace text-success modal-key-placeholder">YOUR_API_KEY</span>
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Option A: Node.js / Python / Go App (Running via Start Command)</h6>
                            <p class="text-muted small mb-2">1. In your Render <strong>Build Command</strong>, add the download command:</p>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code id="renderBuildCmd">npm install && curl -sLO <HOST_URL>/download/agent -o log-agent.jar</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copySnippet('renderBuildCmd')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>

                            <p class="text-muted small mb-2">2. In your Render <strong>Start Command</strong>, start the agent alongside your app (pipe output to <code>app.log</code>):</p>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code id="renderStartCmd">java -jar log-agent.jar --api-key="$AUTOHEAL_API_KEY" --log-file="app.log" --server-url="<SERVER_URL>" & npm start</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copySnippet('renderStartCmd')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>

                            <div class="p-2.5 rounded-2 bg-secondary bg-opacity-10 border border-secondary border-opacity-20 text-muted small">
                                <i class="bi bi-check-circle-fill text-success me-1"></i> <strong>Automatic Recovery on Render:</strong> When an unhandled error writes to <code>app.log</code>, the agent intercepts it, notifies AutoHeal, and executes the configured restart command.
                            </div>
                        </div>

                        <!-- ==================== AWS TAB ==================== -->
                        <div class="tab-pane fade" id="tab-aws" role="tabpanel">
                            <div class="d-flex align-items-center gap-2 mb-3">
                                <span class="badge" style="background: rgba(245, 158, 11, 0.2); color: #fbbf24;">Platform: AWS EC2 / Elastic Beanstalk / Linux VM</span>
                            </div>

                            <div class="alert alert-info bg-info bg-opacity-10 border-info border-opacity-25 text-main small p-3 mb-3">
                                <strong><i class="bi bi-info-circle-fill me-1"></i> Where to add the API Key on AWS:</strong><br>
                                - <strong>EC2:</strong> Pass via CLI flag <code>--api-key="KEY"</code> or add to <code>/etc/environment</code>.<br>
                                - <strong>Elastic Beanstalk:</strong> Add in <strong>Configuration</strong> &rarr; <strong>Software</strong> &rarr; <strong>Environment properties</strong>: <code>AUTOHEAL_API_KEY</code>.
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Step 1: Install Java 17 on EC2 (if needed)</h6>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code>sudo apt update && sudo apt install -y openjdk-17-jre-headless</code></pre>
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Step 2: Download the Agent to your app directory</h6>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code id="awsDownloadCmd">sudo mkdir -p /opt/autoheal && cd /opt/autoheal
sudo curl -sLO <HOST_URL>/download/agent -o log-agent.jar</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copySnippet('awsDownloadCmd')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Step 3: Run as a Persistent Systemd Service (Auto-starts on server reboot)</h6>
                            <p class="text-muted small mb-2">Create service file at <code>/etc/systemd/system/autoheal-agent.service</code>:</p>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code id="awsSystemdCode">[Unit]
Description=AutoHeal Autonomous Log Agent
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/autoheal
ExecStart=/usr/bin/java -jar /opt/autoheal/log-agent.jar --api-key="<API_KEY>" --log-file="/var/log/app.log" --server-url="<SERVER_URL>"
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copySnippet('awsSystemdCode')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>

                            <p class="text-muted small mb-2">Enable and start the service:</p>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code>sudo systemctl daemon-reload && sudo systemctl enable --now autoheal-agent</code></pre>
                            </div>
                        </div>

                        <!-- ==================== HOSTINGER TAB ==================== -->
                        <div class="tab-pane fade" id="tab-hostinger" role="tabpanel">
                            <div class="d-flex align-items-center gap-2 mb-3">
                                <span class="badge" style="background: rgba(6, 182, 212, 0.2); color: #38bdf8;">Platform: Hostinger VPS &amp; Cloud Hosting</span>
                            </div>

                            <div class="alert alert-info bg-info bg-opacity-10 border-info border-opacity-25 text-main small p-3 mb-3">
                                <strong><i class="bi bi-info-circle-fill me-1"></i> Where to add the API Key on Hostinger:</strong><br>
                                Connect to your Hostinger VPS via SSH or Hostinger Web Console. Pass the API key directly in the startup command or inside your PM2 process configuration.
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Step 1: SSH into Hostinger VPS</h6>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code>ssh root@YOUR_HOSTINGER_VPS_IP</code></pre>
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Step 2: Download Agent into Your App Directory</h6>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code id="hostingerDownloadCmd">cd /var/www/your-app && curl -sLO <HOST_URL>/download/agent -o log-agent.jar</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copySnippet('hostingerDownloadCmd')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Step 3: Run via PM2 (Standard on Hostinger Node/Web Apps)</h6>
                            <p class="text-muted small mb-2">PM2 keeps the agent running in the background and restarts it automatically if the server restarts:</p>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code id="hostingerPm2Cmd">pm2 start "java -jar log-agent.jar --api-key='<API_KEY>' --log-file='app.log' --server-url='<SERVER_URL>'" --name "autoheal-agent"
pm2 save
pm2 startup</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copySnippet('hostingerPm2Cmd')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>
                        </div>

                        <!-- ==================== VERCEL TAB ==================== -->
                        <div class="tab-pane fade" id="tab-vercel" role="tabpanel">
                            <div class="d-flex align-items-center gap-2 mb-3">
                                <span class="badge" style="background: rgba(255, 255, 255, 0.2); color: #ffffff;">Platform: Vercel (Next.js / Node.js Serverless)</span>
                            </div>

                            <div class="alert alert-info bg-info bg-opacity-10 border-info border-opacity-25 text-main small p-3 mb-3">
                                <strong><i class="bi bi-info-circle-fill me-1"></i> Where to add the API Key on Vercel:</strong><br>
                                Open your <strong>Vercel Dashboard</strong> &rarr; Select Project &rarr; <strong>Settings</strong> &rarr; <strong>Environment Variables</strong> &rarr; Add:<br>
                                <span class="font-monospace text-warning">AUTOHEAL_API_KEY</span> = <span class="font-monospace text-success modal-key-placeholder">YOUR_API_KEY</span>
                            </div>

                            <div class="alert alert-warning bg-warning bg-opacity-10 border-warning border-opacity-25 text-main small p-3 mb-3">
                                <i class="bi bi-lightning-charge-fill text-warning me-1"></i> <strong>Note for Serverless Lambdas:</strong><br>
                                Vercel functions are ephemeral and run in micro-lambdas (no persistent background JVM). You send error logs directly to the AutoHeal Ingestion API via HTTP fetch inside your error handler or Next.js instrumentation!
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Next.js / Express Error Middleware Integration</h6>
                            <p class="text-muted small mb-2">Add this helper to your Next.js API handler, Express <code>app.use(errorHandler)</code>, or <code>instrumentation.ts</code>:</p>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code id="vercelCodeSnippet">// lib/autoheal.js
export async function sendErrorToAutoHeal(error, req = null) {
  try {
    await fetch('<SERVER_URL>', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': process.env.AUTOHEAL_API_KEY || '<API_KEY>'
      },
      body: JSON.stringify({
        logLevel: 'ERROR',
        message: error.message || String(error),
        stackTrace: error.stack || null,
        timestamp: Date.now()
      })
    });
  } catch (err) {
    console.error('Failed to notify AutoHeal:', err);
  }
}</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copySnippet('vercelCodeSnippet')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>
                        </div>

                        <!-- ==================== DOCKER TAB ==================== -->
                        <div class="tab-pane fade" id="tab-docker" role="tabpanel">
                            <div class="d-flex align-items-center gap-2 mb-3">
                                <span class="badge" style="background: rgba(14, 165, 233, 0.2); color: #38bdf8;">Platform: Docker &amp; Docker Compose</span>
                            </div>

                            <div class="alert alert-info bg-info bg-opacity-10 border-info border-opacity-25 text-main small p-3 mb-3">
                                <strong><i class="bi bi-info-circle-fill me-1"></i> Where to add the API Key in Docker:</strong><br>
                                In your <code>.env</code> file or passed as environment variable <code>-e AUTOHEAL_API_KEY="KEY"</code>.
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Option A: Run Agent Container Sharing a Log Volume</h6>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code id="dockerRunCmd">docker run -d --name autoheal-agent \
  --restart unless-stopped \
  -v /var/log/app:/app/logs \
  -e AUTOHEAL_API_KEY="<API_KEY>" \
  openjdk:17-slim \
  sh -c "curl -sLO <HOST_URL>/download/agent -o /log-agent.jar && java -jar /log-agent.jar --api-key=\"$AUTOHEAL_API_KEY\" --log-file=\"/app/logs/app.log\" --server-url=\"<SERVER_URL>\""</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copySnippet('dockerRunCmd')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Option B: In your existing Dockerfile Entrypoint</h6>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code id="dockerfileCmd"># Download agent in Dockerfile:
RUN curl -sLO <HOST_URL>/download/agent -o /app/log-agent.jar

# Run agent in background before starting your main application:
CMD java -jar /app/log-agent.jar --api-key="$AUTOHEAL_API_KEY" --log-file="/app/logs/app.log" --server-url="<SERVER_URL>" & npm start</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copySnippet('dockerfileCmd')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>
                        </div>

                        <!-- ==================== LINUX / CLI TAB ==================== -->
                        <div class="tab-pane fade" id="tab-linux" role="tabpanel">
                            <div class="d-flex align-items-center gap-2 mb-3">
                                <span class="badge" style="background: rgba(16, 185, 129, 0.2); color: #34d399;">Platform: Linux / Terminal / VM Direct CLI</span>
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Quick One-Liner (Foreground with console logging)</h6>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code id="linuxForegroundCmd">java -jar log-agent.jar --api-key="<API_KEY>" --log-file="/path/to/app.log" --server-url="<SERVER_URL>"</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copySnippet('linuxForegroundCmd')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Background Execution with Nohup</h6>
                            <div class="position-relative mb-3">
                                <pre class="p-3 rounded-3 font-monospace small bg-dark text-info overflow-auto"><code id="linuxNohupCmd">nohup java -jar log-agent.jar --api-key="<API_KEY>" --log-file="/path/to/app.log" --server-url="<SERVER_URL>" > autoheal-agent.out 2>&1 &</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copySnippet('linuxNohupCmd')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>

                            <h6 class="fw-bold small text-uppercase text-muted mt-3 mb-2">Parameters Reference</h6>
                            <div class="table-responsive">
                                <table class="table table-sm table-saas small mb-0">
                                    <thead>
                                        <tr>
                                            <th>Flag</th>
                                            <th>Required</th>
                                            <th>Description</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td><code>--api-key="&lt;KEY&gt;"</code></td>
                                            <td><span class="badge bg-danger">Yes</span></td>
                                            <td>Domain API Key generated in AutoHeal dashboard.</td>
                                        </tr>
                                        <tr>
                                            <td><code>--log-file="&lt;PATH&gt;"</code></td>
                                            <td><span class="badge bg-danger">Yes</span></td>
                                            <td>Absolute or relative path to the log file your application writes to.</td>
                                        </tr>
                                        <tr>
                                            <td><code>--server-url="&lt;URL&gt;"</code></td>
                                            <td><span class="badge bg-secondary">Optional</span></td>
                                            <td>AutoHeal endpoint (Default: <code>/api/v1/logs/ingest</code>).</td>
                                        </tr>
                                        <tr>
                                            <td><code>--poll-interval=&lt;MS&gt;</code></td>
                                            <td><span class="badge bg-secondary">Optional</span></td>
                                            <td>File tail check interval in milliseconds (Default: 1000ms).</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer modal-footer-saas">
                    <button type="button" class="btn btn-saas-outline" data-bs-dismiss="modal">Close</button>
                    <a href="${pageContext.request.contextPath}/logs" class="btn btn-saas-primary">
                        <i class="bi bi-terminal me-1"></i> Open Live Logs Console
                    </a>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function copySnippet(elementId, isInput = false) {
            const el = document.getElementById(elementId);
            if (!el) return;
            const text = isInput ? el.value : (el.innerText || el.textContent);
            if (navigator.clipboard && window.isSecureContext) {
                navigator.clipboard.writeText(text).then(() => {
                    showToast('Copied to clipboard!', 'success');
                }).catch(() => {
                    fallbackCopy(text);
                });
            } else {
                fallbackCopy(text);
            }
        }

        function fallbackCopy(text) {
            const textArea = document.createElement("textarea");
            textArea.value = text;
            textArea.style.position = "fixed";
            textArea.style.left = "-999999px";
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            try {
                document.execCommand('copy');
                showToast('Copied to clipboard!', 'success');
            } catch (err) {
                showToast('Unable to copy', 'danger');
            }
            document.body.removeChild(textArea);
        }

        function showDeploymentModal(apiKey, domainName) {
            const hostUrl = window.location.origin + '${pageContext.request.contextPath}';
            const ingestUrl = hostUrl + '/api/v1/logs/ingest';
            const effectiveKey = (apiKey && apiKey.trim().length > 0) ? apiKey : 'YOUR_API_KEY';
            const effectiveDomain = (domainName && domainName.trim().length > 0) ? domainName : 'General Configuration';

            // Update Domain badge & input
            const domainEl = document.getElementById('modalTargetDomain');
            if (domainEl) domainEl.innerText = effectiveDomain;

            const keyInput = document.getElementById('modalActiveApiKey');
            if (keyInput) keyInput.value = effectiveKey;

            document.querySelectorAll('.modal-key-placeholder').forEach(el => {
                el.innerText = effectiveKey;
            });

            // Update Render commands
            const renderBuild = document.getElementById('renderBuildCmd');
            if (renderBuild) renderBuild.innerText = `npm install && curl -sLO ` + hostUrl + `/download/agent -o log-agent.jar`;

            const renderStart = document.getElementById('renderStartCmd');
            if (renderStart) renderStart.innerText = `java -jar log-agent.jar --api-key="$AUTOHEAL_API_KEY" --log-file="app.log" --server-url="` + ingestUrl + `" & npm start`;

            // Update AWS commands
            const awsDl = document.getElementById('awsDownloadCmd');
            if (awsDl) awsDl.innerText = `sudo mkdir -p /opt/autoheal && cd /opt/autoheal\nsudo curl -sLO ` + hostUrl + `/download/agent -o log-agent.jar`;

            const awsSystemd = document.getElementById('awsSystemdCode');
            if (awsSystemd) {
                awsSystemd.innerText = `[Unit]\nDescription=AutoHeal Autonomous Log Agent\nAfter=network.target\n\n[Service]\nType=simple\nUser=root\nWorkingDirectory=/opt/autoheal\nExecStart=/usr/bin/java -jar /opt/autoheal/log-agent.jar --api-key="` + effectiveKey + `" --log-file="/var/log/app.log" --server-url="` + ingestUrl + `"\nRestart=always\nRestartSec=10\n\n[Install]\nWantedBy=multi-user.target`;
            }

            // Update Hostinger commands
            const hostingerDl = document.getElementById('hostingerDownloadCmd');
            if (hostingerDl) hostingerDl.innerText = `cd /var/www/your-app && curl -sLO ` + hostUrl + `/download/agent -o log-agent.jar`;

            const hostingerPm2 = document.getElementById('hostingerPm2Cmd');
            if (hostingerPm2) hostingerPm2.innerText = `pm2 start "java -jar log-agent.jar --api-key='` + effectiveKey + `' --log-file='app.log' --server-url='` + ingestUrl + `'" --name "autoheal-agent"\npm2 save\npm2 startup`;

            // Update Vercel code snippet
            const vercelSnippet = document.getElementById('vercelCodeSnippet');
            if (vercelSnippet) {
                vercelSnippet.innerText = `// lib/autoheal.js\nexport async function sendErrorToAutoHeal(error, req = null) {\n  try {\n    await fetch('` + ingestUrl + `', {\n      method: 'POST',\n      headers: {\n        'Content-Type': 'application/json',\n        'X-API-KEY': process.env.AUTOHEAL_API_KEY || '` + effectiveKey + `'\n      },\n      body: JSON.stringify({\n        logLevel: 'ERROR',\n        message: error.message || String(error),\n        stackTrace: error.stack || null,\n        timestamp: Date.now()\n      })\n    });\n  } catch (err) {\n    console.error('Failed to notify AutoHeal:', err);\n  }\n}`;
            }

            // Update Docker commands
            const dockerRun = document.getElementById('dockerRunCmd');
            if (dockerRun) {
                dockerRun.innerText = `docker run -d --name autoheal-agent \\\n  --restart unless-stopped \\\n  -v /var/log/app:/app/logs \\\n  -e AUTOHEAL_API_KEY="` + effectiveKey + `" \\\n  openjdk:17-slim \\\n  sh -c "curl -sLO ` + hostUrl + `/download/agent -o /log-agent.jar && java -jar /log-agent.jar --api-key=\\"$AUTOHEAL_API_KEY\\" --log-file=\\"/app/logs/app.log\\" --server-url=\\"` + ingestUrl + `\\""`;
            }

            const dockerfile = document.getElementById('dockerfileCmd');
            if (dockerfile) {
                dockerfile.innerText = `# Download agent in Dockerfile:\nRUN curl -sLO ` + hostUrl + `/download/agent -o /app/log-agent.jar\n\n# Run agent in background before starting your main application:\nCMD java -jar /app/log-agent.jar --api-key="$AUTOHEAL_API_KEY" --log-file="/app/logs/app.log" --server-url="` + ingestUrl + `" & npm start`;
            }

            // Update Linux commands
            const linuxFg = document.getElementById('linuxForegroundCmd');
            if (linuxFg) linuxFg.innerText = `java -jar log-agent.jar --api-key="` + effectiveKey + `" --log-file="/path/to/app.log" --server-url="` + ingestUrl + `"`;

            const linuxNohup = document.getElementById('linuxNohupCmd');
            if (linuxNohup) linuxNohup.innerText = `nohup java -jar log-agent.jar --api-key="` + effectiveKey + `" --log-file="/path/to/app.log" --server-url="` + ingestUrl + `" > autoheal-agent.out 2>&1 &`;

            const modal = new bootstrap.Modal(document.getElementById('deploymentModal'));
            modal.show();
        }
    </script>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>