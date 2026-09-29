<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Team Management | AutoHeal Engine</title>
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
                            <li><a class="dropdown-item active" href="${pageContext.request.contextPath}/team"><i class="bi bi-people text-info"></i> Team Management</a></li>
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
        <div class="d-flex justify-content-between flex-wrap align-items-center pb-3 mb-4 border-bottom border-secondary border-opacity-20 gap-3">
            <div>
                <h2 class="fw-bold mb-1"><i class="bi bi-people text-info me-2"></i> Tenant Team Management</h2>
                <p class="text-muted small mb-0">Manage developer memberships, access scopes, and granular role permissions</p>
            </div>
            <button class="btn btn-saas-primary shadow-sm" data-bs-toggle="modal" data-bs-target="#teamModal" onclick="resetForm()">
                <i class="bi bi-person-plus me-1"></i> Invite Member
            </button>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger mb-4"><i class="bi bi-exclamation-triangle me-2"></i> ${error}</div>
        </c:if>

        <!-- Search Bar -->
        <div class="saas-card p-3 mb-4">
            <div class="row g-2 align-items-center">
                <div class="col-md-4">
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control form-control-saas" id="tableSearchInput" placeholder="Filter team members by name, email, or role...">
                    </div>
                </div>
                <div class="col-md-8 text-md-end">
                    <span class="badge role-badge role-OWNER me-1">Owner: Full Control</span>
                    <span class="badge role-badge role-MANAGER me-1">Manager: Team Admin</span>
                    <span class="badge role-badge role-SENIOR_DEV me-1">Senior Dev: AI Approver</span>
                    <span class="badge role-badge role-DEV">Developer: View</span>
                </div>
            </div>
        </div>

        <!-- Members Table -->
        <div class="saas-card">
            <div class="table-responsive">
                <table class="table table-saas">
                    <thead>
                        <tr>
                            <th>Member</th>
                            <th>Email Address</th>
                            <th>Role Scope</th>
                            <th>Joined Date</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="member" items="${teamMembers}">
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width:36px; height:36px; background: rgba(99, 102, 241, 0.15); color: var(--primary-color);">
                                            ${member.fullName.substring(0, 1)}
                                        </div>
                                        <div>
                                            <span class="fw-bold d-block">${member.fullName}</span>
                                            <c:if test="${member.id == sessionScope.user.id}">
                                                <span class="badge bg-success bg-opacity-15 text-success small" style="font-size: 0.68rem;">(You)</span>
                                            </c:if>
                                        </div>
                                    </div>
                                </td>
                                <td class="text-muted font-monospace small">${member.email}</td>
                                <td>
                                    <span class="badge role-badge role-${member.role}">${member.role}</span>
                                </td>
                                <td class="text-muted small">${member.createdAt}</td>
                                <td class="text-end">
                                    <button class="btn btn-sm btn-saas-outline py-1 px-2.5 me-1" onclick="editUser(${member.id}, '${member.email}', '${member.fullName}', '${member.role}')" title="Edit Member">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                    <c:if test="${member.id != sessionScope.user.id}">
                                        <button class="btn btn-sm btn-outline-danger py-1 px-2.5" onclick="deleteUser(${member.id})" title="Remove Member">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Add/Edit Member Modal -->
    <div class="modal fade" id="teamModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content modal-content-saas">
                <form id="teamForm" onsubmit="saveUser(event)">
                    <div class="modal-header modal-header-saas">
                        <h5 class="modal-title fw-bold" id="teamModalLabel">
                            <i class="bi bi-person-plus text-primary me-2"></i> Invite Team Member
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <input type="hidden" id="userId" name="userId">
                        
                        <div class="mb-3">
                            <label class="form-label-custom" for="email">Work Email Address <span class="text-danger">*</span></label>
                            <input type="email" class="form-control form-control-saas" id="email" name="email" placeholder="dev@company.com" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label-custom" for="fullName">Full Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-saas" id="fullName" name="fullName" placeholder="Alex Morgan" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label-custom" for="role">Role Permission Level</label>
                            <select class="form-select form-control-saas" id="role" name="role" required>
                                <option value="DEVELOPER">Developer (View logs and telemetry)</option>
                                <option value="SENIOR_DEVELOPER">Senior Developer (Can authorize AI fixes & rules)</option>
                                <option value="MANAGER">Manager (Team admin & domain configuration)</option>
                                <option value="OWNER">Owner (Full tenant vault ownership)</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label-custom"><i class="bi bi-globe me-1"></i> Domain Access Scopes</label>
                            <div class="rounded p-3" style="background: rgba(255, 255, 255, 0.03); border: 1px solid var(--border-color); max-height: 140px; overflow-y: auto;">
                                <c:forEach var="domain" items="${domains}">
                                    <div class="form-check mb-1">
                                        <input class="form-check-input" type="checkbox" name="domainIds[]" value="${domain.id}" id="domain-${domain.id}">
                                        <label class="form-check-label small" for="domain-${domain.id}">
                                            ${domain.domainName}
                                        </label>
                                    </div>
                                </c:forEach>
                            </div>
                            <span class="text-muted small d-block mt-1">Select specific microservice domains this member can access.</span>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-saas">
                        <button type="button" class="btn btn-saas-outline" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-saas-primary">
                            <i class="bi bi-check-circle me-1"></i> Save Member
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Toast Notifications Container -->
    <div id="toastContainer"></div>

    <script>
        function resetForm() {
            document.getElementById('teamForm').reset();
            document.getElementById('userId').value = '';
            document.getElementById('email').readOnly = false;
            document.getElementById('fullName').readOnly = false;
            document.getElementById('teamModalLabel').innerHTML = '<i class="bi bi-person-plus text-primary me-2"></i> Invite Team Member';
        }

        function editUser(id, email, name, role) {
            resetForm();
            document.getElementById('userId').value = id;
            document.getElementById('email').value = email;
            document.getElementById('email').readOnly = true;
            document.getElementById('fullName').value = name;
            document.getElementById('fullName').readOnly = true;
            document.getElementById('role').value = role;
            document.getElementById('teamModalLabel').innerHTML = '<i class="bi bi-pencil-square text-primary me-2"></i> Update Team Member';
            var modal = new bootstrap.Modal(document.getElementById('teamModal'));
            modal.show();
        }

        function saveUser(event) {
            event.preventDefault();
            const formData = new FormData(document.getElementById('teamForm'));
            const urlSearchParams = new URLSearchParams();
            
            for (const pair of formData.entries()) {
                urlSearchParams.append(pair[0], pair[1]);
            }

            fetch('${pageContext.request.contextPath}/team', {
                method: 'POST',
                body: urlSearchParams,
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            })
            .then(res => res.json())
            .then(data => {
                if(data.success) {
                    showToast(data.message, 'success');
                    const modal = bootstrap.Modal.getInstance(document.getElementById('teamModal'));
                    if (modal) modal.hide();
                    setTimeout(() => location.reload(), 1000);
                } else {
                    showToast(data.message, 'danger');
                }
            })
            .catch(err => {
                showToast("Save error: " + err, 'danger');
            });
        }

        function deleteUser(id) {
            if(confirm("Are you sure you want to remove this user from the organization?")) {
                fetch('${pageContext.request.contextPath}/api/v1/team/member/delete', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'userId=' + encodeURIComponent(id)
                })
                .then(res => res.json())
                .then(data => {
                    if(data.success) {
                        showToast(data.message, 'success');
                        setTimeout(() => location.reload(), 1000);
                    } else {
                        showToast(data.message, 'danger');
                    }
                })
                .catch(err => {
                    showToast("Error removing member: " + err, 'danger');
                });
            }
        }
    </script>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>