<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Auto-Healing Rules | AutoHeal Engine</title>
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
                    <a href="${pageContext.request.contextPath}/logs" class="nav-link-saas">
                        <i class="bi bi-terminal-fill"></i> Live Logs
                    </a>
                    <a href="${pageContext.request.contextPath}/rules" class="nav-link-saas active">
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
        
        <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-4">
            <div>
                <h3 class="fw-bold mb-1"><i class="bi bi-magic text-primary me-2"></i> Deterministic Auto-Healing Rules</h3>
                <p class="text-muted small mb-0">Define automated remediation triggers when ingested error patterns are matched</p>
            </div>
            <div class="d-flex align-items-center gap-2 flex-wrap">
                <button type="button" class="btn btn-saas-outline" data-bs-toggle="modal" data-bs-target="#regexTesterModal">
                    <i class="bi bi-regex me-1 text-info"></i> Test Regex / Pattern
                </button>
                <button type="button" class="btn btn-saas-primary d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#addRuleModal">
                    <i class="bi bi-plus-lg"></i> Create Healing Rule
                </button>
            </div>
        </div>

        <!-- Filter bar -->
        <div class="saas-card p-3 mb-4">
            <div class="row g-2 align-items-center">
                <div class="col-md-4">
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control form-control-saas" id="tableSearchInput" placeholder="Filter rules by pattern, script, or domain...">
                    </div>
                </div>
                <div class="col-md-8 text-md-end text-muted small">
                    <span>Secured by <code>CommandSanitizer</code> guardrail limits</span>
                </div>
            </div>
        </div>

        <!-- Rules Data Table Card -->
        <div class="saas-card">
            <div class="table-responsive">
                <table class="table table-saas">
                    <thead>
                        <tr>
                            <th>Target Domain</th>
                            <th>Error Pattern String / Regex</th>
                            <th>Action Type</th>
                            <th>Target Script / Command</th>
                            <th>Active Status</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty rules}">
                                <c:forEach var="rule" items="${rules}">
                                    <tr>
                                        <td>
                                            <span class="badge" style="background: rgba(6, 182, 212, 0.12); color: #38bdf8; border: 1px solid rgba(6, 182, 212, 0.3);">
                                                <i class="bi bi-globe me-1"></i> <c:out value="${rule.domainName}" />
                                            </span>
                                        </td>
                                        <td>
                                            <code class="px-2 py-1 rounded font-monospace small" style="background: rgba(245, 158, 11, 0.12); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.3);">
                                                <c:out value="${rule.errorPattern}" />
                                            </code>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${rule.actionType eq 'RESTART_SERVICE'}">
                                                    <span class="badge" style="background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.35);">
                                                        <i class="bi bi-arrow-repeat me-1"></i> RESTART SERVICE
                                                    </span>
                                                </c:when>
                                                <c:when test="${rule.actionType eq 'CLEAR_CACHE'}">
                                                    <span class="badge" style="background: rgba(245, 158, 11, 0.15); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.35);">
                                                        <i class="bi bi-trash2 me-1"></i> CLEAR CACHE
                                                    </span>
                                                </c:when>
                                                <c:when test="${rule.actionType eq 'RESET_CONNECTION'}">
                                                    <span class="badge" style="background: rgba(6, 182, 212, 0.15); color: #38bdf8; border: 1px solid rgba(6, 182, 212, 0.35);">
                                                        <i class="bi bi-diagram-3 me-1"></i> RESET CONNECTION
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge" style="background: rgba(99, 102, 241, 0.15); color: #a5b4fc; border: 1px solid rgba(99, 102, 241, 0.35);">
                                                        <i class="bi bi-code-slash me-1"></i> CUSTOM SCRIPT
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <code class="px-2 py-1 rounded font-monospace small" style="background: rgba(255, 255, 255, 0.05); color: var(--text-main); border: 1px solid var(--border-color);">
                                                <c:out value="${rule.targetScript}" />
                                            </code>
                                        </td>
                                        <td>
                                            <!-- Interactive AJAX Toggle Switch -->
                                            <div class="form-check form-switch">
                                                <input class="form-check-input rule-toggle-switch" type="checkbox" role="switch" 
                                                       data-rule-id="${rule.id}" ${rule.active ? 'checked' : ''}>
                                                <span class="small ${rule.active ? 'text-success fw-semibold' : 'text-muted'}">
                                                    ${rule.active ? 'Active' : 'Disabled'}
                                                </span>
                                            </div>
                                        </td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-outline-danger btn-sm px-2.5 py-1" onclick="deleteRule(${rule.id}, '${rule.errorPattern}')" title="Delete Rule">
                                                <i class="bi bi-trash3"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-magic fs-1 d-block mb-2 text-secondary"></i>
                                        No auto-healing rules configured yet. Click <strong>"Create Healing Rule"</strong> to set up autonomous recovery.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <!-- Modal: Interactive Regex Tester -->
    <div class="modal fade" id="regexTesterModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content modal-content-saas">
                <div class="modal-header modal-header-saas">
                    <h5 class="modal-title fw-bold"><i class="bi bi-regex text-info me-2"></i> Live Regex &amp; Pattern Tester</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label-custom">Pattern or Regex</label>
                        <input type="text" class="form-control form-control-saas font-monospace" id="testerPattern" placeholder="e.g. Connection pool exhausted" oninput="runRegexTest()">
                    </div>
                    <div class="mb-3">
                        <label class="form-label-custom">Sample Log Line</label>
                        <textarea class="form-control form-control-saas font-monospace small" id="testerLog" rows="3" placeholder="Paste sample log message here to test match..." oninput="runRegexTest()"></textarea>
                    </div>
                    <div id="testerResult" class="p-3 rounded small font-monospace d-flex align-items-center gap-2" style="background: rgba(255, 255, 255, 0.04); border: 1px solid var(--border-color);">
                        <i class="bi bi-info-circle text-muted"></i>
                        <span class="text-muted">Enter a pattern and sample log to test match status.</span>
                    </div>
                </div>
                <div class="modal-footer modal-footer-saas">
                    <button type="button" class="btn btn-saas-outline" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-saas-primary" onclick="useTestedPattern()">
                        <i class="bi bi-arrow-right-circle me-1"></i> Use in New Rule
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal: Add New Healing Rule -->
    <div class="modal fade" id="addRuleModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content modal-content-saas">
                <div class="modal-header modal-header-saas">
                    <h5 class="modal-title fw-bold"><i class="bi bi-magic text-primary me-2"></i> Configure Auto-Healing Rule</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="addRuleForm">
                    <div class="modal-body p-4">
                        
                        <!-- Quick Templates -->
                        <div class="mb-4 p-3 rounded" style="background: rgba(99, 102, 241, 0.08); border: 1px solid rgba(99, 102, 241, 0.2);">
                            <label class="form-label-custom mb-1 text-primary">Load Ready-Made Recipe Template</label>
                            <div class="d-flex flex-wrap gap-2 mt-2">
                                <button type="button" class="btn btn-sm btn-saas-outline" onclick="applyRuleRecipe('db')">
                                    <i class="bi bi-database me-1"></i> DB Pool Recovery
                                </button>
                                <button type="button" class="btn btn-sm btn-saas-outline" onclick="applyRuleRecipe('cache')">
                                    <i class="bi bi-hdd-network me-1"></i> Redis OOM Flush
                                </button>
                                <button type="button" class="btn btn-sm btn-saas-outline" onclick="applyRuleRecipe('restart')">
                                    <i class="bi bi-arrow-repeat me-1"></i> JVM Memory Restart
                                </button>
                            </div>
                        </div>

                        <!-- Domain Selection -->
                        <div class="mb-3">
                            <label class="form-label-custom" for="ruleDomainId">Target Microservice Domain <span class="text-danger">*</span></label>
                            <select class="form-select form-control-saas" id="ruleDomainId" required>
                                <option value="" disabled selected>Select domain...</option>
                                <c:forEach var="dom" items="${domains}">
                                    <option value="${dom.id}"><c:out value="${dom.domainName}" /></option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Error Pattern String / Regex -->
                        <div class="mb-3">
                            <label class="form-label-custom" for="ruleErrorPattern">Log Error Pattern String / Substring <span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-saas font-monospace" id="ruleErrorPattern" placeholder="e.g. Connection pool exhausted or OutOfMemoryError" required>
                            <span class="text-muted small d-block mt-1">When an ingested log message or stack trace contains this string, the rule triggers.</span>
                        </div>

                        <div class="row g-3 mb-3">
                            <!-- Action Type -->
                            <div class="col-md-6">
                                <label class="form-label-custom" for="ruleActionType">Recovery Action Type <span class="text-danger">*</span></label>
                                <select class="form-select form-control-saas" id="ruleActionType" required>
                                    <option value="RESTART_SERVICE">RESTART_SERVICE</option>
                                    <option value="CLEAR_CACHE">CLEAR_CACHE</option>
                                    <option value="RESET_CONNECTION">RESET_CONNECTION</option>
                                    <option value="CUSTOM_SCRIPT">CUSTOM_SCRIPT</option>
                                </select>
                            </div>

                            <!-- Target Script -->
                            <div class="col-md-6">
                                <label class="form-label-custom" for="ruleTargetScript">Target Script / Command <span class="text-danger">*</span></label>
                                <input type="text" class="form-control form-control-saas font-monospace" id="ruleTargetScript" placeholder="scripts/restart-app.sh" required>
                                <span class="text-muted small d-block mt-1">Secured by <code>CommandSanitizer</code> guardrail.</span>
                            </div>
                        </div>

                    </div>
                    <div class="modal-footer modal-footer-saas">
                        <button type="button" class="btn btn-saas-outline" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-saas-primary">
                            <i class="bi bi-check-circle me-1"></i> Save Healing Rule
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
        function runRegexTest() {
            const pattern = document.getElementById('testerPattern').value.trim();
            const logText = document.getElementById('testerLog').value;
            const resEl = document.getElementById('testerResult');

            if (!pattern || !logText) {
                resEl.className = 'p-3 rounded small font-monospace d-flex align-items-center gap-2 text-muted';
                resEl.style.background = 'rgba(255, 255, 255, 0.04)';
                resEl.innerHTML = '<i class="bi bi-info-circle"></i> Enter both a pattern and log line to test.';
                return;
            }

            try {
                const regex = new RegExp(pattern, 'i');
                const matched = regex.test(logText) || logText.includes(pattern);
                if (matched) {
                    resEl.className = 'p-3 rounded small font-monospace d-flex align-items-center gap-2 text-success';
                    resEl.style.background = 'rgba(16, 185, 129, 0.15)';
                    resEl.innerHTML = '<i class="bi bi-check-circle-fill"></i> <strong>MATCH SUCCESSFUL:</strong> Rule would trigger autonomous recovery!';
                } else {
                    resEl.className = 'p-3 rounded small font-monospace d-flex align-items-center gap-2 text-danger';
                    resEl.style.background = 'rgba(239, 68, 68, 0.15)';
                    resEl.innerHTML = '<i class="bi bi-x-circle-fill"></i> <strong>NO MATCH:</strong> Pattern was not found in sample log message.';
                }
            } catch (e) {
                const matched = logText.includes(pattern);
                if (matched) {
                    resEl.className = 'p-3 rounded small font-monospace d-flex align-items-center gap-2 text-success';
                    resEl.style.background = 'rgba(16, 185, 129, 0.15)';
                    resEl.innerHTML = '<i class="bi bi-check-circle-fill"></i> <strong>SUBSTRING MATCHED:</strong> (Treated as plain literal substring).';
                } else {
                    resEl.className = 'p-3 rounded small font-monospace d-flex align-items-center gap-2 text-warning';
                    resEl.style.background = 'rgba(245, 158, 11, 0.15)';
                    resEl.innerHTML = '<i class="bi bi-exclamation-triangle-fill"></i> Invalid regex: ' + e.message;
                }
            }
        }

        function useTestedPattern() {
            const pattern = document.getElementById('testerPattern').value.trim();
            if (pattern) {
                document.getElementById('ruleErrorPattern').value = pattern;
                const testerModal = bootstrap.Modal.getInstance(document.getElementById('regexTesterModal'));
                if (testerModal) testerModal.hide();
                const addModal = new bootstrap.Modal(document.getElementById('addRuleModal'));
                addModal.show();
            }
        }

        function applyRuleRecipe(type) {
            const patternEl = document.getElementById('ruleErrorPattern');
            const actionEl = document.getElementById('ruleActionType');
            const scriptEl = document.getElementById('ruleTargetScript');

            if (type === 'db') {
                patternEl.value = 'Connection pool exhausted';
                actionEl.value = 'RESTART_SERVICE';
                scriptEl.value = 'scripts/restart_hikari_pool.sh';
            } else if (type === 'cache') {
                patternEl.value = 'OOM command not allowed';
                actionEl.value = 'CLEAR_CACHE';
                scriptEl.value = 'redis-cli flushall';
            } else if (type === 'restart') {
                patternEl.value = 'OutOfMemoryError';
                actionEl.value = 'RESTART_SERVICE';
                scriptEl.value = 'scripts/restart_jvm.sh';
            }
            showToast('Applied ' + type.toUpperCase() + ' rule recipe', 'info');
        }

        document.addEventListener('DOMContentLoaded', () => {
            // Interactive Rule Toggle Switches
            document.querySelectorAll('.rule-toggle-switch').forEach(switchInput => {
                switchInput.addEventListener('change', (e) => {
                    const ruleId = e.target.getAttribute('data-rule-id');
                    const isActive = e.target.checked;

                    fetch('rules/toggle', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: 'ruleId=' + encodeURIComponent(ruleId) + '&isActive=' + encodeURIComponent(isActive)
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            showToast(data.message, 'success');
                            const label = e.target.nextElementSibling;
                            if (label) {
                                label.innerText = isActive ? 'Active' : 'Disabled';
                                label.className = 'small ' + (isActive ? 'text-success fw-semibold' : 'text-muted');
                            }
                        } else {
                            e.target.checked = !isActive;
                            showToast(data.message, 'danger');
                        }
                    })
                    .catch(err => {
                        e.target.checked = !isActive;
                        showToast('Error toggling rule: ' + err, 'danger');
                    });
                });
            });

            // Add Rule Form Handler
            const addRuleForm = document.getElementById('addRuleForm');
            if (addRuleForm) {
                addRuleForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    const domainId = document.getElementById('ruleDomainId').value;
                    const errorPattern = document.getElementById('ruleErrorPattern').value.trim();
                    const actionType = document.getElementById('ruleActionType').value;
                    const targetScript = document.getElementById('ruleTargetScript').value.trim();

                    fetch('rules/add', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: 'domainId=' + encodeURIComponent(domainId) + '&errorPattern=' + encodeURIComponent(errorPattern) + '&actionType=' + encodeURIComponent(actionType) + '&targetScript=' + encodeURIComponent(targetScript)
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            showToast(data.message, 'success');
                            const modal = bootstrap.Modal.getInstance(document.getElementById('addRuleModal'));
                            if (modal) modal.hide();
                            setTimeout(() => window.location.reload(), 1000);
                        } else {
                            showToast(data.message, 'danger');
                        }
                    });
                });
            }
        });

        function deleteRule(ruleId, errorPattern) {
            if (!confirm('Are you sure you want to delete the healing rule for pattern "' + errorPattern + '"?')) return;

            fetch('rules/delete', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'ruleId=' + encodeURIComponent(ruleId)
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    showToast(data.message, 'success');
                    setTimeout(() => window.location.reload(), 1000);
                } else {
                    showToast(data.message, 'danger');
                }
            });
        }
    </script>
</body>
</html>