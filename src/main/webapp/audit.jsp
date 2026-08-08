<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit Trail | AutoHeal Engine</title>
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
                <h1 class="h2"><i class="bi bi-clock-history text-primary me-2"></i> Organization Audit Trail</h1>
                <p class="text-muted">Immutable log of security and system events.</p>
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
                                    <th>Timestamp (UTC)</th>
                                    <th>Actor</th>
                                    <th>Action Type</th>
                                    <th>Details</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="audit" items="${auditLogs}">
                                    <tr>
                                        <td class="text-nowrap text-muted small">${audit.createdAt}</td>
                                        <td class="fw-bold">
                                            <i class="bi bi-person-badge text-secondary me-1"></i>
                                            <c:choose>
                                                <c:when test="${not empty audit.userId}">
                                                    ${userNames[audit.userId] != null ? userNames[audit.userId] : 'System/Unknown'}
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-secondary fst-italic">System Daemon</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge bg-secondary action-badge">${audit.action}</span>
                                        </td>
                                        <td class="text-muted small">${audit.details}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <c:if test="${empty auditLogs}">
                        <div class="p-4 text-center text-muted">
                            No audit logs available for this organization yet.
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
