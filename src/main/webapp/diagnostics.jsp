<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Diagnostics Dashboard</title>
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Include marked.js for markdown rendering -->
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    
</head>
<body>

    <!-- Top Dashboard Navbar -->
    <nav class="navbar navbar-saas">
        <div class="container-fluid px-4">
            <div class="d-flex align-items-center gap-4">
                <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/dashboard">
                    <i class="bi bi-cpu-fill text-primary fs-3"></i>
                    <span class="brand-gradient">AutoHeal Console</span>
                </a>

                <!-- Main Navigation Links -->
                <div class="d-none d-md-flex align-items-center gap-1">
                    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-sm btn-saas-outline border-0">
                        <i class="bi bi-speedometer2 me-1"></i> Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/logs" class="btn btn-sm btn-saas-outline border-0">
                        <i class="bi bi-terminal-fill me-1"></i> Live Logs
                    </a>
                    <a href="${pageContext.request.contextPath}/rules" class="btn btn-sm btn-saas-outline border-0">
                        <i class="bi bi-magic me-1"></i> Healing Rules
                    </a>
                    
                    <!-- AI & Approvals -->
                    <div class="dropdown">
                        <button class="btn btn-sm btn-saas-primary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-robot me-1"></i> AI Engine
                        </button>
                        <ul class="dropdown-menu shadow-sm shadow-lg border-secondary">
                            <li><a class="dropdown-item text-dark" href="${pageContext.request.contextPath}/diagnostics"><i class="bi bi-search me-2"></i> Diagnostics</a></li>
                            <li><a class="dropdown-item text-dark" href="${pageContext.request.contextPath}/approvals"><i class="bi bi-check2-square me-2"></i> Approvals Queue</a></li>
                        </ul>
                    </div>

                    <!-- Administration -->
                    <div class="dropdown">
                        <button class="btn btn-sm btn-saas-outline border-0 dropdown-toggle" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-shield-lock me-1"></i> Admin
                        </button>
                        <ul class="dropdown-menu shadow-sm shadow-lg border-secondary">
                            <li><a class="dropdown-item text-dark" href="${pageContext.request.contextPath}/team"><i class="bi bi-people me-2"></i> Team Management</a></li>
                            <li><a class="dropdown-item text-dark" href="${pageContext.request.contextPath}/audit"><i class="bi bi-clock-history me-2"></i> Audit Trail</a></li>
                            <li><hr class="dropdown-divider border-secondary"></li>
                            <li><a class="dropdown-item text-dark" href="${pageContext.request.contextPath}/guardrails"><i class="bi bi-shield-lock me-2"></i> Guardrails</a></li>
                            <li><a class="dropdown-item text-dark" href="${pageContext.request.contextPath}/simulation"><i class="bi bi-play-circle me-2"></i> Simulation Console</a></li>
                        </ul>
                    </div>
                </div>
            </div>
            
            <div class="d-flex align-items-center gap-3">
                <!-- Tenant Org Badge -->
                <div class="d-none d-md-flex align-items-center gap-2 px-3 py-1.5 rounded-pill bg-light border border-secondary border-opacity-30">
                    <i class="bi bi-buildings text-primary"></i>
                    <span class="text-dark fw-semibold small"><c:out value="${sessionScope.orgName}" default="Organization" /></span>
                </div>

                <!-- User Profile & Role -->
                <div class="dropdown">
                    <button class="btn btn-saas-outline d-flex align-items-center gap-2 py-1.5 px-3 dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <div class="bg-primary text-dark rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width:28px; height:28px; font-size:12px;">
                            <c:out value="${sessionScope.user.fullName.substring(0, 1)}" default="U" />
                        </div>
                        <span class="text-dark small fw-medium"><c:out value="${sessionScope.user.fullName}" default="User" /></span>
                        <span class="badge badge-role"><c:out value="${sessionScope.user.role}" default="MEMBER" /></span>
                    </button>
                    <ul class="dropdown-menu shadow-sm dropdown-menu-end shadow-lg border-secondary">
                        <li><h6 class="dropdown-header text-muted"><c:out value="${sessionScope.user.email}" /></h6></li>
                        <li><hr class="dropdown-divider border-secondary"></li>
                        <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i> Sign Out</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Container -->
    <div class="container-fluid px-4 py-4">
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-4 border-bottom">
                <h1 class="h2"><i class="bi bi-magic text-primary me-2"></i> Gemini AI Diagnostics</h1>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <div class="row">
                <c:forEach var="log" items="${logs}">
                    <div class="col-12 mb-4">
                        <div class="card shadow-sm diagnostic-card position-relative-container" id="card-${log.id}">
                            
                            <!-- Loading Spinner -->
                            <div class="spinner-overlay" id="spinner-${log.id}">
                                <div class="text-center">
                                    <div class="spinner-border text-primary mb-2" role="status">
                                        <span class="visually-hidden">Loading...</span>
                                    </div>
                                    <h6 class="text-primary">Gemini AI is analyzing...</h6>
                                </div>
                            </div>

                            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="badge ${log.logLevel == 'ERROR' || log.logLevel == 'CRITICAL' ? 'bg-danger' : 'bg-warning'} me-2">
                                        ${log.logLevel}
                                    </span>
                                    <strong>Domain:</strong> ${log.domainName}
                                </div>
                                <div>
                                    <span class="badge ai-badge" id="statusBadge-${log.id}">
                                        ${log.status == 'PENDING' ? 'Awaiting Diagnosis' : 'AI Analyzed'}
                                    </span>
                                </div>
                            </div>
                            
                            <div class="card-body row">
                                <!-- Raw Error Info -->
                                <div class="col-md-6 border-end">
                                    <h6 class="text-muted mb-2">Original Error Message</h6>
                                    <p class="fw-bold">${log.message}</p>
                                    
                                    <c:if test="${not empty log.stackTrace}">
                                        <h6 class="text-muted mt-3 mb-2">Stack Trace</h6>
                                        <pre class="bg-light p-2 rounded" style="max-height: 200px; overflow-y: auto; font-size: 0.85rem;">${log.stackTrace}</pre>
                                    </c:if>
                                </div>

                                <!-- AI Analysis Area -->
                                <div class="col-md-6">
                                    <div id="aiAnalysisArea-${log.id}" class="${log.status == 'PENDING' ? 'd-none' : ''}">
                                        <h6 class="text-primary mb-2"><i class="bi bi-search me-1"></i> Root Cause</h6>
                                        <div class="markdown-body mb-3" data-markdown="${log.aiRootCause}"></div>
                                        
                                        <h6 class="text-success mb-2"><i class="bi bi-tools me-1"></i> Remediation Suggestion</h6>
                                        <div class="markdown-body" data-markdown="${log.aiRemediationSuggestion}"></div>
                                    </div>
                                    
                                    <div id="aiTriggerArea-${log.id}" class="h-100 d-flex align-items-center justify-content-center flex-column ${log.status == 'PENDING' ? '' : 'd-none'}">
                                        <p class="text-muted text-center mb-3">This error hasn't been analyzed yet.</p>
                                        <button class="btn btn-outline-primary shadow-sm" onclick="triggerDiagnosis(${log.id})">
                                            <i class="bi bi-stars"></i> Analyze with Gemini
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty logs}">
                    <div class="alert alert-info">No pending or AI diagnosed logs found. Great job!</div>
                </c:if>
            </div>
        </div>

