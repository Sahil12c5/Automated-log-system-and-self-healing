<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Real-Time Log Stream Console | AutoHeal Engine</title>
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
                    <a href="${pageContext.request.contextPath}/dashboard" class="nav-link-saas">
                        <i class="bi bi-speedometer2"></i> Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/logs" class="nav-link-saas active">
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
                <!-- Live Ingestion Stream Pulse -->
                <div class="d-flex align-items-center gap-2 px-3 py-1.5 rounded-pill" style="background: rgba(16, 185, 129, 0.12); border: 1px solid rgba(16, 185, 129, 0.3);">
                    <span class="pulse-indicator"></span>
                    <span class="small fw-semibold" style="color: #34d399;" id="pollingStatusText">Live Feed Active</span>
                </div>

                <!-- Theme Switcher Toggle -->
                <button type="button" class="btn-theme-toggle" title="Toggle Theme">
                    <i class="bi bi-sun-fill text-warning"></i>
                </button>

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
        
        <!-- Console Header & Action Toolbar -->
        <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-3">
            <div>
                <h3 class="fw-bold mb-1"><i class="bi bi-terminal text-primary me-2"></i> Real-Time Log Monitoring Console</h3>
                <p class="text-muted small mb-0">High-throughput log aggregation pipeline with autonomous self-healing triggers</p>
            </div>
            
            <div class="d-flex align-items-center gap-2">
                <!-- Test Ingest Simulator Button -->
                <button type="button" class="btn btn-saas-primary d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#testIngestModal">
                    <i class="bi bi-send-plus"></i> Simulate Ingestion
                </button>
            </div>
        </div>

        <!-- Filter Controls Bar -->
        <div class="saas-card p-3 mb-4">
            <div class="row g-2 align-items-center">
                <!-- Filter by Domain -->
                <div class="col-12 col-md-3">
                    <label class="form-label-custom mb-1">Domain</label>
                    <select class="form-select form-control-saas" id="filterDomain" onchange="applyLogFilters()">
                        <option value="ALL" selected>All Domains</option>
                        <c:forEach var="dom" items="${domains}">
                            <option value="${dom.domainName}"><c:out value="${dom.domainName}" /></option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Filter by Log Level -->
                <div class="col-6 col-md-2">
                    <label class="form-label-custom mb-1">Severity</label>
                    <select class="form-select form-control-saas" id="filterLevel" onchange="applyLogFilters()">
                        <option value="ALL" selected>All Levels</option>
                        <option value="INFO">INFO</option>
                        <option value="WARN">WARN</option>
                        <option value="ERROR">ERROR</option>
                        <option value="CRITICAL">CRITICAL</option>
                    </select>
                </div>

                <!-- Filter by Status -->
                <div class="col-6 col-md-2">
                    <label class="form-label-custom mb-1">Recovery Status</label>
                    <select class="form-select form-control-saas" id="filterStatus" onchange="applyLogFilters()">
                        <option value="ALL" selected>All Statuses</option>
                        <option value="AUTO_HEALED">AUTO_HEALED</option>
                        <option value="PENDING">PENDING</option>
                        <option value="AI_DIAGNOSED">AI_DIAGNOSED</option>
                    </select>
                </div>

                <!-- Search Input -->
                <div class="col-12 col-md-3">
                    <label class="form-label-custom mb-1">Live Search</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control form-control-saas" id="filterSearch" placeholder="Search message or action..." oninput="applyLogFilters()">
                    </div>
                </div>

                <!-- Auto-Refresh Toggle -->
                <div class="col-12 col-md-2 d-flex justify-content-md-end align-items-end pt-3">
                    <div class="form-check form-switch mb-0">
                        <input class="form-check-input" type="checkbox" id="toggleAutoRefresh" checked>
                        <label class="form-check-label text-muted small" for="toggleAutoRefresh">Auto-Refresh (3s)</label>
                    </div>
                </div>
            </div>
        </div>

        <!-- Terminal Console Card -->
        <div class="terminal-window">
            <div class="terminal-header">
                <div class="terminal-dots">
                    <span class="terminal-dot dot-red"></span>
                    <span class="terminal-dot dot-yellow"></span>
                    <span class="terminal-dot dot-green"></span>
                    <span class="terminal-title ms-2"><i class="bi bi-terminal me-1"></i> autoheal-log-stream.log</span>
                </div>
                <div class="d-flex align-items-center gap-3">
                    <span class="text-muted small font-monospace" id="logCountDisplay">Showing ${logs.size()} entries</span>
                    <button class="btn btn-sm btn-saas-outline py-0 px-2" onclick="window.location.reload()" title="Refresh Now">
                        <i class="bi bi-arrow-clockwise"></i>
                    </button>
                </div>
            </div>

            <div class="table-responsive" style="max-height: 580px; overflow-y: auto;" id="terminalScrollBox">
                <table class="table table-saas mb-0" id="logsTable">
                    <thead>
                        <tr>
                            <th>Timestamp</th>
                            <th>Domain</th>
                            <th>Level</th>
                            <th>Message</th>
                            <th>Status</th>
                            <th>Executed Recovery Action</th>
                            <th class="text-end">Stack Trace</th>
                        </tr>
                    </thead>
                    <tbody id="logsTableBody">
                        <c:choose>
                            <c:when test="${not empty logs}">
                                <c:forEach var="log" items="${logs}">
                                    <tr data-domain="<c:out value="${log.domainName}" />" data-level="${log.logLevel}" data-status="${log.status}">
                                        <td class="font-monospace small text-muted text-nowrap">
                                            <fmt:formatDate value="${log.createdAt}" pattern="HH:mm:ss.SSS" />
                                        </td>
                                        <td>
                                            <span class="badge" style="background: rgba(6, 182, 212, 0.12); color: #38bdf8; border: 1px solid rgba(6, 182, 212, 0.3);">
                                                <c:out value="${log.domainName}" />
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.logLevel eq 'CRITICAL'}">
                                                    <span class="badge bg-danger text-white fw-bold"><i class="bi bi-exclamation-octagon-fill me-1"></i> CRITICAL</span>
                                                </c:when>
                                                <c:when test="${log.logLevel eq 'ERROR'}">
                                                    <span class="badge" style="background: rgba(239, 68, 68, 0.18); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.35);"><i class="bi bi-x-circle-fill me-1"></i> ERROR</span>
                                                </c:when>
                                                <c:when test="${log.logLevel eq 'WARN'}">
                                                    <span class="badge" style="background: rgba(245, 158, 11, 0.18); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.35);"><i class="bi bi-exclamation-triangle-fill me-1"></i> WARN</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge" style="background: rgba(6, 182, 212, 0.15); color: #38bdf8; border: 1px solid rgba(6, 182, 212, 0.35);"><i class="bi bi-info-circle-fill me-1"></i> INFO</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="font-monospace small text-wrap" style="max-width: 420px; color: var(--text-main);">
                                            <c:out value="${log.message}" />
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.status eq 'AUTO_HEALED'}">
                                                    <span class="badge badge-status-active"><i class="bi bi-check-all me-1"></i> AUTO_HEALED</span>
                                                </c:when>
                                                <c:when test="${log.status eq 'PENDING'}">
                                                    <span class="badge" style="background: rgba(245, 158, 11, 0.15); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.3);"><i class="bi bi-hourglass-split me-1"></i> PENDING</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary bg-opacity-25 text-main border border-secondary border-opacity-40"><c:out value="${log.status}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:if test="${not empty log.executedAction}">
                                                <code class="px-2 py-1 rounded font-monospace small" style="background: rgba(16, 185, 129, 0.15); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.35);">
                                                    <i class="bi bi-lightning-charge-fill me-1"></i> <c:out value="${log.executedAction}" />
                                                </code>
                                            </c:if>
                                        </td>
                                        <td class="text-end">
                                            <c:if test="${not empty log.stackTrace}">
                                                <button type="button" class="btn btn-saas-outline btn-sm py-0.5 px-2 btn-view-trace" 
                                                        data-trace="<c:out value="${log.stackTrace}" />" 
                                                        data-msg="<c:out value="${log.message}" />">
                                                    <i class="bi bi-code-square me-1"></i> Trace
                                                </button>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr id="noLogsRow">
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="bi bi-terminal fs-1 d-block mb-2 text-secondary"></i>
                                        No log entries recorded yet. Click <strong>"Simulate Ingestion"</strong> to send a test event.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <!-- Modal: View Stack Trace -->
    <div class="modal fade" id="stackTraceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content modal-content-saas">
                <div class="modal-header modal-header-saas">
                    <h5 class="modal-title fw-bold"><i class="bi bi-bug-fill text-danger me-2"></i> Log Exception Stack Trace</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <h6 class="font-monospace mb-3 text-warning" id="modalLogMessage"></h6>
                    <div class="position-relative">
                        <pre class="p-3 rounded font-monospace small overflow-x-auto text-danger" id="modalStackTraceContent" style="background: var(--bg-terminal); border: 1px solid var(--border-color); max-height: 380px;"></pre>
                        <button class="btn btn-sm btn-saas-outline position-absolute top-0 end-0 m-2" onclick="copyToClipboard('modalStackTraceContent')">
                            <i class="bi bi-clipboard"></i> Copy Trace
                        </button>
                    </div>
                </div>
                <div class="modal-footer modal-footer-saas">
                    <button type="button" class="btn btn-saas-outline" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal: Test Ingest Simulator -->
    <div class="modal fade" id="testIngestModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content modal-content-saas">
                <div class="modal-header modal-header-saas">
                    <h5 class="modal-title fw-bold"><i class="bi bi-send-plus text-primary me-2"></i> Simulate Log Ingestion</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="simIngestForm">
                    <div class="modal-body p-4">
                        <p class="text-muted small mb-3">Submit a simulated log event using API Key header verification to test live ingestion and auto-healing.</p>

                        <!-- Pre-set Templates -->
                        <div class="mb-3">
                            <label class="form-label-custom">Quick Preset Scenarios</label>
                            <div class="d-flex flex-wrap gap-2">
                                <button type="button" class="btn btn-sm btn-saas-outline" onclick="loadSamplePreset('db')">
                                    <i class="bi bi-database me-1"></i> DB Connection Pool
                                </button>
                                <button type="button" class="btn btn-sm btn-saas-outline" onclick="loadSamplePreset('oom')">
                                    <i class="bi bi-memory me-1"></i> OutOfMemoryError
                                </button>
                                <button type="button" class="btn btn-sm btn-saas-outline" onclick="loadSamplePreset('cache')">
                                    <i class="bi bi-hdd-rack me-1"></i> Cache Flush
                                </button>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label-custom" for="simDomainSelect">Target Domain API Key</label>
                            <select class="form-select form-control-saas" id="simDomainSelect" required>
                                <c:forEach var="dom" items="${domains}">
                                    <option value="${dom.apiKey}"><c:out value="${dom.domainName}" /> (${dom.apiKey.substring(0, 10)}...)</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label-custom" for="simLogLevel">Severity Level</label>
                            <select class="form-select form-control-saas" id="simLogLevel" required>
                                <option value="INFO">INFO</option>
                                <option value="WARN">WARN</option>
                                <option value="ERROR" selected>ERROR</option>
                                <option value="CRITICAL">CRITICAL</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label-custom" for="simLogMessage">Log Message</label>
                            <textarea class="form-control form-control-saas font-monospace small" id="simLogMessage" rows="2" placeholder="e.g. org.postgresql.util.PSQLException: Connection pool exhausted" required></textarea>
                        </div>

                        <div class="mb-3">
                            <label class="form-label-custom" for="simStackTrace">Stack Trace (Optional)</label>
                            <textarea class="form-control form-control-saas font-monospace small" id="simStackTrace" rows="3" placeholder="Paste exception stack trace..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-saas">
                        <button type="button" class="btn btn-saas-outline" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-saas-primary" id="btnSubmitSimLog">
                            <i class="bi bi-send me-1"></i> Ingest Log Event
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Client-side Interactivity Script for Logs Console -->
    <script>
        function applyLogFilters() {
            const domainVal = document.getElementById('filterDomain').value.toLowerCase();
            const levelVal = document.getElementById('filterLevel').value.toUpperCase();
            const statusVal = document.getElementById('filterStatus').value.toUpperCase();
            const searchVal = document.getElementById('filterSearch').value.toLowerCase().trim();

            const rows = document.querySelectorAll('#logsTableBody tr');
            let visibleCount = 0;

            rows.forEach(row => {
                if (row.id === 'noLogsRow') return;

                const rowDomain = (row.getAttribute('data-domain') || '').toLowerCase();
                const rowLevel = (row.getAttribute('data-level') || '').toUpperCase();
                const rowStatus = (row.getAttribute('data-status') || '').toUpperCase();
                const rowText = row.innerText.toLowerCase();

                const matchDomain = (domainVal === 'all' || rowDomain === domainVal);
                const matchLevel = (levelVal === 'ALL' || rowLevel === levelVal);
                const matchStatus = (statusVal === 'ALL' || rowStatus === statusVal);
                const matchSearch = (!searchVal || rowText.includes(searchVal));

                if (matchDomain && matchLevel && matchStatus && matchSearch) {
                    row.style.display = '';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            });

            const countDisplay = document.getElementById('logCountDisplay');
            if (countDisplay) {
                countDisplay.innerText = `Showing ` + visibleCount + ` entries`;
            }
        }

        function loadSamplePreset(type) {
            const msgEl = document.getElementById('simLogMessage');
            const traceEl = document.getElementById('simStackTrace');
            const levelEl = document.getElementById('simLogLevel');

            if (type === 'db') {
                levelEl.value = 'ERROR';
                msgEl.value = 'org.postgresql.util.PSQLException: FATAL - Connection pool exhausted! Max limit 50 reached.';
                traceEl.value = 'at com.zaxxer.hikari.pool.HikariPool.getConnection(HikariPool.java:182)\n\tat com.autoheal.dao.DBConnection.getConnection(DBConnection.java:42)';
            } else if (type === 'oom') {
                levelEl.value = 'CRITICAL';
                msgEl.value = 'java.lang.OutOfMemoryError: Java heap space during heavy batch processing.';
                traceEl.value = 'at java.base/java.util.Arrays.copyOf(Arrays.java:3512)\n\tat com.autoheal.service.BatchIngest.process(BatchIngest.java:88)';
            } else if (type === 'cache') {
                levelEl.value = 'WARN';
                msgEl.value = 'RedisCacheMissWarning: Key eviction rate spiked above 90% threshold in node-east-1.';
                traceEl.value = 'at io.lettuce.core.RedisClient.connect(RedisClient.java:112)';
            }
        }

        // Stack Trace Modal handler
        document.addEventListener('click', (e) => {
            const btn = e.target.closest('.btn-view-trace');
            if (btn) {
                const trace = btn.getAttribute('data-trace');
                const msg = btn.getAttribute('data-msg');
                document.getElementById('modalLogMessage').innerText = msg;
                document.getElementById('modalStackTraceContent').innerText = trace;
                const modal = new bootstrap.Modal(document.getElementById('stackTraceModal'));
                modal.show();
            }
        });

        // Form Submission for Sim Ingestion
        document.getElementById('simIngestForm').addEventListener('submit', (e) => {
            e.preventDefault();
            const apiKey = document.getElementById('simDomainSelect').value;
            const level = document.getElementById('simLogLevel').value;
            const message = document.getElementById('simLogMessage').value;
            const stackTrace = document.getElementById('simStackTrace').value;
            const submitBtn = document.getElementById('btnSubmitSimLog');

            submitBtn.disabled = true;
            submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Ingesting...';

            fetch('api/v1/logs/ingest', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-API-Key': apiKey
                },
                body: JSON.stringify({
                    logLevel: level,
                    message: message,
                    stackTrace: stackTrace
                })
            })
            .then(res => res.json())
            .then(data => {
                submitBtn.disabled = false;
                submitBtn.innerHTML = '<i class="bi bi-send me-1"></i> Ingest Log Event';

                if (data.success) {
                    showToast(data.message, 'success');
                    const modalElem = document.getElementById('testIngestModal');
                    const modal = bootstrap.Modal.getInstance(modalElem);
                    if (modal) modal.hide();
                    setTimeout(() => window.location.reload(), 900);
                } else {
                    showToast(data.message || 'Ingestion rejected', 'danger');
                }
            })
            .catch(err => {
                submitBtn.disabled = false;
                submitBtn.innerHTML = '<i class="bi bi-send me-1"></i> Ingest Log Event';
                showToast('Ingestion error: ' + err, 'danger');
            });
        });

        // Auto Refresh
        let refreshInterval = setInterval(() => {
            const autoRefresh = document.getElementById('toggleAutoRefresh');
            if (autoRefresh && autoRefresh.checked) {
                // Smoothly reload logs
                window.location.reload();
            }
        }, 3000);
    </script>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>