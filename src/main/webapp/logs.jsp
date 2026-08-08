<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Real-Time Log Monitoring Console | AutoHeal Engine</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/theme.css" rel="stylesheet">
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
                    <a href="${pageContext.request.contextPath}/logs" class="btn btn-sm btn-saas-primary">
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
                <!-- Live Polling Indicator -->
                <div class="d-flex align-items-center gap-2 px-3 py-1 rounded-pill bg-light border border-secondary border-opacity-30">
                    <span class="spinner-grow spinner-grow-sm text-success" id="livePollingPulse" role="status"></span>
                    <span class="text-success small fw-semibold" id="pollingStatusText">Live Feed Active</span>
                </div>

                <div class="dropdown">
                    <button class="btn btn-saas-outline d-flex align-items-center gap-2 py-1.5 px-3 dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <div class="bg-primary text-dark rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width:28px; height:28px; font-size:12px;">
                            <c:out value="${sessionScope.user.fullName.substring(0, 1)}" default="U" />
                        </div>
                        <span class="text-dark small fw-medium"><c:out value="${sessionScope.user.fullName}" default="User" /></span>
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
        
        <!-- Console Header & Action Toolbar -->
        <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-3">
            <div>
                <h3 class="text-dark fw-bold mb-1"><i class="bi bi-terminal text-primary me-2"></i> Ingested Log Monitoring Console</h3>
                <p class="text-muted small mb-0">Stream real-time log entries and observe autonomous recovery actions</p>
            </div>
            
            <div class="d-flex align-items-center gap-2">
                <!-- Test Ingest Simulator Button -->
                <button type="button" class="btn btn-saas-outline d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#testIngestModal">
                    <i class="bi bi-send-plus text-info"></i> Test Log Ingestion
                </button>
            </div>
        </div>

        <!-- Filter Controls Bar -->
        <div class="saas-card p-3 mb-4">
            <div class="row g-2 align-items-center">
                <!-- Filter by Domain -->
                <div class="col-12 col-md-3">
                    <select class="form-select form-control-saas" id="filterDomain">
                        <option value="ALL" selected>All Domains</option>
                        <c:forEach var="dom" items="${domains}">
                            <option value="${dom.id}"><c:out value="${dom.domainName}" /></option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Filter by Log Level -->
                <div class="col-6 col-md-2">
                    <select class="form-select form-control-saas" id="filterLevel">
                        <option value="ALL" selected>All Levels</option>
                        <option value="INFO">INFO</option>
                        <option value="WARN">WARN</option>
                        <option value="ERROR">ERROR</option>
                        <option value="CRITICAL">CRITICAL</option>
                    </select>
                </div>

                <!-- Filter by Status -->
                <div class="col-6 col-md-2">
                    <select class="form-select form-control-saas" id="filterStatus">
                        <option value="ALL" selected>All Statuses</option>
                        <option value="AUTO_HEALED">AUTO_HEALED</option>
                        <option value="PENDING">PENDING</option>
                        <option value="AI_DIAGNOSED">AI_DIAGNOSED</option>
                    </select>
                </div>

                <!-- Search Input -->
                <div class="col-12 col-md-3">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-secondary text-muted"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control form-control-saas" id="filterSearch" placeholder="Search message or action...">
                    </div>
                </div>

                <!-- Auto-Refresh Toggle -->
                <div class="col-12 col-md-2 d-flex justify-content-md-end">
                    <div class="form-check form-switch mb-0">
                        <input class="form-check-input" type="checkbox" id="toggleAutoRefresh" checked>
                        <label class="form-check-label text-muted small" for="toggleAutoRefresh">Auto-Refresh (3s)</label>
                    </div>
                </div>
            </div>
        </div>

        <!-- Terminal Console Card -->
        <div class="saas-card p-0 overflow-hidden border-0 shadow-sm" style="background-color: #f1f5f9;">
            <div class="bg-light bg-opacity-60 px-4 py-2 border-bottom border-secondary border-opacity-30 d-flex align-items-center justify-content-between">
                <div class="d-flex align-items-center gap-2">
                    <span class="rounded-circle bg-danger d-inline-block" style="width:10px; height:10px;"></span>
                    <span class="rounded-circle bg-warning d-inline-block" style="width:10px; height:10px;"></span>
                    <span class="rounded-circle bg-success d-inline-block" style="width:10px; height:10px;"></span>
                    <span class="font-monospace small text-muted ms-2">bash -- autoheal-log-stream.log</span>
                </div>
                <span class="text-muted small font-monospace" id="logCountDisplay">Showing ${logs.size()} entries</span>
            </div>

            <div class="table-responsive" style="max-height: 580px; overflow-y: auto;" id="terminalScrollBox">
                <table class="table table-saas mb-0">
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
                                    <tr>
                                        <td class="font-monospace small text-muted text-nowrap">
                                            <fmt:formatDate value="${log.createdAt}" pattern="HH:mm:ss.SSS" />
                                        </td>
                                        <td>
                                            <span class="badge bg-light border border-secondary text-info">
                                                <c:out value="${log.domainName}" />
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.logLevel eq 'CRITICAL'}">
                                                    <span class="badge bg-danger text-dark fw-bold"><i class="bi bi-exclamation-octagon-fill me-1"></i> CRITICAL</span>
                                                </c:when>
                                                <c:when test="${log.logLevel eq 'ERROR'}">
                                                    <span class="badge bg-danger bg-opacity-20 text-danger border border-danger border-opacity-30"><i class="bi bi-x-circle-fill me-1"></i> ERROR</span>
                                                </c:when>
                                                <c:when test="${log.logLevel eq 'WARN'}">
                                                    <span class="badge bg-warning bg-opacity-20 text-warning border border-warning border-opacity-30"><i class="bi bi-exclamation-triangle-fill me-1"></i> WARN</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-info bg-opacity-20 text-info border border-info border-opacity-30"><i class="bi bi-info-circle-fill me-1"></i> INFO</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="font-monospace small text-dark text-wrap max-w-md">
                                            <c:out value="${log.message}" />
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.status eq 'AUTO_HEALED'}">
                                                    <span class="badge badge-status-active"><i class="bi bi-check-all me-1"></i> AUTO_HEALED</span>
                                                </c:when>
                                                <c:when test="${log.status eq 'PENDING'}">
                                                    <span class="badge bg-warning bg-opacity-15 text-warning border border-warning border-opacity-30"><i class="bi bi-hourglass-split me-1"></i> PENDING</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary text-dark"><c:out value="${log.status}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:if test="${not empty log.executedAction}">
                                                <code class="text-success bg-light bg-opacity-40 px-2 py-1 rounded border border-success border-opacity-30 font-monospace small">
                                                    <i class="bi bi-lightning-charge-fill me-1"></i> <c:out value="${log.executedAction}" />
                                                </code>
                                            </c:if>
                                        </td>
                                        <td class="text-end">
                                            <c:if test="${not empty log.stackTrace}">
                                                <button type="button" class="btn btn-saas-outline btn-sm py-0 px-2 btn-view-trace" 
                                                        data-trace="<c:out value="${log.stackTrace}" />" 
                                                        data-msg="<c:out value="${log.message}" />">
                                                    <i class="bi bi-code-square"></i> Trace
                                                </button>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">No logs recorded for selected filters.</td>
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
                    <h5 class="modal-title text-dark fw-bold"><i class="bi bi-bug-fill text-danger me-2"></i> Log Exception Stack Trace</h5>
                    <button type="button" class="btn-close btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <h6 class="text-warning font-monospace mb-3" id="modalLogMessage"></h6>
                    <pre class="bg-light p-3 rounded border border-secondary text-danger font-monospace small overflow-x-auto" id="modalStackTraceContent"></pre>
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
                    <h5 class="modal-title text-dark fw-bold"><i class="bi bi-send-plus text-info me-2"></i> Simulate Log Ingestion</h5>
                    <button type="button" class="btn-close btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="simIngestForm">
                    <div class="modal-body p-4">
                        <p class="text-muted small mb-3">Submit a sample log entry using API Key header simulation to trigger real-time auto-healing.</p>

                        <div class="mb-3">
                            <label class="form-label-custom" for="simDomainSelect">Target Domain API Key</label>
                            <select class="form-select form-control-saas" id="simDomainSelect" required>
                                <c:forEach var="dom" items="${domains}">
                                    <option value="${dom.apiKey}"><c:out value="${dom.domainName}" /> (${dom.apiKey.substring(0, 14)}...)</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label-custom" for="simLogLevel">Log Level</label>
                            <select class="form-select form-control-saas" id="simLogLevel" required>
                                <option value="INFO">INFO</option>
                                <option value="WARN">WARN</option>
                                <option value="ERROR" selected>ERROR</option>
                                <option value="CRITICAL">CRITICAL</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label-custom" for="simMessage">Log Message</label>
                            <input type="text" class="form-control form-control-saas font-monospace" id="simMessage" 
                                   value="Connection pool exhausted: Timeout waiting for idle connection" required>
                            <span class="text-muted small d-block mt-1">Tip: Use <code>Connection pool exhausted</code> or <code>OutOfMemoryError</code> to trigger seed auto-healing rules!</span>
                        </div>

                        <div class="mb-3">
                            <label class="form-label-custom" for="simStackTrace">Stack Trace (Optional)</label>
                            <textarea class="form-control form-control-saas font-monospace" id="simStackTrace" rows="3" placeholder="java.sql.SQLException: Connection pool exhausted..."></textarea>
                        </div>

                    </div>
                    <div class="modal-footer modal-footer-saas">
                        <button type="button" class="btn btn-saas-outline" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-saas-primary">
                            <i class="bi bi-send me-1"></i> Send Log Payload
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Toast Notifications Container -->
    <div id="toastContainer"></div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            let pollingTimer = null;

            function fetchLatestLogs() {
                const domainId = document.getElementById('filterDomain').value;
                const logLevel = document.getElementById('filterLevel').value;
                const status = document.getElementById('filterStatus').value;
                const searchQuery = document.getElementById('filterSearch').value.trim();

                const query = `domainId=\${encodeURIComponent(domainId)}&logLevel=\${encodeURIComponent(logLevel)}&status=\${encodeURIComponent(status)}&q=\${encodeURIComponent(searchQuery)}&limit=100`;

                fetch(`api/v1/logs?\${query}`)
                .then(res => res.json())
                .then(data => {
                    if (data.success && data.data) {
                        renderLogsTable(data.data);
                    }
                })
                .catch(err => console.error('Polling error:', err));
            }

            function renderLogsTable(logs) {
                const tbody = document.getElementById('logsTableBody');
                const countDisplay = document.getElementById('logCountDisplay');
                if (countDisplay) countDisplay.innerText = `Showing \${logs.length} entries`;

                if (!logs || logs.length === 0) {
                    tbody.innerHTML = `<tr><td colspan="7" class="text-center py-5 text-muted">No logs recorded for selected filters.</td></tr>`;
                    return;
                }

                let html = '';
                logs.forEach(log => {
                    let levelBadge = `<span class="badge bg-info bg-opacity-20 text-info border border-info border-opacity-30"><i class="bi bi-info-circle-fill me-1"></i> INFO</span>`;
                    if (log.logLevel === 'WARN') levelBadge = `<span class="badge bg-warning bg-opacity-20 text-warning border border-warning border-opacity-30"><i class="bi bi-exclamation-triangle-fill me-1"></i> WARN</span>`;
                    if (log.logLevel === 'ERROR') levelBadge = `<span class="badge bg-danger bg-opacity-20 text-danger border border-danger border-opacity-30"><i class="bi bi-x-circle-fill me-1"></i> ERROR</span>`;
                    if (log.logLevel === 'CRITICAL') levelBadge = `<span class="badge bg-danger text-dark fw-bold"><i class="bi bi-exclamation-octagon-fill me-1"></i> CRITICAL</span>`;

                    let statusPill = `<span class="badge bg-secondary text-dark">\${escapeHtml(log.status)}</span>`;
                    if (log.status === 'AUTO_HEALED') statusPill = `<span class="badge badge-status-active"><i class="bi bi-check-all me-1"></i> AUTO_HEALED</span>`;
                    if (log.status === 'PENDING') statusPill = `<span class="badge bg-warning bg-opacity-15 text-warning border border-warning border-opacity-30"><i class="bi bi-hourglass-split me-1"></i> PENDING</span>`;

                    let actionHtml = log.executedAction ? `<code class="text-success bg-light bg-opacity-40 px-2 py-1 rounded border border-success border-opacity-30 font-monospace small"><i class="bi bi-lightning-charge-fill me-1"></i> \${escapeHtml(log.executedAction)}</code>` : '';

                    let traceBtn = log.stackTrace ? `<button type="button" class="btn btn-saas-outline btn-sm py-0 px-2 btn-view-trace" data-trace="\${escapeHtml(log.stackTrace)}" data-msg="\${escapeHtml(log.message)}"><i class="bi bi-code-square"></i> Trace</button>` : '';

                    let timeStr = new Date(log.createdAt).toLocaleTimeString();

                    html += `
                        <tr>
                            <td class="font-monospace small text-muted text-nowrap">\${timeStr}</td>
                            <td><span class="badge bg-light border border-secondary text-info">\${escapeHtml(log.domainName)}</span></td>
                            <td>\${levelBadge}</td>
                            <td class="font-monospace small text-dark text-wrap max-w-md">\${escapeHtml(log.message)}</td>
                            <td>\${statusPill}</td>
                            <td>\${actionHtml}</td>
                            <td class="text-end">\${traceBtn}</td>
                        </tr>
                    `;
                });

                tbody.innerHTML = html;
                attachTraceListeners();
            }

            function attachTraceListeners() {
                document.querySelectorAll('.btn-view-trace').forEach(btn => {
                    btn.addEventListener('click', () => {
                        const msg = btn.getAttribute('data-msg');
                        const trace = btn.getAttribute('data-trace');
                        document.getElementById('modalLogMessage').innerText = msg;
                        document.getElementById('modalStackTraceContent').innerText = trace;
                        const modal = new bootstrap.Modal(document.getElementById('stackTraceModal'));
                        modal.show();
                    });
                });
            }

            function escapeHtml(text) {
                if (!text) return '';
                return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
            }

            // Filters Change Handlers
            ['filterDomain', 'filterLevel', 'filterStatus', 'filterSearch'].forEach(id => {
                const elem = document.getElementById(id);
                if (elem) {
                    elem.addEventListener('input', fetchLatestLogs);
                    elem.addEventListener('change', fetchLatestLogs);
                }
            });

            // Auto Refresh Toggle
            const toggleRef = document.getElementById('toggleAutoRefresh');
            const pulse = document.getElementById('livePollingPulse');
            const pulseText = document.getElementById('pollingStatusText');

            function startPolling() {
                if (pollingTimer) clearInterval(pollingTimer);
                pollingTimer = setInterval(fetchLatestLogs, 3000);
                if (pulse) pulse.classList.remove('d-none');
                if (pulseText) pulseText.innerText = 'Live Feed Active';
            }

            function stopPolling() {
                if (pollingTimer) clearInterval(pollingTimer);
                if (pulse) pulse.classList.add('d-none');
                if (pulseText) pulseText.innerText = 'Feed Paused';
            }

            if (toggleRef) {
                toggleRef.addEventListener('change', (e) => {
                    if (e.target.checked) startPolling();
                    else stopPolling();
                });
                startPolling(); // Initial start
            }

            attachTraceListeners();

            // Test Ingest Simulator Form
            const simForm = document.getElementById('simIngestForm');
            if (simForm) {
                simForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    const apiKey = document.getElementById('simDomainSelect').value;
                    const logLevel = document.getElementById('simLogLevel').value;
                    const message = document.getElementById('simMessage').value.trim();
                    const stackTrace = document.getElementById('simStackTrace').value.trim();

                    fetch('api/v1/logs/ingest', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-API-KEY': apiKey
                        },
                        body: JSON.stringify({ logLevel, message, stackTrace })
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            showToast(`Log ingested! Status: \${data.data.status}`, data.data.status === 'AUTO_HEALED' ? 'success' : 'info');
                            const modal = bootstrap.Modal.getInstance(document.getElementById('testIngestModal'));
                            if (modal) modal.hide();
                            fetchLatestLogs();
                        } else {
                            showToast(data.message, 'danger');
                        }
                    })
                    .catch(err => showToast('Error simulating ingestion: ' + err, 'danger'));
                });
            }
        });
    </script>
</body>
</html>
