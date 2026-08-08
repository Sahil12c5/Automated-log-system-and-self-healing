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
                    <a href="${pageContext.request.contextPath}/logs" class="btn btn-sm btn-saas-outline border-0">
                        <i class="bi bi-terminal-fill me-1"></i> Live Logs
                    </a>
                    <a href="${pageContext.request.contextPath}/rules" class="btn btn-sm btn-saas-primary">
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
                <div class="d-none d-md-flex align-items-center gap-2 px-3 py-1.5 rounded-pill bg-light border border-secondary border-opacity-30">
                    <i class="bi bi-buildings text-primary"></i>
                    <span class="text-dark fw-semibold small"><c:out value="${sessionScope.orgName}" default="Organization" /></span>
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
        
        <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-4">
            <div>
                <h3 class="text-dark fw-bold mb-1"><i class="bi bi-magic text-primary me-2"></i> Deterministic Auto-Healing Rules</h3>
                <p class="text-muted small mb-0">Configure automated recovery procedures when ingested error patterns are matched</p>
            </div>
            <button type="button" class="btn btn-saas-primary d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#addRuleModal">
                <i class="bi bi-plus-lg"></i> Create Healing Rule
            </button>
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
                                            <span class="badge bg-light border border-secondary text-info">
                                                <i class="bi bi-globe me-1"></i> <c:out value="${rule.domainName}" />
                                            </span>
                                        </td>
                                        <td>
                                            <code class="text-warning bg-light bg-opacity-40 px-2 py-1 rounded border border-secondary border-opacity-20 font-monospace">
                                                <c:out value="${rule.errorPattern}" />
                                            </code>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${rule.actionType eq 'RESTART_SERVICE'}">
                                                    <span class="badge bg-danger bg-opacity-20 text-danger border border-danger border-opacity-30">
                                                        <i class="bi bi-arrow-repeat me-1"></i> RESTART SERVICE
                                                    </span>
                                                </c:when>
                                                <c:when test="${rule.actionType eq 'CLEAR_CACHE'}">
                                                    <span class="badge bg-warning bg-opacity-20 text-warning border border-warning border-opacity-30">
                                                        <i class="bi bi-trash2 me-1"></i> CLEAR CACHE
                                                    </span>
                                                </c:when>
                                                <c:when test="${rule.actionType eq 'RESET_CONNECTION'}">
                                                    <span class="badge bg-info bg-opacity-20 text-info border border-info border-opacity-30">
                                                        <i class="bi bi-diagram-3 me-1"></i> RESET CONNECTION
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-primary bg-opacity-20 text-primary border border-primary border-opacity-30">
                                                        <i class="bi bi-code-slash me-1"></i> CUSTOM SCRIPT
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <code class="text-dark bg-light bg-opacity-50 px-2 py-1 rounded font-monospace small">
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

    <!-- Modal: Add New Healing Rule -->
    <div class="modal fade" id="addRuleModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content modal-content-saas">
                <div class="modal-header modal-header-saas">
                    <h5 class="modal-title text-dark fw-bold"><i class="bi bi-magic text-primary me-2"></i> Configure Auto-Healing Rule</h5>
                    <button type="button" class="btn-close btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="addRuleForm">
                    <div class="modal-body p-4">
                        
                        <!-- Domain Selection -->
                        <div class="mb-3">
                            <label class="form-label-custom" for="ruleDomainId">Target Microservice Domain</label>
                            <select class="form-select form-control-saas" id="ruleDomainId" required>
                                <option value="" disabled selected>Select domain...</option>
                                <c:forEach var="dom" items="${domains}">
                                    <option value="${dom.id}"><c:out value="${dom.domainName}" /></option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Error Pattern String / Regex -->
                        <div class="mb-3">
                            <label class="form-label-custom" for="ruleErrorPattern">Log Error Pattern String / Substring</label>
                            <input type="text" class="form-control form-control-saas font-monospace" id="ruleErrorPattern" placeholder="e.g. Connection pool exhausted or OutOfMemoryError" required>
                            <span class="text-muted small d-block mt-1">When an ingested log message or stack trace contains this string, the rule triggers.</span>
                        </div>

                        <div class="row g-3 mb-3">
                            <!-- Action Type -->
                            <div class="col-md-6">
                                <label class="form-label-custom" for="ruleActionType">Recovery Action Type</label>
                                <select class="form-select form-control-saas" id="ruleActionType" required>
                                    <option value="RESTART_SERVICE">RESTART_SERVICE</option>
                                    <option value="CLEAR_CACHE">CLEAR_CACHE</option>
                                    <option value="RESET_CONNECTION">RESET_CONNECTION</option>
                                    <option value="CUSTOM_SCRIPT">CUSTOM_SCRIPT</option>
                                </select>
                            </div>

                            <!-- Target Script -->
                            <div class="col-md-6">
                                <label class="form-label-custom" for="ruleTargetScript">Target Script / Command</label>
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
                            e.target.checked = !isActive; // Revert switch state
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
