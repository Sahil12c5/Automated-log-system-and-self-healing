<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Guardrails | AutoHeal Engine</title>
    <!-- Custom Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
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
                    <a href="${pageContext.request.contextPath}/dashboard" class="nav-link-saas">
                        <i class="bi bi-speedometer2"></i> Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/logs" class="nav-link-saas">
                        <i class="bi bi-terminal-fill"></i> Live Logs
                    </a>
                    <a href="${pageContext.request.contextPath}/rules" class="nav-link-saas">
                        <i class="bi bi-magic"></i> Healing Rules
                    </a>
                    
                    <!-- AI & Approvals -->
                    <div class="dropdown">
                        <button class="nav-link-saas dropdown-toggle border-0 bg-transparent" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-robot"></i> AI Engine
                        </button>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/diagnostics"><i class="bi bi-search text-primary"></i> Diagnostics</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/approvals"><i class="bi bi-check2-square text-warning"></i> Approvals Queue</a></li>
                        </ul>
                    </div>

                    <!-- Administration -->
                    <div class="dropdown">
                        <button class="nav-link-saas active dropdown-toggle border-0 bg-transparent" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-shield-lock"></i> Admin
                        </button>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/team"><i class="bi bi-people text-info"></i> Team Management</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/audit"><i class="bi bi-clock-history text-secondary"></i> Audit Trail</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item active" href="${pageContext.request.contextPath}/guardrails"><i class="bi bi-shield-lock text-danger"></i> Guardrails</a></li>
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
        <div class="d-flex justify-content-between flex-wrap align-items-center pb-3 mb-4 border-bottom border-secondary border-opacity-20 gap-3">
            <div>
                <h2 class="fw-bold mb-1"><i class="bi bi-shield-lock text-danger me-2"></i> Security Guardrails &amp; Rate Limiting</h2>
                <p class="text-muted small mb-0">Protect host environments from destructive commands and infinite recovery reboot loops</p>
            </div>
            <div class="d-flex align-items-center gap-2">
                <span class="badge" style="background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.35);">
                    <i class="bi bi-slash-circle me-1"></i> CommandSanitizer Shield Active
                </span>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <!-- Reboot Loop Prevention Card -->
            <div class="col-lg-6">
                <div class="saas-card h-100 p-4" style="border-top: 4px solid #f59e0b;">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="stat-card-icon" style="background: rgba(245, 158, 11, 0.15); color: #fbbf24;">
                            <i class="bi bi-arrow-repeat"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-0">Reboot Loop Prevention</h5>
                            <span class="text-muted small">Automatic lockout threshold for flapping services</span>
                        </div>
                    </div>

                    <p class="text-muted small mb-4">
                        If a microservice triggers repeated recoveries beyond this limit within a 15-minute rolling window, the AutoHeal platform locks out further automated commands and escalates an emergency incident.
                    </p>

                    <form id="limitForm">
                        <div class="mb-4">
                            <label class="form-label-custom d-flex justify-content-between">
                                <span>Max Executions per 15 Minutes</span>
                                <span class="fw-bold text-warning font-monospace fs-6" id="limitDisplay">${maxExecutions} runs</span>
                            </label>
                            <input type="range" class="form-range" id="limitRange" min="1" max="20" value="${maxExecutions}" oninput="document.getElementById('maxExecutions').value = this.value; document.getElementById('limitDisplay').innerText = this.value + ' runs';">
                            <div class="input-group mt-2">
                                <span class="input-group-text"><i class="bi bi-speedometer2"></i></span>
                                <input type="number" class="form-control form-control-saas" id="maxExecutions" value="${maxExecutions}" required min="1" max="100" oninput="document.getElementById('limitRange').value = this.value; document.getElementById('limitDisplay').innerText = this.value + ' runs';">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-saas-primary w-100">
                            <i class="bi bi-save me-1"></i> Save Execution Threshold
                        </button>
                    </form>
                </div>
            </div>

            <!-- Command Sanitizer Blacklist Card -->
            <div class="col-lg-6">
                <div class="saas-card h-100 p-4" style="border-top: 4px solid #ef4444;">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="stat-card-icon" style="background: rgba(239, 68, 68, 0.15); color: #f87171;">
                            <i class="bi bi-slash-circle"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-0">Command Sanitizer Blacklist</h5>
                            <span class="text-muted small">Strictly forbidden subcommands and destructive tokens</span>
                        </div>
                    </div>

                    <p class="text-muted small mb-3">
                        Recovery scripts or AI suggestions containing any blacklisted tokens below will be immediately aborted with a security violation alert.
                    </p>

                    <div class="d-flex flex-wrap gap-2 mb-4 p-3 rounded" style="background: rgba(255, 255, 255, 0.03); border: 1px solid var(--border-color); min-height: 80px;">
                        <c:forEach var="keyword" items="${blacklist}">
                            <span class="badge d-inline-flex align-items-center gap-2 p-2 px-3 font-monospace" style="background: rgba(239, 68, 68, 0.18); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.35); font-size: 0.85rem;">
                                ${keyword}
                                <i class="bi bi-x-circle-fill text-danger" style="cursor:pointer;" onclick="removeKeyword('${keyword}')" title="Remove '${keyword}'"></i>
                            </span>
                        </c:forEach>
                    </div>

                    <form id="keywordForm" class="d-flex gap-2">
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-shield-x"></i></span>
                            <input type="text" class="form-control form-control-saas font-monospace" id="newKeyword" placeholder="e.g. format, drop, rm -rf" required>
                        </div>
                        <button type="submit" class="btn btn-saas-primary text-nowrap">
                            <i class="bi bi-plus-circle me-1"></i> Add Token
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Toast Notifications Container -->
    <div id="toastContainer"></div>

    <script>
        document.getElementById('limitForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const maxEx = document.getElementById('maxExecutions').value;
            fetch('${pageContext.request.contextPath}/api/v1/guardrails/settings', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=UPDATE_LIMITS&maxExecutions=' + maxEx
            })
            .then(res => res.json())
            .then(data => {
                showToast(data.message || 'Execution limits updated successfully', 'success');
                setTimeout(() => location.reload(), 1000);
            })
            .catch(err => {
                showToast("Error updating limit: " + err, 'danger');
            });
        });

        document.getElementById('keywordForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const kw = document.getElementById('newKeyword').value.trim();
            if (!kw) return;

            fetch('${pageContext.request.contextPath}/api/v1/guardrails/settings', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=ADD_KEYWORD&keyword=' + encodeURIComponent(kw)
            })
            .then(res => res.json())
            .then(data => {
                showToast(`Added token '` + kw + `' to blacklist`, 'success');
                setTimeout(() => location.reload(), 1000);
            })
            .catch(err => {
                showToast("Error adding keyword: " + err, 'danger');
            });
        });

        function removeKeyword(kw) {
            if(confirm("Remove '" + kw + "' from security blacklist?")) {
                fetch('${pageContext.request.contextPath}/api/v1/guardrails/settings', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'action=REMOVE_KEYWORD&keyword=' + encodeURIComponent(kw)
                })
                .then(res => res.json())
                .then(data => {
                    showToast(`Removed token '` + kw + `'`, 'info');
                    setTimeout(() => location.reload(), 1000);
                })
                .catch(err => {
                    showToast("Error removing keyword: " + err, 'danger');
                });
            }
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>