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
    <style>
        @keyframes spin { 100% { transform: rotate(360deg); } }
        .spin-animation { display: inline-block; animation: spin 0.75s linear infinite; }
        
        /* Dynamic New Log Row Highlight */
        .log-row-new { animation: logRowHighlight 3.5s ease-out; }
        @keyframes logRowHighlight {
            0% {
                background-color: rgba(99, 102, 241, 0.45) !important;
                box-shadow: inset 0 0 15px rgba(99, 102, 241, 0.5);
            }
            40% {
                background-color: rgba(99, 102, 241, 0.2) !important;
            }
            100% {
                background-color: transparent !important;
            }
        }

        /* Pulse Indicator */
        .pulse-dot {
            width: 8px;
            height: 8px;
            background-color: #10b981;
            border-radius: 50%;
            display: inline-block;
            box-shadow: 0 0 0 rgba(16, 185, 129, 0.7);
            animation: pulseGlow 1.8s infinite;
        }
        @keyframes pulseGlow {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
            70% { transform: scale(1.15); box-shadow: 0 0 0 7px rgba(16, 185, 129, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }

        /* Live Toast Floating Notifications */
        #liveToastContainer {
            position: fixed;
            top: 24px;
            right: 24px;
            z-index: 10050;
            max-width: 420px;
            display: flex;
            flex-direction: column;
            gap: 12px;
            pointer-events: none;
        }
        .live-incident-toast {
            pointer-events: auto;
            background: rgba(15, 23, 42, 0.95);
            backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.16);
            border-radius: 12px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.6), 0 0 15px rgba(99, 102, 241, 0.2);
            overflow: hidden;
            animation: toastSlideIn 0.35s cubic-bezier(0.16, 1, 0.3, 1);
            color: #f8fafc;
        }
        @keyframes toastSlideIn {
            from { opacity: 0; transform: translateX(50px) scale(0.95); }
            to { opacity: 1; transform: translateX(0) scale(1); }
        }

        /* Terminal Window High-Contrast Overrides */
        .terminal-window {
            background: #0b0f19 !important;
            border: 1px solid rgba(255, 255, 255, 0.12) !important;
            color: #f1f5f9 !important;
        }
        .terminal-window .terminal-header {
            background: rgba(255, 255, 255, 0.04) !important;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
        }
        .terminal-window .terminal-title,
        .terminal-window .table-saas th {
            color: #94a3b8 !important;
        }
        .terminal-window #logCountDisplay {
            color: #cbd5e1 !important;
        }
        .terminal-window .table-saas td {
            color: #f1f5f9 !important;
            border-bottom: 1px solid rgba(255, 255, 255, 0.07) !important;
        }
        .terminal-window .log-timestamp-cell {
            color: #94a3b8 !important;
        }
        .terminal-window .log-message-cell {
            color: #f8fafc !important;
        }
        .terminal-window .btn-saas-outline {
            background: rgba(255, 255, 255, 0.08) !important;
            color: #e2e8f0 !important;
            border-color: rgba(255, 255, 255, 0.2) !important;
        }
        .terminal-window .btn-saas-outline:hover {
            background: rgba(255, 255, 255, 0.16) !important;
            color: #ffffff !important;
            border-color: rgba(255, 255, 255, 0.35) !important;
        }
    </style>
