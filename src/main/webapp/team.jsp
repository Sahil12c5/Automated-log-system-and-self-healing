<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Team Management | AutoHeal Engine</title>
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
                <h1 class="h2"><i class="bi bi-people text-primary me-2"></i> Team Management</h1>
                <button class="btn btn-primary shadow-sm" data-bs-toggle="modal" data-bs-target="#teamModal" onclick="resetForm()">
                    <i class="bi bi-person-plus me-1"></i> Invite Member
                </button>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <div class="card shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Full Name</th>
                                    <th>Email</th>
                                    <th>Role</th>
                                    <th>Joined</th>
                                    <th class="text-end">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="member" items="${teamMembers}">
                                    <tr>
                                        <td class="fw-bold">${member.fullName}</td>
                                        <td class="text-muted">${member.email}</td>
                                        <td><span class="badge role-badge role-${member.role}">${member.role}</span></td>
                                        <td>${member.createdAt}</td>
                                        <td class="text-end">
                                            <button class="btn btn-sm btn-outline-secondary me-1" onclick="editUser(${member.id}, '${member.email}', '${member.fullName}', '${member.role}')">
                                                <i class="bi bi-pencil"></i>
                                            </button>
                                            <c:if test="${member.id != sessionScope.user.id}">
                                                <button class="btn btn-sm btn-outline-danger" onclick="deleteUser(${member.id})">
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
        </div>

<!-- Add/Edit Member Modal -->
<div class="modal fade" id="teamModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form id="teamForm" onsubmit="saveUser(event)">
                <div class="modal-header">
                    <h5 class="modal-title" id="teamModalLabel">Invite Team Member</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="userId" name="userId">
                    
                    <div class="mb-3">
                        <label class="form-label">Email Address</label>
                        <input type="email" class="form-control" id="email" name="email" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Full Name</label>
                        <input type="text" class="form-control" id="fullName" name="fullName" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Role</label>
                        <select class="form-select" id="role" name="role" required>
                            <option value="DEVELOPER">Developer (View only)</option>
                            <option value="SENIOR_DEVELOPER">Senior Developer (Can Approve AI fixes)</option>
                            <option value="MANAGER">Manager (Team Admin)</option>
                            <option value="OWNER">Owner (Full Access)</option>
                        </select>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label text-muted"><i class="bi bi-globe me-1"></i> Domain Access Scopes</label>
                        <div class="border rounded p-3 bg-light" style="max-height: 150px; overflow-y: auto;">
                            <c:forEach var="domain" items="${domains}">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="domainIds[]" value="${domain.id}" id="domain-${domain.id}">
                                    <label class="form-check-label" for="domain-${domain.id}">
                                        ${domain.domainName}
                                    </label>
                                </div>
                            </c:forEach>
                        </div>
                        <small class="text-muted">Select domains this user can view and manage.</small>
                    </div>
                </div>
                <div class="modal-footer border-top-0">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Member</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function resetForm() {
        document.getElementById('teamForm').reset();
        document.getElementById('userId').value = '';
        document.getElementById('email').readOnly = false;
        document.getElementById('fullName').readOnly = false;
        document.getElementById('teamModalLabel').innerText = 'Invite Team Member';
    }

    function editUser(id, email, name, role) {
        resetForm();
        document.getElementById('userId').value = id;
        document.getElementById('email').value = email;
        document.getElementById('email').readOnly = true;
        document.getElementById('fullName').value = name;
        document.getElementById('fullName').readOnly = true;
        document.getElementById('role').value = role;
        document.getElementById('teamModalLabel').innerText = 'Update Team Member';
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
                location.reload();
            } else {
                alert(data.message);
            }
        });
    }

    function deleteUser(id) {
        if(confirm("Are you sure you want to remove this user?")) {
            fetch('${pageContext.request.contextPath}/api/v1/team/member/delete', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'userId=' + encodeURIComponent(id)
            })
            .then(res => res.json())
            .then(data => {
                if(data.success) {
                    location.reload();
                } else {
                    alert(data.message);
                }
            });
        }
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
