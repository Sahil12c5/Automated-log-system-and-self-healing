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

    <!-- Modal: Quick Deployment Guide -->
    <div class="modal fade" id="deploymentModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content modal-content-saas">
                <div class="modal-header modal-header-saas">
                    <h5 class="modal-title fw-bold">
                        <i class="bi bi-rocket-takeoff text-primary me-2"></i> Quick Deployment Guide
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="d-flex align-items-center justify-content-between p-3 rounded-3 mb-4" style="background: rgba(99, 102, 241, 0.08); border: 1px solid rgba(99, 102, 241, 0.2);">
                        <div>
                            <h6 class="fw-bold mb-1">1. Download the Log Agent</h6>
                            <span class="text-muted small">Get the standalone executable JAR file. Requires Java 17+.</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/download/agent" class="btn btn-saas-primary">
                            <i class="bi bi-download me-1"></i> Download log-agent.jar
                        </a>
                    </div>
                    
                    <h6 class="fw-bold mb-3">2. Start the Agent</h6>
                    <p class="text-muted small mb-3">Run the agent alongside your application. Choose your hosting environment below.</p>
                    
                    <!-- Tabs for environments -->
                    <ul class="nav nav-tabs mb-3 border-secondary border-opacity-30" id="deployTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active fw-semibold text-main" id="linux-tab" data-bs-toggle="tab" data-bs-target="#linux-deploy" type="button" role="tab">Linux / VM</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-semibold text-main" id="render-tab" data-bs-toggle="tab" data-bs-target="#render-deploy" type="button" role="tab">Render / PaaS</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-semibold text-main" id="docker-tab" data-bs-toggle="tab" data-bs-target="#docker-deploy" type="button" role="tab">Docker</button>
                        </li>
                    </ul>
                    
                    <div class="tab-content" id="deployTabsContent">
                        <!-- Linux / VM Tab -->
                        <div class="tab-pane fade show active" id="linux-deploy" role="tabpanel">
                            <div class="position-relative">
                                <pre class="bg-dark text-info p-3 rounded-3 small overflow-auto font-monospace"><code id="linuxCommand">nohup java -jar log-agent.jar --api-key="YOUR_API_KEY" --log-file="/var/log/app.log" --server-url="http://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/api/v1/logs/ingest" > /dev/null 2>&1 &</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copyToClipboard('linuxCommand')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>
                        </div>
                        <!-- Render / PaaS Tab -->
                        <div class="tab-pane fade" id="render-deploy" role="tabpanel">
                            <div class="position-relative">
                                <pre class="bg-dark text-info p-3 rounded-3 small overflow-auto font-monospace"><code id="renderCommand">java -jar log-agent.jar --api-key="YOUR_API_KEY" --log-file="app.log" --server-url="http://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/api/v1/logs/ingest" & <YOUR_ORIGINAL_START_COMMAND></code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copyToClipboard('renderCommand')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>
                        </div>
                        <!-- Docker Tab -->
                        <div class="tab-pane fade" id="docker-deploy" role="tabpanel">
                            <div class="position-relative">
                                <pre class="bg-dark text-info p-3 rounded-3 small overflow-auto font-monospace"><code id="dockerCommand">CMD java -jar log-agent.jar --api-key=$API_KEY --log-file=/app/app.log --server-url=http://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/api/v1/logs/ingest & java -jar main-app.jar</code></pre>
                                <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copyToClipboard('dockerCommand')"><i class="bi bi-clipboard"></i> Copy</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function showDeploymentModal(apiKey, domainName) {
            const hostUrl = window.location.origin + '${pageContext.request.contextPath}';
            const linuxCode = document.getElementById('linuxCommand');
            const renderCode = document.getElementById('renderCommand');
            const dockerCode = document.getElementById('dockerCommand');
            
            if (linuxCode) linuxCode.innerText = `nohup java -jar log-agent.jar --api-key="` + apiKey + `" --log-file="/var/log/app.log" --server-url="` + hostUrl + `/api/v1/logs/ingest" > /dev/null 2>&1 &`;
            if (renderCode) renderCode.innerText = `java -jar log-agent.jar --api-key="` + apiKey + `" --log-file="app.log" --server-url="` + hostUrl + `/api/v1/logs/ingest" & <YOUR_ORIGINAL_START_COMMAND>`;
            if (dockerCode) dockerCode.innerText = `CMD java -jar log-agent.jar --api-key="` + apiKey + `" --log-file=/app/app.log --server-url=` + hostUrl + `/api/v1/logs/ingest & java -jar main-app.jar`;
            
            const modal = new bootstrap.Modal(document.getElementById('deploymentModal'));
            modal.show();
        }
    </script>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>