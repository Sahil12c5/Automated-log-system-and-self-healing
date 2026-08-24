<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Authentication Vault | AutoHeal Engine</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/theme.css" rel="stylesheet">
</head>
<body>

    <!-- Navbar -->
    <nav class="navbar navbar-saas">
        <div class="container-fluid px-4">
            <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/">
                <i class="bi bi-cpu-fill text-primary fs-3"></i>
                <span class="brand-gradient">AutoHeal Engine</span>
            </a>
            <div>
                <span class="text-muted me-2 font-size-sm">Need an organization?</span>
                <a href="${pageContext.request.contextPath}/signup" class="btn btn-saas-primary btn-sm">Register Tenant</a>
            </div>
        </div>
    </nav>

    <!-- Login Auth Card -->
    <div class="auth-wrapper">
        <div class="auth-card">
            
            <c:choose>
                <c:when test="${require2FA}">
                    <!-- 2FA OTP Verification Form -->
                    <div class="auth-tab-content">
                        <div class="text-center mb-4">
                            <h4 class="text-dark fw-bold">Two-Factor Authentication</h4>
                            <p class="text-muted small">Please enter the 4-digit OTP sent to <strong><c:out value="${requestScope['2faEmail']}"/></strong></p>
                        </div>
                        <form action="${pageContext.request.contextPath}/login" method="POST" class="needs-validation" novalidate>
                            <input type="hidden" name="authType" value="2fa_verify">
                            
                            <div class="mb-4">
                                <label class="form-label-custom" for="otpCode2FA">4-Digit Security Code</label>
                                <input type="text" class="form-control form-control-saas font-monospace text-center fs-4 letter-spacing-2" id="otpCode2FA" name="otpCode" maxlength="4" placeholder="••••" required>
                                <div class="invalid-feedback">OTP code is required.</div>
                            </div>

                            <button type="submit" class="btn btn-saas-primary w-100 py-2.5">
                                <i class="bi bi-shield-check me-1"></i> Verify &amp; Sign In
                            </button>
                        </form>
                        <div class="text-center mt-3">
                            <a href="${pageContext.request.contextPath}/login" class="text-muted small text-decoration-none">Cancel &amp; Back to Login</a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Dual Tab Switcher -->
                    <div class="auth-nav-tabs">
                        <button type="button" class="auth-tab-btn active" data-tab="tabPasswordLogin">
                            <i class="bi bi-shield-lock me-1"></i> Owner Password
                        </button>
                        <button type="button" class="auth-tab-btn" data-tab="tabOtpLogin">
                            <i class="bi bi-phone-vibrate me-1"></i> Employee OTP
                        </button>
                    </div>

            <!-- Error / Success Alert Banners -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger bg-danger bg-opacity-10 border-danger text-danger rounded-3 d-flex align-items-center gap-2 mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                    <div><c:out value="${error}" /></div>
                </div>
            </c:if>

            <c:if test="${param.logout eq 'success'}">
                <div class="alert alert-success bg-success bg-opacity-10 border-success text-success rounded-3 d-flex align-items-center gap-2 mb-4" role="alert">
                    <i class="bi bi-check-circle-fill"></i>
                    <div>You have been logged out securely.</div>
                </div>
            </c:if>

            <!-- TAB 1: Owner Password Login -->
            <div id="tabPasswordLogin" class="auth-tab-content">
                <div class="text-center mb-4">
                    <h4 class="text-dark fw-bold">Sign In with Credentials</h4>
                    <p class="text-muted small">Enter your email &amp; master password to access dashboard</p>
                </div>

                <form action="${pageContext.request.contextPath}/login" method="POST" class="needs-validation" novalidate>
                    <input type="hidden" name="authType" value="password">
                    
                    <div class="mb-3">
                        <label class="form-label-custom" for="loginEmail">Email Address</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light border-secondary text-muted"><i class="bi bi-envelope"></i></span>
                            <input type="email" class="form-control form-control-saas" id="loginEmail" name="email" placeholder="owner@acme.com" required>
                            <div class="invalid-feedback">Please enter a valid email address.</div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <label class="form-label-custom" for="loginPassword">Password</label>
                            <a href="#" class="text-primary small text-decoration-none" data-bs-toggle="modal" data-bs-target="#forgotPasswordModal">Forgot Password?</a>
                        </div>
                        <div class="input-group">
                            <span class="input-group-text bg-light border-secondary text-muted"><i class="bi bi-key"></i></span>
                            <input type="password" class="form-control form-control-saas" id="loginPassword" name="password" placeholder="â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢" required>
                            <div class="invalid-feedback">Password is required.</div>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-saas-primary w-100 py-2.5">
                        <i class="bi bi-box-arrow-in-right me-1"></i> Sign In to Account
                    </button>
                </form>
            </div>

            <!-- TAB 2: Employee Passwordless Login (OTP) -->
            <div id="tabOtpLogin" class="auth-tab-content d-none">
                <div class="text-center mb-4">
                    <h4 class="text-dark fw-bold">Passwordless Employee Login</h4>
                    <p class="text-muted small">Receive a 4-digit OTP code on your registered email</p>
                </div>



                <div class="mb-3">
                    <label class="form-label-custom" for="empEmail">Enterprise Email</label>
                    <div class="input-group">
                        <input type="email" class="form-control form-control-saas" id="empEmail" placeholder="developer@company.com">
                        <button type="button" class="btn btn-saas-outline" id="btnSendEmpOtp">Send OTP</button>
                    </div>
                </div>

                <div id="empOtpVerifySection" class="d-none">
                    <div class="mb-4">
                        <label class="form-label-custom" for="empOtpCode">4-Digit Security Code</label>
                        <input type="text" class="form-control form-control-saas font-monospace text-center fs-4 letter-spacing-2" id="empOtpCode" maxlength="4" placeholder="â€¢â€¢â€¢â€¢">
                    </div>

                    <button type="button" class="btn btn-saas-primary w-100 py-2.5" id="btnVerifyEmpOtp">
                        <i class="bi bi-shield-check me-1"></i> Verify &amp; Sign In
                    </button>
                </div>
            </div>
                </c:otherwise>
            </c:choose>

        </div>
    </div>

    <!-- Forgot Password Modal -->
    <div class="modal fade" id="forgotPasswordModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content modal-content-saas">
                <div class="modal-header modal-header-saas">
                    <h5 class="modal-title text-dark fw-bold"><i class="bi bi-arrow-counterclockwise text-primary me-2"></i> Reset Password</h5>
                    <button type="button" class="btn-close btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <p class="text-muted small mb-3">Send a 4-digit verification code to your email to configure a new password.</p>
                    
                    <div class="mb-3">
                        <label class="form-label-custom" for="resetEmail">Email Address</label>
                        <div class="input-group">
                            <input type="email" class="form-control form-control-saas" id="resetEmail" placeholder="user@company.com">
                            <button type="button" class="btn btn-saas-outline" id="btnSendResetOtp">Request OTP</button>
                        </div>
                    </div>



                    <div id="resetFormFields" class="d-none">
                        <div class="mb-3">
                            <label class="form-label-custom" for="resetOtpCode">OTP Code</label>
                            <input type="text" class="form-control form-control-saas" id="resetOtpCode" placeholder="Enter 4-digit OTP" maxlength="4">
                        </div>
                        <div class="mb-3">
                            <label class="form-label-custom" for="resetNewPassword">New Password</label>
                            <input type="password" class="form-control form-control-saas" id="resetNewPassword" placeholder="Enter new password">
                        </div>
                    </div>
                </div>
                <div class="modal-footer modal-footer-saas">
                    <button type="button" class="btn btn-saas-outline" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-saas-primary" id="btnSubmitResetPassword" disabled>Update Password</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Toast Notifications Container -->
    <div id="toastContainer"></div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
    
    <script>
        // Modal reset password script helper
        document.addEventListener('DOMContentLoaded', () => {
            const btnSendReset = document.getElementById('btnSendResetOtp');
            const btnSubmitReset = document.getElementById('btnSubmitResetPassword');

            if (btnSendReset) {
                btnSendReset.addEventListener('click', () => {
                    const email = document.getElementById('resetEmail').value.trim();
                    if (!email) {
                        showToast('Enter your email first.', 'danger');
                        return;
                    }

                    fetch('api/otp/send', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: 'email=' + encodeURIComponent(email)
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            showToast("Please check your email inbox for the OTP code.", 'success');
                            document.getElementById('resetFormFields').classList.remove('d-none');
                            btnSubmitReset.disabled = false;
                        } else {
                            showToast(data.message, 'danger');
                        }
                    });
                });
            }

            if (btnSubmitReset) {
                btnSubmitReset.addEventListener('click', () => {
                    const email = document.getElementById('resetEmail').value.trim();
                    const otpCode = document.getElementById('resetOtpCode').value.trim();
                    const newPassword = document.getElementById('resetNewPassword').value;

                    fetch('api/otp/reset-password', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: 'email=' + encodeURIComponent(email) + '&otpCode=' + encodeURIComponent(otpCode) + '&newPassword=' + encodeURIComponent(newPassword)
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            showToast(data.message, 'success');
                            const modal = bootstrap.Modal.getInstance(document.getElementById('forgotPasswordModal'));
                            if (modal) modal.hide();
                        } else {
                            showToast(data.message, 'danger');
                        }
                    });
                });
            }
        });
    </script>
</body>
</html>