<script>
    // Render markdown for all elements with data-markdown
    document.addEventListener("DOMContentLoaded", function() {
        document.querySelectorAll('.markdown-body').forEach(el => {
            const rawMarkdown = el.getAttribute('data-markdown');
            if(rawMarkdown && rawMarkdown.trim() !== "") {
                el.innerHTML = marked.parse(rawMarkdown);
            }
        });
    });

    function triggerDiagnosis(logId) {
        // Show spinner
        document.getElementById('spinner-' + logId).style.display = 'flex';
        
        fetch('${pageContext.request.contextPath}/api/v1/diagnose', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ logId: logId })
        })
        .then(response => response.json())
        .then(data => {
            document.getElementById('spinner-' + logId).style.display = 'none';
            if(data.success) {
                // Hide trigger area, show analysis area
                document.getElementById('aiTriggerArea-' + logId).classList.add('d-none');
                
                const analysisArea = document.getElementById('aiAnalysisArea-' + logId);
                analysisArea.classList.remove('d-none');
                
                // Populate markdown and render it
                const rootCauseEl = analysisArea.querySelectorAll('.markdown-body')[0];
                const remediationEl = analysisArea.querySelectorAll('.markdown-body')[1];
                
                rootCauseEl.innerHTML = marked.parse(data.data.aiRootCause || "No root cause identified.");
                remediationEl.innerHTML = marked.parse(data.data.aiRemediationSuggestion || "No remediation suggested.");
                
                // Update badge
                const badge = document.getElementById('statusBadge-' + logId);
                badge.textContent = 'AI Analyzed';
                
            } else {
                alert("Error from AI Service: " + data.message);
            }
        })
        .catch(err => {
            document.getElementById('spinner-' + logId).style.display = 'none';
            alert("Network Error: " + err);
        });
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
