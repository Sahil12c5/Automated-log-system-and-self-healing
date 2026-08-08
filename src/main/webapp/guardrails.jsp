<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guardrails & Security | AutoHeal Engine</title>
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
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
                        <button class="btn btn-sm btn-saas-outline border-0 dropdown-toggle" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-robot me-1"></i> AI Engine
                        </button>
                        <ul class="dropdown-menu shadow-sm shadow-lg border-secondary">
                            <li><a class="dropdown-item text-dark" href="${pageContext.request.contextPath}/diagnostics"><i class="bi bi-search me-2"></i> Diagnostics</a></li>
                            <li><a class="dropdown-item text-dark" href="${pageContext.request.contextPath}/approvals"><i class="bi bi-check2-square me-2"></i> Approvals Queue</a></li>
                        </ul>
                    </div>

                    <!-- Administration -->
                    <div class="dropdown">
                        <button class="btn btn-sm btn-saas-primary dropdown-toggle" type="button" data-bs-toggle="dropdown">
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
                <h1 class="h2"><i class="bi bi-shield-lock text-danger me-2"></i> Security Guardrails</h1>
                <p class="text-muted">Manage loop limits and script command blacklisting.</p>
            </div>

            <div class="row mb-4">
                <div class="col-md-6">
                    <div class="card metric-card border-warning shadow-sm h-100">
                        <div class="card-header bg-white"><i class="bi bi-arrow-repeat text-warning me-2"></i> Reboot Loop Prevention</div>
                        <div class="card-body">
                            <p class="text-muted small">Configure the maximum number of automated fix executions allowed per domain within the rolling time window.</p>
                            <form id="limitForm" class="d-flex align-items-end gap-2">
                                <div class="flex-grow-1">
                                    <label class="form-label small">Max Executions per 15 Minutes</label>
                                    <input type="number" class="form-control" id="maxExecutions" value="${maxExecutions}" required min="1" max="100">
                                </div>
                                <button type="submit" class="btn btn-warning text-dark"><i class="bi bi-save"></i> Save</button>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="card metric-card border-danger shadow-sm h-100">
                        <div class="card-header bg-white"><i class="bi bi-slash-circle text-danger me-2"></i> Command Sanitizer Blacklist</div>
                        <div class="card-body">
                            <p class="text-muted small">Operational scripts containing any of these keywords will be strictly blocked from execution.</p>
                            <div class="d-flex flex-wrap gap-2 mb-3">
                                <c:forEach var="keyword" items="${blacklist}">
                                    <span class="badge bg-danger fs-6">
                                        ${keyword} <i class="bi bi-x ms-1 text-dark" style="cursor:pointer" onclick="removeKeyword('${keyword}')"></i>
                                    </span>
                                </c:forEach>
                            </div>
                            <form id="keywordForm" class="d-flex gap-2">
                                <input type="text" class="form-control" id="newKeyword" placeholder="e.g. format" required>
                                <button type="submit" class="btn btn-danger"><i class="bi bi-plus-circle"></i> Add</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

<script>
    document.getElementById('limitForm').addEventListener('submit', function(e) {
        e.preventDefault();
        const maxEx = document.getElementById('maxExecutions').value;
        fetch('${pageContext.request.contextPath}/api/v1/guardrails/settings', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=UPDATE_LIMITS&maxExecutions=' + maxEx
        }).then(res => res.json()).then(data => { alert(data.message); location.reload(); });
    });

    document.getElementById('keywordForm').addEventListener('submit', function(e) {
        e.preventDefault();
        const kw = document.getElementById('newKeyword').value;
        fetch('${pageContext.request.contextPath}/api/v1/guardrails/settings', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=ADD_KEYWORD&keyword=' + encodeURIComponent(kw)
        }).then(res => res.json()).then(data => { location.reload(); });
    });

    function removeKeyword(kw) {
        if(confirm("Remove '" + kw + "' from blacklist?")) {
            fetch('${pageContext.request.contextPath}/api/v1/guardrails/settings', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=REMOVE_KEYWORD&keyword=' + encodeURIComponent(kw)
            }).then(res => res.json()).then(data => { location.reload(); });
        }
    }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
