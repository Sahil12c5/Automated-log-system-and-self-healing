<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fix Approval Queue | AutoHeal Engine</title>
    <!-- Custom Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
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
                        <button class="nav-link-saas active dropdown-toggle border-0 bg-transparent" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-robot"></i> AI Engine
                        </button>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/diagnostics"><i class="bi bi-search text-primary"></i> Diagnostics</a></li>
                            <li><a class="dropdown-item active" href="${pageContext.request.contextPath}/approvals"><i class="bi bi-check2-square text-warning"></i> Approvals Queue</a></li>
                        </ul>
                    </div>

                    <!-- Administration -->
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
        <div class="d-flex justify-content-between flex-wrap align-items-center pb-3 mb-4 border-bottom border-secondary border-opacity-20 gap-3">
            <div>
                <h2 class="fw-bold mb-1"><i class="bi bi-check2-square text-warning me-2"></i> Fix Approval Queue</h2>
                <p class="text-muted small mb-0">Human-in-the-loop governance: Review, authorize, or convert AI-generated remediations into permanent rules</p>
            </div>
            <div class="d-flex align-items-center gap-2">
                <span class="badge" style="background: rgba(245, 158, 11, 0.15); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.35);">
                    <i class="bi bi-shield-check me-1"></i> Developer Authorization Guardrail
                </span>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger mb-4"><i class="bi bi-exclamation-triangle me-2"></i> ${error}</div>
        </c:if>

        <div class="row">
            <c:forEach var="log" items="${logs}">
                <div class="col-12 mb-4">
                    <div class="saas-card" style="border-left: 4px solid #f59e0b;">
                        <div class="p-3 px-4 border-bottom border-secondary border-opacity-20 d-flex flex-wrap justify-content-between align-items-center gap-2" style="background: rgba(255, 255, 255, 0.02);">
                            <div class="d-flex align-items-center gap-2">
                                <span class="badge ${log.logLevel == 'ERROR' || log.logLevel == 'CRITICAL' ? 'bg-danger text-white' : 'bg-warning text-dark'} fw-bold">
                                    ${log.logLevel}
                                </span>
                                <span class="badge" style="background: rgba(6, 182, 212, 0.12); color: #38bdf8; border: 1px solid rgba(6, 182, 212, 0.3);">
                                    <i class="bi bi-globe me-1"></i> ${log.domainName}
                                </span>
                                <span class="text-muted small font-monospace">#LOG-${log.id}</span>
                            </div>
                            <div class="text-muted small">
                                <i class="bi bi-clock me-1"></i> ${log.timestamp}
                            </div>
                        </div>
                        
                        <div class="p-4">
                            <h6 class="form-label-custom mb-1 text-danger"><i class="bi bi-bug me-1"></i> Error Trigger</h6>
                            <div class="p-3 rounded mb-4 font-monospace small" style="background: var(--bg-terminal); border: 1px solid var(--border-color); color: #f87171;">
                                ${log.message}
                            </div>
                            
                            <div class="row g-4 mb-4">
                                <div class="col-md-6">
                                    <div class="p-3.5 rounded h-100" style="background: rgba(99, 102, 241, 0.08); border: 1px solid rgba(99, 102, 241, 0.25);">
                                        <h6 class="fw-bold text-primary mb-2"><i class="bi bi-search me-1"></i> Gemini AI Root Cause Analysis</h6>
                                        <div class="markdown-body" data-markdown="${log.aiRootCause}"></div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="p-3.5 rounded h-100" style="background: rgba(16, 185, 129, 0.08); border: 1px solid rgba(16, 185, 129, 0.25);">
                                        <h6 class="fw-bold text-success mb-2"><i class="bi bi-tools me-1"></i> Proposed Remediation Fix</h6>
                                        <div class="markdown-body" data-markdown="${log.aiRemediationSuggestion}"></div>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex flex-wrap gap-2 pt-3 border-top border-secondary border-opacity-20">
                                <button class="btn btn-saas-primary flex-grow-1" onclick="handleAction(${log.id}, 'APPROVE')">
                                    <i class="bi bi-play-fill me-1"></i> Approve &amp; Execute Now
                                </button>
                                <button class="btn btn-saas-outline flex-grow-1" onclick="handleAction(${log.id}, 'PERMANENT_RULE')">
                                    <i class="bi bi-shield-plus me-1 text-primary"></i> Save as Permanent Rule
                                </button>
                                <button class="btn btn-outline-danger flex-grow-1" onclick="handleAction(${log.id}, 'REJECT')">
                                    <i class="bi bi-x-circle me-1"></i> Dismiss / Reject
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <c:if test="${empty logs}">
                <div class="col-12">
                    <div class="saas-card p-5 text-center">
                        <i class="bi bi-check2-all fs-1 text-success d-block mb-3"></i>
                        <h4 class="fw-bold">Queue Empty!</h4>
                        <p class="text-muted">There are no pending AI diagnostic fixes awaiting authorization.</p>
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-saas-outline mt-2">
                            <i class="bi bi-speedometer2 me-1"></i> Return to Dashboard
                        </a>
                    </div>
                </div>
            </c:if>
        </div>
    </div>

    <!-- Toast Notifications Container -->
    <div id="toastContainer"></div>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            document.querySelectorAll('.markdown-body').forEach(el => {
                const rawMarkdown = el.getAttribute('data-markdown');
                if(rawMarkdown && rawMarkdown.trim() !== "") {
                    el.innerHTML = marked.parse(rawMarkdown);
                }
            });
        });

        function handleAction(logId, actionStr) {
            const actionText = actionStr === 'APPROVE' ? 'Approve & Execute Fix' : (actionStr === 'PERMANENT_RULE' ? 'Convert to Permanent Rule' : 'Reject Suggestion');
            if(!confirm(`Are you sure you want to: ` + actionText + `?`)) {
                return;
            }

            fetch('${pageContext.request.contextPath}/api/v1/logs/approve', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ logId: logId, action: actionStr })
            })
            .then(response => response.json())
            .then(data => {
                if(data.success) {
                    showToast(data.message, 'success');
                    setTimeout(() => location.reload(), 1000);
                } else {
                    showToast("Error: " + data.message, 'danger');
                }
            })
            .catch(err => {
                showToast("Network Error: " + err, 'danger');
            });
        }
    </script>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>