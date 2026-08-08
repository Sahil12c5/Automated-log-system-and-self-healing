<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Approval Queue | AutoHeal Engine</title>
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
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
                <h1 class="h2"><i class="bi bi-check2-square text-primary me-2"></i> Fix Approval Queue</h1>
                <p class="text-muted">Review and authorize AI-generated remediation strategies.</p>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <div class="row">
                <c:forEach var="log" items="${logs}">
                    <div class="col-12 mb-4">
                        <div class="card shadow-sm border-start border-4 border-warning">
                            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="badge ${log.logLevel == 'ERROR' || log.logLevel == 'CRITICAL' ? 'bg-danger' : 'bg-warning'} me-2">
                                        ${log.logLevel}
                                    </span>
                                    <strong>Domain:</strong> ${log.domainName}
                                </div>
                                <div class="text-muted small">
                                    <i class="bi bi-clock me-1"></i> ${log.timestamp}
                                </div>
                            </div>
                            
                            <div class="card-body">
                                <h6 class="text-danger fw-bold">Error Trigger</h6>
                                <p class="mb-3">${log.message}</p>
                                
                                <div class="row bg-light p-3 rounded">
                                    <div class="col-md-6 border-end">
                                        <h6 class="text-primary mb-2"><i class="bi bi-search me-1"></i> Gemini AI Root Cause</h6>
                                        <div class="markdown-body" data-markdown="${log.aiRootCause}"></div>
                                    </div>
                                    <div class="col-md-6">
                                        <h6 class="text-success mb-2"><i class="bi bi-tools me-1"></i> Proposed Remediation</h6>
                                        <div class="markdown-body" data-markdown="${log.aiRemediationSuggestion}"></div>
                                    </div>
                                </div>
                            </div>

                            <div class="card-footer bg-white d-flex gap-2">
                                <button class="btn btn-success flex-grow-1" onclick="handleAction(${log.id}, 'APPROVE')">
                                    <i class="bi bi-play-fill me-1"></i> Approve & Execute
                                </button>
                                <button class="btn btn-primary flex-grow-1" onclick="handleAction(${log.id}, 'PERMANENT_RULE')">
                                    <i class="bi bi-shield-plus me-1"></i> Save as Permanent Rule
                                </button>
                                <button class="btn btn-danger flex-grow-1" onclick="handleAction(${log.id}, 'REJECT')">
                                    <i class="bi bi-x-circle me-1"></i> Reject Suggestion
                                </button>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty logs}">
                    <div class="alert alert-success d-flex align-items-center" role="alert">
                        <i class="bi bi-check-circle-fill me-2 fs-4"></i>
                        <div>
                            <strong>Queue Empty!</strong> There are no pending AI diagnostic fixes awaiting your approval.
                        </div>
                    </div>
                </c:if>
            </div>
        </div>

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
        if(!confirm(`Are you sure you want to perform action: ` + actionStr + `?`)) {
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
                alert(data.message);
                location.reload();
            } else {
                alert("Error: " + data.message);
            }
        })
        .catch(err => {
            alert("Network Error: " + err);
        });
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