</head>
<body>
    <!-- Real-time Floating Incident Toast Notifications Container -->
    <div id="liveToastContainer" aria-live="polite" aria-atomic="true"></div>

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
                    <div class="d-flex align-items-center gap-2 px-2.5 py-1 rounded-pill" style="background: rgba(16, 185, 129, 0.12); border: 1px solid rgba(16, 185, 129, 0.3);">
                        <span class="pulse-dot"></span>
                        <span class="font-monospace small fw-bold" id="streamStatusBadge" style="font-size: 0.72rem; color: #34d399;">LIVE STREAMING</span>
                    </div>
                    <span class="text-muted small font-monospace" id="logCountDisplay">Showing ${logs.size()} entries</span>
                    <button class="btn btn-sm btn-saas-outline py-0 px-2" id="btnToggleSound" onclick="toggleSoundAlert()" title="Notification Audio Enabled">
                        <i class="bi bi-volume-up text-info" id="soundIcon"></i>
                    </button>
                    <button class="btn btn-sm btn-saas-outline py-0 px-2" onclick="refreshLogsManually()" id="btnManualRefresh" title="Refresh Live Logs">
                        <i class="bi bi-arrow-clockwise" id="manualRefreshIcon"></i>
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
                                    <tr data-id="${log.id}" data-domain="<c:out value="${log.domainName}" />" data-level="${log.logLevel}" data-status="${log.status}">
                                        <td class="font-monospace small text-nowrap log-timestamp-cell" style="color: #94a3b8 !important;">
                                            <fmt:formatDate value="${log.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" />
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
                                        <td class="font-monospace small text-wrap log-message-cell" style="max-width: 420px; color: #f8fafc !important;">
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

            fetch('${pageContext.request.contextPath}/api/v1/logs/ingest', {
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
                    document.getElementById('simLogMessage').value = '';
                    document.getElementById('simStackTrace').value = '';
                    // Fetch live logs immediately without full page reload!
                    fetchLiveLogs(true);
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

        // Audio Alert Chime using Web Audio API (No external assets required)
        let soundAlertEnabled = true;
        function toggleSoundAlert() {
            soundAlertEnabled = !soundAlertEnabled;
            const btn = document.getElementById('btnToggleSound');
            const icon = document.getElementById('soundIcon');
            if (btn && icon) {
                if (soundAlertEnabled) {
                    icon.className = 'bi bi-volume-up text-info';
                    btn.title = 'Notification Audio Enabled';
                } else {
                    icon.className = 'bi bi-volume-mute text-muted';
                    btn.title = 'Notification Audio Muted';
                }
            }
        }

        function playLiveAlertSound() {
            if (!soundAlertEnabled) return;
            try {
                const ctx = new (window.AudioContext || window.webkitAudioContext)();
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(587.33, ctx.currentTime); // D5
                osc.frequency.exponentialRampToValueAtTime(880, ctx.currentTime + 0.12); // A5
                gain.gain.setValueAtTime(0.12, ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.25);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start();
                osc.stop(ctx.currentTime + 0.25);
            } catch (e) {
                // AudioContext not allowed before user interaction in some browsers
            }
        }

        // Real-Time Incident Toast Notification
        function showIncidentToast(log) {
            const container = document.getElementById('liveToastContainer');
            if (!container) return;

            const toast = document.createElement('div');
            toast.className = 'live-incident-toast p-3';

            const level = (log.logLevel || 'INFO').toUpperCase();
            const status = (log.status || 'PENDING').toUpperCase();
            let levelBadgeClass = 'bg-info text-dark';
            if (level === 'CRITICAL' || level === 'ERROR') levelBadgeClass = 'bg-danger text-white';
            else if (level === 'WARN') levelBadgeClass = 'bg-warning text-dark';

            let statusBadge = '';
            if (status === 'AUTO_HEALED') {
                statusBadge = '<span class="badge" style="background:#064e3b; color:#34d399; border:1px solid #059669;"><i class="bi bi-check-all me-1"></i>AUTO_HEALED</span>';
            } else if (status === 'LOOP_DETECTED') {
                statusBadge = '<span class="badge bg-danger text-white"><i class="bi bi-shield-slash me-1"></i>LOOP_DETECTED</span>';
            } else if (status === 'SECURITY_BLOCKED') {
                statusBadge = '<span class="badge bg-danger text-white"><i class="bi bi-shield-x me-1"></i>BLOCKED</span>';
            } else {
                statusBadge = `<span class="badge bg-warning text-dark">${escapeHtml(status)}</span>`;
            }

            const timeStr = formatLogTime(log.createdAt);

            toast.innerHTML = `
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <div class="d-flex align-items-center gap-2">
                        <span class="badge ${levelBadgeClass} fw-bold">${level}</span>
                        <strong class="text-white small">${escapeHtml(log.domainName || 'Domain')}</strong>
                    </div>
                    <button type="button" class="btn-close btn-close-white small ms-2" onclick="this.closest('.live-incident-toast').remove()"></button>
                </div>
                <div class="text-light font-monospace small text-truncate my-1" title="${escapeHtml(log.message || '')}">
                    ${escapeHtml(log.message || '')}
                </div>
                <div class="d-flex justify-content-between align-items-center mt-2 pt-1 border-top border-secondary border-opacity-25">
                    <div>${statusBadge}</div>
                    <small class="text-muted font-monospace" style="font-size:0.7rem;">${timeStr}</small>
                </div>
                ${log.executedAction ? `<div class="mt-1 small font-monospace text-success text-truncate" style="font-size:0.72rem;"><i class="bi bi-lightning-charge me-1"></i>${escapeHtml(log.executedAction)}</div>` : ''}
            `;

            container.prepend(toast);

            // Auto-remove after 7 seconds
            setTimeout(() => {
                toast.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
                toast.style.opacity = '0';
                toast.style.transform = 'translateX(50px)';
                setTimeout(() => toast.remove(), 400);
            }, 7000);
        }

        // Track known log IDs to highlight brand new logs
        const knownLogIds = new Set();
        let isInitialLoad = true;

        document.querySelectorAll('#logsTableBody tr[data-id]').forEach(r => {
            const id = r.getAttribute('data-id');
            if (id) knownLogIds.add(String(id));
        });
        setTimeout(() => { isInitialLoad = false; }, 800);

        function escapeHtml(text) {
            if (!text) return '';
            return String(text)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
        }

        function formatLogTime(dateVal) {
            if (!dateVal) return '';
            try {
                const d = (typeof dateVal === 'number') ? new Date(dateVal) : new Date(String(dateVal));
                if (isNaN(d.getTime())) return String(dateVal);
                const pad = (n, s = 2) => String(n).padStart(s, '0');
                const year = d.getFullYear();
                const month = pad(d.getMonth() + 1);
                const day = pad(d.getDate());
                const hours = pad(d.getHours());
                const minutes = pad(d.getMinutes());
                const seconds = pad(d.getSeconds());
                return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
            } catch (e) {
                return String(dateVal);
            }
        }

        function renderLogRow(log, isNew = false) {
            const timeFormatted = formatLogTime(log.createdAt);
            const domain = escapeHtml(log.domainName || '');
            const level = (log.logLevel || 'INFO').toUpperCase();
            const status = (log.status || 'PENDING').toUpperCase();
            const message = escapeHtml(log.message || '');
            const rawMessage = log.message || '';
            const rawTrace = log.stackTrace || '';
            const executedAction = log.executedAction || '';

            let levelBadge = '';
            if (level === 'CRITICAL') {
                levelBadge = '<span class="badge bg-danger text-white fw-bold"><i class="bi bi-exclamation-octagon-fill me-1"></i> CRITICAL</span>';
            } else if (level === 'ERROR') {
                levelBadge = '<span class="badge" style="background: rgba(239, 68, 68, 0.18); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.35);"><i class="bi bi-x-circle-fill me-1"></i> ERROR</span>';
            } else if (level === 'WARN') {
                levelBadge = '<span class="badge" style="background: rgba(245, 158, 11, 0.18); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.35);"><i class="bi bi-exclamation-triangle-fill me-1"></i> WARN</span>';
            } else {
                levelBadge = '<span class="badge" style="background: rgba(6, 182, 212, 0.15); color: #38bdf8; border: 1px solid rgba(6, 182, 212, 0.35);"><i class="bi bi-info-circle-fill me-1"></i> INFO</span>';
            }

            let statusBadge = '';
            if (status === 'AUTO_HEALED') {
                statusBadge = '<span class="badge badge-status-active"><i class="bi bi-check-all me-1"></i> AUTO_HEALED</span>';
            } else if (status === 'PENDING') {
                statusBadge = '<span class="badge" style="background: rgba(245, 158, 11, 0.15); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.3);"><i class="bi bi-hourglass-split me-1"></i> PENDING</span>';
            } else if (status === 'LOOP_DETECTED') {
                statusBadge = '<span class="badge bg-danger bg-opacity-25 text-danger border border-danger border-opacity-40"><i class="bi bi-shield-slash me-1"></i> LOOP_DETECTED</span>';
            } else if (status === 'SECURITY_BLOCKED') {
                statusBadge = '<span class="badge bg-danger bg-opacity-25 text-danger border border-danger border-opacity-40"><i class="bi bi-shield-x me-1"></i> BLOCKED</span>';
            } else if (status === 'AI_DIAGNOSED') {
                statusBadge = '<span class="badge" style="background: rgba(99, 102, 241, 0.18); color: #818cf8; border: 1px solid rgba(99, 102, 241, 0.35);"><i class="bi bi-robot me-1"></i> AI_DIAGNOSED</span>';
            } else {
                statusBadge = `<span class="badge bg-secondary bg-opacity-25 text-main border border-secondary border-opacity-40">${escapeHtml(status)}</span>`;
            }

            let actionHtml = '';
            if (executedAction) {
                actionHtml = `<code class="px-2 py-1 rounded font-monospace small" style="background: rgba(16, 185, 129, 0.15); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.35);"><i class="bi bi-lightning-charge-fill me-1"></i> ${escapeHtml(executedAction)}</code>`;
            }

            let traceHtml = '';
            if (rawTrace) {
                traceHtml = `<button type="button" class="btn btn-saas-outline btn-sm py-0.5 px-2 btn-view-trace" data-trace="${escapeHtml(rawTrace)}" data-msg="${escapeHtml(rawMessage)}"><i class="bi bi-code-square me-1"></i> Trace</button>`;
            }

            const newClass = isNew ? ' log-row-new' : '';

            return `
                <tr data-id="${log.id}" data-domain="${domain}" data-level="${level}" data-status="${status}" class="${newClass}">
                    <td class="font-monospace small text-nowrap log-timestamp-cell" style="color: #94a3b8 !important;">${timeFormatted}</td>
                    <td>
                        <span class="badge" style="background: rgba(6, 182, 212, 0.12); color: #38bdf8; border: 1px solid rgba(6, 182, 212, 0.3);">
                            ${domain}
                        </span>
                    </td>
                    <td>${levelBadge}</td>
                    <td class="font-monospace small text-wrap log-message-cell" style="max-width: 420px; color: #f8fafc !important;">${message}</td>
                    <td>${statusBadge}</td>
                    <td>${actionHtml}</td>
                    <td class="text-end">${traceHtml}</td>
                </tr>
            `;
        }

        let isFetchingLogs = false;
        let lastLogSignature = '';

        function renderLogsTable(logs) {
            const tbody = document.getElementById('logsTableBody');
            if (!tbody) return;

            if (!logs || logs.length === 0) {
                tbody.innerHTML = `
                    <tr id="noLogsRow">
                        <td colspan="7" class="text-center py-5 text-muted">
                            <i class="bi bi-terminal fs-1 d-block mb-2 text-secondary"></i>
                            No log entries recorded yet. Click <strong>"Simulate Ingestion"</strong> to send a test event.
                        </td>
                    </tr>
                `;
                applyLogFilters();
                return;
            }

            let newlyArrivedCount = 0;
            const html = logs.map(log => {
                const logIdStr = String(log.id);
                const isNew = !knownLogIds.has(logIdStr);
                if (isNew) {
                    knownLogIds.add(logIdStr);
                    if (!isInitialLoad) {
                        newlyArrivedCount++;
                        showIncidentToast(log);
                    }
                }
                return renderLogRow(log, isNew && !isInitialLoad);
            }).join('');

            if (newlyArrivedCount > 0) {
                playLiveAlertSound();
                const scrollBox = document.getElementById('terminalScrollBox');
                if (scrollBox) {
                    scrollBox.scrollTo({ top: 0, behavior: 'smooth' });
                }
            }

            tbody.innerHTML = html;
            applyLogFilters();
        }

        function fetchLiveLogs(force = false) {
            if (isFetchingLogs) return;
            isFetchingLogs = true;

            const refreshIcon = document.getElementById('manualRefreshIcon');
            if (refreshIcon && force) {
                refreshIcon.classList.add('spin-animation');
            }

            const streamBadge = document.getElementById('streamStatusBadge');

            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 4000);

            const url = '${pageContext.request.contextPath}/api/v1/logs?limit=100&_t=' + Date.now();

            fetch(url, {
                signal: controller.signal,
                headers: { 'Accept': 'application/json' },
                cache: 'no-store'
            })
            .then(res => {
                clearTimeout(timeoutId);
                if (!res.ok) throw new Error('HTTP ' + res.status);
                return res.json();
            })
            .then(data => {
                if (data && data.success && Array.isArray(data.data)) {
                    const logs = data.data;
                    const signature = logs.map(l => `${l.id}:${l.status}:${l.executedAction}`).join('|');
                    
                    if (force || signature !== lastLogSignature) {
                        lastLogSignature = signature;
                        renderLogsTable(logs);
                    }

                    if (streamBadge) {
                        streamBadge.innerText = 'LIVE STREAMING';
                        streamBadge.style.color = '#34d399';
                    }
                }
            })
            .catch(err => {
                clearTimeout(timeoutId);
                if (err.name !== 'AbortError') {
                    console.warn('Live log poll note:', err.message);
                }
                if (streamBadge) {
                    streamBadge.innerText = 'RECONNECTING';
                    streamBadge.style.color = '#f59e0b';
                }
            })
            .finally(() => {
                isFetchingLogs = false;
                if (refreshIcon) {
                    refreshIcon.classList.remove('spin-animation');
                }
            });
        }

        function refreshLogsManually() {
            fetchLiveLogs(true);
        }

        // Ultra-responsive Real-Time AJAX Stream polling every 1.5 seconds!
        let refreshInterval = setInterval(() => {
            const autoRefresh = document.getElementById('toggleAutoRefresh');
            if (autoRefresh && autoRefresh.checked) {
                fetchLiveLogs(false);
            }
        }, 1500);

        // Immediate first poll
        setTimeout(() => { fetchLiveLogs(false); }, 1500);
    </script>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>