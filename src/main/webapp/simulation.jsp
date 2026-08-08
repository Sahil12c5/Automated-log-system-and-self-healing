<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simulation Console | AutoHeal Engine</title>
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
                <h1 class="h2"><i class="bi bi-play-circle text-success me-2"></i> End-to-End Test Simulation</h1>
                <p class="text-muted">Inject synthetic errors into the ingestion pipeline to test automated remediations.</p>
            </div>

            <div class="row">
                <!-- Controls -->
                <div class="col-md-5 mb-4">
                    <div class="card shadow-sm h-100">
                        <div class="card-header bg-white fw-bold"><i class="bi bi-lightning-charge text-primary me-2"></i> Error Generators</div>
                        <div class="card-body d-flex flex-column gap-3">
                            <button class="btn btn-outline-success text-start sim-btn" onclick="runSim('A')">
                                <div class="fw-bold"><i class="bi bi-check-circle me-1"></i> Test Case A: Known Error</div>
                                <small class="text-muted d-block">Injects a "Connection pool exhausted" error to trigger Phase 2 deterministic auto-healing instantly.</small>
                            </button>
                            
                            <button class="btn btn-outline-primary text-start sim-btn" onclick="runSim('B')">
                                <div class="fw-bold"><i class="bi bi-magic me-1"></i> Test Case B: Unknown Error</div>
                                <small class="text-muted d-block">Injects a "NullPointerException" to trigger Phase 3 Gemini AI analysis and queue for approval.</small>
                            </button>

                            <button class="btn btn-outline-danger text-start sim-btn" onclick="runSim('C')">
                                <div class="fw-bold"><i class="bi bi-shield-x me-1"></i> Test Case C: Loop Lockout</div>
                                <small class="text-muted d-block">Fires 4 known errors sequentially to intentionally breach the Phase 5 Rate Limiter threshold.</small>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Console Output -->
                <div class="col-md-7 mb-4">
                    <div class="card shadow-sm h-100">
                        <div class="card-header bg-light text-dark fw-bold"><i class="bi bi-terminal me-2"></i> Pipeline Execution Stream</div>
                        <div class="card-body bg-light p-0">
                            <div id="simOutput">
                                > SYSTEM READY. Awaiting test case injection...
                            </div>
                        </div>
                        <div class="card-footer bg-light border-top border-secondary text-end">
                            <button class="btn btn-sm btn-outline-secondary text-dark" onclick="document.getElementById('simOutput').innerHTML='> SYSTEM READY. Awaiting test case injection...'"><i class="bi bi-eraser"></i> Clear Stream</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

<script>
    function logToStream(msg, color = "#00ff00") {
        const out = document.getElementById('simOutput');
        out.innerHTML += `<br><span style="color: ${color}">[${new Date().toISOString().split('T')[1].split('.')[0]}] ${msg}</span>`;
        out.scrollTop = out.scrollHeight;
    }

    function runSim(testCase) {
        logToStream(`> INITIATING TEST CASE ${testCase}...`, "#ffc107");
        
        const btnClass = testCase === 'A' ? 'success' : (testCase === 'B' ? 'primary' : 'danger');
        
        fetch('${pageContext.request.contextPath}/api/v1/simulation/run', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'testCase=' + testCase
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                logToStream(`SUCCESS: ${data.message}`);
                logToStream(`> Pipeline Execution Completed. Verify results in Log Console and Audit Trail.`, "#00bfff");
            } else {
                logToStream(`ERROR: ${data.message}`, "#ff4444");
            }
        })
        .catch(err => {
            logToStream(`FATAL EXCEPTION: ${err}`, "#ff4444");
        });
    }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
