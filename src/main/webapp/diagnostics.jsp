<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Diagnostics Console | AutoHeal Engine</title>
    <!-- Custom Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Include marked.js for markdown rendering -->
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
                            <li><a class="dropdown-item active" href="${pageContext.request.contextPath}/diagnostics"><i class="bi bi-search text-primary"></i> Diagnostics</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/approvals"><i class="bi bi-check2-square text-warning"></i> Approvals Queue</a></li>
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
        <div class="d-flex flex-wrap justify-content-between align-items-center pb-3 mb-4 border-bottom border-secondary border-opacity-20 gap-3">
            <div>
                <h2 class="fw-bold mb-1"><i class="bi bi-robot text-primary me-2"></i> Gemini AI Automated Diagnostics</h2>
                <p class="text-muted small mb-0">Deep semantic analysis of unknown stack traces, root cause extraction, and autonomous fix suggestions</p>
            </div>
            <div class="d-flex align-items-center gap-2">
                <a href="${pageContext.request.contextPath}/approvals" class="btn btn-saas-outline">
                    <i class="bi bi-check2-square text-warning me-1"></i> Go to Approvals Queue
                </a>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger mb-4"><i class="bi bi-exclamation-triangle me-2"></i> ${error}</div>
        </c:if>

        <div class="row">
            <c:forEach var="log" items="${logs}">
                <div class="col-12 mb-4">
                    <div class="diagnostic-card position-relative-container" id="card-${log.id}">
                        
                        <!-- Shimmering Loading Spinner Overlay -->
                        <div class="spinner-overlay" id="spinner-${log.id}">
                            <div class="text-center p-4 rounded-3" style="background: var(--bg-surface); border: 1px solid var(--border-color); box-shadow: var(--shadow-glow);">
                                <div class="spinner-border text-primary mb-2" role="status">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                                <h6 class="fw-bold mb-1 text-primary"><i class="bi bi-stars"></i> Gemini AI is analyzing stack trace...</h6>
                                <span class="text-muted small">Correlating error tokens and formulating remediation script</span>
                            </div>
                        </div>

                        <!-- Card Header -->
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
                            <div>
                                <span class="ai-badge" id="statusBadge-${log.id}">
                                    <i class="bi bi-stars me-1"></i> ${log.status == 'PENDING' ? 'Awaiting AI Diagnosis' : 'AI Diagnosed'}
                                </span>
                            </div>
                        </div>
                        
                        <!-- Card Body -->
                        <div class="p-4">
                            <div class="row g-4">
                                <!-- Raw Error Info -->
                                <div class="col-lg-6 border-end-lg border-secondary border-opacity-20">
                                    <h6 class="form-label-custom mb-2"><i class="bi bi-bug me-1 text-danger"></i> Ingested Error Message</h6>
                                    <div class="p-3 rounded mb-3 font-monospace small" style="background: var(--bg-terminal); border: 1px solid var(--border-color); color: #f87171;">
                                        ${log.message}
                                    </div>
                                    
                                    <c:if test="${not empty log.stackTrace}">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <h6 class="form-label-custom mb-0"><i class="bi bi-code-square me-1"></i> Stack Trace</h6>
                                            <button type="button" class="btn btn-sm btn-saas-outline py-0 px-2" onclick="copyTextToClipboard('${log.stackTrace}', this, 'Copied stack trace!')">
                                                <i class="bi bi-clipboard"></i> Copy
                                            </button>
                                        </div>
                                        <pre class="p-3 rounded font-monospace small" style="max-height: 220px; overflow-y: auto; background: var(--bg-terminal); border: 1px solid var(--border-color); color: #94a3b8;">${log.stackTrace}</pre>
                                    </c:if>
                                </div>

                                <!-- AI Analysis Area -->
                                <div class="col-lg-6">
                                    <div id="aiAnalysisArea-${log.id}" class="${log.status == 'PENDING' ? 'd-none' : ''}">
                                        <div class="p-3 rounded mb-3" style="background: rgba(99, 102, 241, 0.08); border: 1px solid rgba(99, 102, 241, 0.25);">
                                            <h6 class="fw-bold text-primary mb-2"><i class="bi bi-search me-1"></i> AI Identified Root Cause</h6>
                                            <div class="markdown-body" data-markdown="${log.aiRootCause}"></div>
                                        </div>
                                        
                                        <div class="p-3 rounded" style="background: rgba(16, 185, 129, 0.08); border: 1px solid rgba(16, 185, 129, 0.25);">
                                            <h6 class="fw-bold text-success mb-2"><i class="bi bi-tools me-1"></i> Proposed Remediation Fix</h6>
                                            <div class="markdown-body" data-markdown="${log.aiRemediationSuggestion}"></div>
                                        </div>
                                    </div>
                                    
                                    <div id="aiTriggerArea-${log.id}" class="h-100 d-flex align-items-center justify-content-center flex-column text-center py-4 ${log.status == 'PENDING' ? '' : 'd-none'}">
                                        <div class="mb-3 p-3 rounded-circle" style="background: rgba(99, 102, 241, 0.12); width: 64px; height: 64px; display: flex; align-items: center; justify-content: center;">
                                            <i class="bi bi-stars text-primary fs-3"></i>
                                        </div>
                                        <h6 class="fw-bold mb-1">Untriaged Exception Event</h6>
                                        <p class="text-muted small mb-3" style="max-width: 320px;">Invoke Gemini AI to synthesize this error and produce an actionable remediation recommendation.</p>
                                        <button class="btn btn-saas-primary" onclick="triggerDiagnosis(${log.id})">
                                            <i class="bi bi-stars me-1"></i> Analyze with Gemini AI
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <c:if test="${empty logs}">
                <div class="col-12">
                    <div class="saas-card p-5 text-center">
                        <i class="bi bi-check-circle-fill fs-1 text-success d-block mb-3"></i>
                        <h4 class="fw-bold">No Untriaged Diagnostics</h4>
                        <p class="text-muted">All incoming log errors have either been autonomously resolved or triaged by AI.</p>
                        <a href="${pageContext.request.contextPath}/logs" class="btn btn-saas-outline mt-2">
                            <i class="bi bi-terminal me-1"></i> View Live Logs
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

        function triggerDiagnosis(logId) {
            const spinner = document.getElementById('spinner-' + logId);
            if (spinner) spinner.style.display = 'flex';
            
            fetch('${pageContext.request.contextPath}/api/v1/diagnose', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ logId: logId })
            })
            .then(response => response.json())
            .then(data => {
                if (spinner) spinner.style.display = 'none';
                if(data.success) {
                    showToast('Gemini AI successfully diagnosed the exception!', 'success');
                    
                    const triggerArea = document.getElementById('aiTriggerArea-' + logId);
                    if (triggerArea) triggerArea.classList.add('d-none');
                    
                    const analysisArea = document.getElementById('aiAnalysisArea-' + logId);
                    if (analysisArea) {
                        analysisArea.classList.remove('d-none');
                        const markdownBoxes = analysisArea.querySelectorAll('.markdown-body');
                        if (markdownBoxes[0]) markdownBoxes[0].innerHTML = marked.parse(data.data.aiRootCause || "No root cause identified.");
                        if (markdownBoxes[1]) markdownBoxes[1].innerHTML = marked.parse(data.data.aiRemediationSuggestion || "No remediation suggested.");
                    }
                    
                    const badge = document.getElementById('statusBadge-' + logId);
                    if (badge) {
                        badge.innerHTML = '<i class="bi bi-stars me-1"></i> AI Diagnosed';
                    }
                } else {
                    showToast("AI Service Error: " + data.message, 'danger');
                }
            })
            .catch(err => {
                if (spinner) spinner.style.display = 'none';
                showToast("Network Error: " + err, 'danger');
            });
        }
    </script>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>