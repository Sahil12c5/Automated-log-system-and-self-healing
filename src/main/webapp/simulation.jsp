<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simulation Console | AutoHeal Engine</title>
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
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/guardrails"><i class="bi bi-shield-lock text-danger"></i> Guardrails</a></li>
                            <li><a class="dropdown-item active" href="${pageContext.request.contextPath}/simulation"><i class="bi bi-play-circle text-success"></i> Simulation Console</a></li>
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
                <h2 class="fw-bold mb-1"><i class="bi bi-play-circle text-success me-2"></i> End-to-End Incident Simulation Playground</h2>
                <p class="text-muted small mb-0">Inject synthetic exception payloads into the multi-tenant pipeline to test autonomous detection &amp; self-healing</p>
            </div>
            <div class="d-flex align-items-center gap-2">
                <span class="badge badge-status-active">
                    <span class="pulse-indicator me-1"></span> Simulation Engine Ready
                </span>
            </div>
        </div>

        <div class="row g-4">
            <!-- Controls -->
            <div class="col-lg-5">
                <div class="saas-card h-100 p-4">
                    <div class="d-flex align-items-center gap-3 mb-4">
                        <div class="stat-card-icon" style="background: rgba(99, 102, 241, 0.15); color: var(--primary-color);">
                            <i class="bi bi-lightning-charge-fill"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-0">Synthetic Test Generators</h5>
                            <span class="text-muted small">Select an injection scenario to trigger pipeline</span>
                        </div>
                    </div>

                    <div class="d-flex flex-column gap-3">
                        <!-- Scenario A -->
                        <div class="p-3 rounded-3" style="background: rgba(16, 185, 129, 0.08); border: 1px solid rgba(16, 185, 129, 0.25);">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="badge" style="background: rgba(16, 185, 129, 0.2); color: #34d399; font-weight: 600;">Scenario A</span>
                                <span class="small text-muted font-monospace">Phase 2 Engine</span>
                            </div>
                            <h6 class="fw-bold text-success mb-1">Deterministic Rule Match</h6>
                            <p class="text-muted small mb-3">Injects a <code>Connection pool exhausted</code> exception to trigger rule pattern matching and instant restart execution.</p>
                            <button class="btn btn-saas-primary w-100" id="btnSimA" onclick="runSim('A')">
                                <i class="bi bi-play-fill me-1"></i> Fire Test Case A
                            </button>
                        </div>

                        <!-- Scenario B -->
                        <div class="p-3 rounded-3" style="background: rgba(99, 102, 241, 0.08); border: 1px solid rgba(99, 102, 241, 0.25);">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="badge" style="background: rgba(99, 102, 241, 0.2); color: #a5b4fc; font-weight: 600;">Scenario B</span>
                                <span class="small text-muted font-monospace">Phase 3 AI</span>
                            </div>
                            <h6 class="fw-bold text-primary mb-1">Unknown Stack Trace Diagnosis</h6>
                            <p class="text-muted small mb-3">Injects an untriaged <code>NullPointerException</code> to invoke Gemini AI root-cause analysis and enqueue for approval.</p>
                            <button class="btn btn-saas-outline w-100" id="btnSimB" onclick="runSim('B')">
                                <i class="bi bi-stars me-1 text-primary"></i> Fire Test Case B
                            </button>
                        </div>

                        <!-- Scenario C -->
                        <div class="p-3 rounded-3" style="background: rgba(239, 68, 68, 0.08); border: 1px solid rgba(239, 68, 68, 0.25);">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="badge" style="background: rgba(239, 68, 68, 0.2); color: #f87171; font-weight: 600;">Scenario C</span>
                                <span class="small text-muted font-monospace">Phase 5 Guardrails</span>
                            </div>
                            <h6 class="fw-bold text-danger mb-1">Loop Lockout Security Breach</h6>
                            <p class="text-muted small mb-3">Fires rapid successive failure events to intentionally breach the Rate Limiter threshold and trigger administrative lockout.</p>
                            <button class="btn btn-outline-danger w-100" id="btnSimC" onclick="runSim('C')">
                                <i class="bi bi-shield-slash me-1"></i> Fire Test Case C
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Dark Hacker Console Output -->
            <div class="col-lg-7">
                <div class="terminal-window h-100 d-flex flex-column">
                    <div class="terminal-header">
                        <div class="terminal-dots">
                            <span class="terminal-dot dot-red"></span>
                            <span class="terminal-dot dot-yellow"></span>
                            <span class="terminal-dot dot-green"></span>
                            <span class="terminal-title ms-2"><i class="bi bi-terminal me-1"></i> telemetry-simulation-stream.sh</span>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <button class="btn btn-sm btn-saas-outline py-0 px-2" onclick="copyStreamContent()" title="Copy Stream">
                                <i class="bi bi-clipboard"></i> Copy
                            </button>
                            <button class="btn btn-sm btn-saas-outline py-0 px-2" onclick="clearStream()" title="Clear Console">
                                <i class="bi bi-eraser"></i> Clear
                            </button>
                        </div>
                    </div>
                    
                    <div class="terminal-body flex-grow-1" id="simOutput" style="min-height: 480px; max-height: 600px; background: #070a10;">
                        <span style="color: #64748b;">[INIT] AutoHeal Synthetic Event Dispatcher v2.4 initialized.</span><br>
                        <span style="color: #10b981;">[STATUS] Multi-Tenant Gateway connected. Listening on /api/v1/simulation/run...</span><br>
                        <span style="color: #64748b;">[READY] Select a scenario from the left panel to begin.</span>
                    </div>

                    <div class="p-2.5 px-3 border-top border-secondary border-opacity-20 d-flex justify-content-between align-items-center text-muted small font-monospace" style="background: rgba(255, 255, 255, 0.02);">
                        <span id="streamStatus"><i class="bi bi-circle-fill text-success" style="font-size: 8px;"></i> Stream Live</span>
                        <a href="${pageContext.request.contextPath}/logs" class="text-decoration-none text-info small">
                            Inspect Ingested Logs <i class="bi bi-arrow-right"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Toast Notifications Container -->
    <div id="toastContainer"></div>

    <script>
        function logToStream(msg, color = "#34d399") {
            const out = document.getElementById('simOutput');
            const now = new Date().toISOString().split('T')[1].split('.')[0];
            out.innerHTML += `<br><span style="color: ` + color + `;">[` + now + `] ` + msg + `</span>`;
            out.scrollTop = out.scrollHeight;
        }

        function clearStream() {
            document.getElementById('simOutput').innerHTML = '<span style="color: #64748b;">[RESET] Pipeline stream cleared. Ready for next test case.</span>';
        }

        function copyStreamContent() {
            const text = document.getElementById('simOutput').innerText;
            navigator.clipboard.writeText(text).then(() => {
                showToast("Console stream copied to clipboard!", "success");
            });
        }

        function runSim(testCase) {
            const btn = document.getElementById('btnSim' + testCase);
            const origHTML = btn ? btn.innerHTML : '';
            if (btn) {
                btn.disabled = true;
                btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Injecting Payload...';
            }

            logToStream(`>>> INITIATING SYNTHETIC PAYLOAD INJECTION [Scenario ` + testCase + `]...`, "#fbbf24");
            
            fetch('${pageContext.request.contextPath}/api/v1/simulation/run', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'testCase=' + encodeURIComponent(testCase)
            })
            .then(res => res.json())
            .then(data => {
                if (btn) {
                    btn.disabled = false;
                    btn.innerHTML = origHTML;
                }

                if (data.success) {
                    logToStream(`[PASS] Ingestion confirmed: ` + data.message, "#34d399");
                    logToStream(`[PIPELINE] Execution completed. Check Logs console & Audit Trail for recorded events.`, "#38bdf8");
                    showToast(data.message, "success");
                } else {
                    logToStream(`[LOCKOUT / REJECT] ` + data.message, "#f87171");
                    showToast(data.message, "danger");
                }
            })
            .catch(err => {
                if (btn) {
                    btn.disabled = false;
                    btn.innerHTML = origHTML;
                }
                logToStream(`[FATAL EXCEPTION] ` + err, "#f87171");
                showToast("Simulation network error: " + err, "danger");
            });
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>