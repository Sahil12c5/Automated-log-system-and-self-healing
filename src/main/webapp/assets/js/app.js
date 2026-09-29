/* ============================================================================
   AutoHeal Engine - Unified Client-Side Application Logic & Interactivity
   ============================================================================ */

document.addEventListener('DOMContentLoaded', () => {
    initTheme();
    initPasswordStrengthMeter();
    initPasswordToggles();
    initCopyButtons();
    initApiKeyMaskToggles();
    initTabSwitches();
    initOTPHandlers();
    initDomainForm();
    initFormValidation();
    initQuickSearchFilters();
});

/**
 * Theme Management (Dark / Light Mode with LocalStorage persistence)
 */
function initTheme() {
    const savedTheme = localStorage.getItem('autoheal_theme') || 'dark';
    applyTheme(savedTheme);

    document.querySelectorAll('.btn-theme-toggle').forEach(btn => {
        btn.addEventListener('click', () => {
            const currentTheme = document.documentElement.getAttribute('data-theme') || 'dark';
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
            applyTheme(newTheme);
            localStorage.setItem('autoheal_theme', newTheme);
            showToast(`Switched to ${newTheme === 'dark' ? 'Dark' : 'Light'} Mode`, 'info');
        });
    });
}

function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    document.querySelectorAll('.btn-theme-toggle').forEach(btn => {
        if (theme === 'dark') {
            btn.innerHTML = '<i class="bi bi-sun-fill text-warning"></i>';
            btn.setAttribute('title', 'Switch to Light Mode');
        } else {
            btn.innerHTML = '<i class="bi bi-moon-stars-fill text-primary"></i>';
            btn.setAttribute('title', 'Switch to Dark Mode');
        }
    });
}

/**
 * Toast Notification System
 */
function showToast(message, type = 'info') {
    let container = document.getElementById('toastContainer');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toastContainer';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast-custom toast-${type}`;

    let iconClass = 'bi-info-circle-fill text-info';
    if (type === 'success') iconClass = 'bi-check-circle-fill text-success';
    if (type === 'danger' || type === 'error') iconClass = 'bi-exclamation-triangle-fill text-danger';
    if (type === 'warning') iconClass = 'bi-exclamation-circle-fill text-warning';

    toast.innerHTML = `
        <i class="bi ${iconClass} fs-5"></i>
        <div class="flex-grow-1 font-size-sm">${message}</div>
        <button type="button" class="btn-close ${document.documentElement.getAttribute('data-theme') === 'dark' ? 'btn-close-white' : ''} ms-2" onclick="this.parentElement.remove()"></button>
    `;

    container.appendChild(toast);

    setTimeout(() => {
        if (toast.parentElement) {
            toast.style.opacity = '0';
            toast.style.transform = 'translateX(100%)';
            toast.style.transition = 'all 0.35s ease';
            setTimeout(() => toast.remove(), 350);
        }
    }, 4500);
}

/**
 * Password Visibility Toggle
 */
function initPasswordToggles() {
    document.querySelectorAll('.btn-toggle-password').forEach(btn => {
        btn.addEventListener('click', () => {
            const targetId = btn.getAttribute('data-target');
            const targetInput = document.getElementById(targetId);
            const icon = btn.querySelector('i');
            if (targetInput) {
                if (targetInput.type === 'password') {
                    targetInput.type = 'text';
                    if (icon) icon.className = 'bi bi-eye-slash';
                } else {
                    targetInput.type = 'password';
                    if (icon) icon.className = 'bi bi-eye';
                }
            }
        });
    });
}

/**
 * Real-time Password Strength Meter with Dynamic Checklist
 */
function initPasswordStrengthMeter() {
    const passwordInput = document.getElementById('signupPassword');
    const bar = document.getElementById('strengthBar');
    const text = document.getElementById('strengthText');

    if (!passwordInput || !bar) return;

    passwordInput.addEventListener('input', () => {
        const val = passwordInput.value;
        let score = 0;

        if (val.length >= 8) score += 25;
        if (/[A-Z]/.test(val)) score += 25;
        if (/[0-9]/.test(val)) score += 25;
        if (/[^A-Za-z0-9]/.test(val)) score += 25;

        bar.style.width = score + '%';

        if (score === 0) {
            bar.style.backgroundColor = 'transparent';
            if (text) text.innerText = 'Min. 8 characters';
        } else if (score <= 25) {
            bar.style.backgroundColor = '#ef4444';
            if (text) text.innerHTML = '<span class="text-danger fw-semibold">Weak password</span> (add uppercase & numbers)';
        } else if (score <= 75) {
            bar.style.backgroundColor = '#f59e0b';
            if (text) text.innerHTML = '<span class="text-warning fw-semibold">Moderate password</span> (add special characters)';
        } else {
            bar.style.backgroundColor = '#10b981';
            if (text) text.innerHTML = '<span class="text-success fw-semibold">Strong password</span> (BCrypt ready)';
        }
    });
}

/**
 * One-Click Copy to Clipboard for API Keys & Commands
 */
function initCopyButtons() {
    document.querySelectorAll('.btn-copy-key').forEach(btn => {
        btn.addEventListener('click', () => {
            const keyText = btn.getAttribute('data-key');
            if (keyText) {
                copyTextToClipboard(keyText, btn, 'API Key copied to clipboard!');
            }
        });
    });
}

function copyToClipboard(elementId) {
    const elem = document.getElementById(elementId);
    if (elem) {
        copyTextToClipboard(elem.innerText.trim(), null, 'Copied command to clipboard!');
    }
}

function copyTextToClipboard(text, btnElement, successMsg) {
    navigator.clipboard.writeText(text).then(() => {
        if (btnElement) {
            const originalHTML = btnElement.innerHTML;
            btnElement.innerHTML = `<i class="bi bi-check2 text-success"></i> Copied!`;
            setTimeout(() => {
                btnElement.innerHTML = originalHTML;
            }, 2000);
        }
        showToast(successMsg || 'Copied to clipboard!', 'success');
    }).catch(err => {
        showToast('Failed to copy: ' + err, 'danger');
    });
}

/**
 * API Key View/Hide Mask Toggle
 */
function initApiKeyMaskToggles() {
    document.querySelectorAll('.btn-toggle-key').forEach(btn => {
        btn.addEventListener('click', () => {
            const targetId = btn.getAttribute('data-target');
            const targetElem = document.getElementById(targetId);
            const icon = btn.querySelector('i');

            if (targetElem) {
                const fullKey = targetElem.getAttribute('data-full-key');
                const maskedKey = targetElem.getAttribute('data-masked-key');

                if (targetElem.innerText === maskedKey) {
                    targetElem.innerText = fullKey;
                    if (icon) icon.className = 'bi bi-eye-slash';
                } else {
                    targetElem.innerText = maskedKey;
                    if (icon) icon.className = 'bi bi-eye';
                }
            }
        });
    });
}

/**
 * Auth Page Tab Switching (Password Login vs Employee Passwordless OTP)
 */
function initTabSwitches() {
    const tabBtns = document.querySelectorAll('.auth-tab-btn');
    if (!tabBtns.length) return;

    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            tabBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            const targetTab = btn.getAttribute('data-tab');
            document.querySelectorAll('.auth-tab-content').forEach(content => {
                content.classList.add('d-none');
            });

            const activeContent = document.getElementById(targetTab);
            if (activeContent) {
                activeContent.classList.remove('d-none');
            }
        });
    });
}

/**
 * OTP Request & Verification Handlers
 */
function initOTPHandlers() {
    const btnSendOtp = document.getElementById('btnSendEmpOtp');
    if (btnSendOtp) {
        btnSendOtp.addEventListener('click', () => {
            const emailInput = document.getElementById('empEmail');
            const email = emailInput ? emailInput.value.trim() : '';

            if (!email || !validateEmail(email)) {
                showToast('Please enter a valid email address.', 'danger');
                return;
            }

            btnSendOtp.disabled = true;
            btnSendOtp.innerHTML = `<span class="spinner-border spinner-border-sm me-1"></span> Sending...`;

            fetch('api/otp/send', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `email=${encodeURIComponent(email)}`
            })
            .then(res => res.json())
            .then(data => {
                btnSendOtp.disabled = false;
                btnSendOtp.innerHTML = `Resend OTP`;

                if (data.success) {
                    showToast("Please check your email inbox for the OTP code.", 'success');
                    const otpSection = document.getElementById('empOtpVerifySection');
                    if (otpSection) otpSection.classList.remove('d-none');
                    const otpInput = document.getElementById('empOtpCode');
                    if (otpInput) otpInput.focus();
                } else {
                    showToast(data.message, 'danger');
                }
            })
            .catch(err => {
                btnSendOtp.disabled = false;
                btnSendOtp.innerHTML = `Send OTP`;
                showToast('Error requesting OTP: ' + err, 'danger');
            });
        });
    }

    const btnVerifyOtp = document.getElementById('btnVerifyEmpOtp');
    if (btnVerifyOtp) {
        btnVerifyOtp.addEventListener('click', () => {
            const email = document.getElementById('empEmail').value.trim();
            const otpCode = document.getElementById('empOtpCode').value.trim();

            if (!otpCode || otpCode.length < 4) {
                showToast('Please enter a valid 4-digit OTP code.', 'danger');
                return;
            }

            btnVerifyOtp.disabled = true;
            btnVerifyOtp.innerHTML = `<span class="spinner-border spinner-border-sm me-1"></span> Verifying...`;

            fetch('api/otp/verify', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `email=${encodeURIComponent(email)}&otpCode=${encodeURIComponent(otpCode)}`
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    showToast(data.message, 'success');
                    setTimeout(() => {
                        window.location.href = data.data.redirect || 'dashboard';
                    }, 1000);
                } else {
                    btnVerifyOtp.disabled = false;
                    btnVerifyOtp.innerHTML = `Verify & Sign In`;
                    showToast(data.message, 'danger');
                }
            })
            .catch(err => {
                btnVerifyOtp.disabled = false;
                btnVerifyOtp.innerHTML = `Verify & Sign In`;
                showToast('Error verifying OTP: ' + err, 'danger');
            });
        });
    }
}

/**
 * AJAX Domain Registration Form
 */
function initDomainForm() {
    const addDomainForm = document.getElementById('addDomainForm');
    if (!addDomainForm) return;

    addDomainForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const domainNameInput = document.getElementById('domainNameInput');
        const domainName = domainNameInput ? domainNameInput.value.trim() : '';

        if (!domainName) {
            showToast('Please enter a domain name.', 'danger');
            return;
        }

        const githubRepoInput = document.getElementById('githubRepoInput');
        const githubRepo = githubRepoInput ? githubRepoInput.value.trim() : '';

        const githubTokenInput = document.getElementById('githubTokenInput');
        const githubToken = githubTokenInput ? githubTokenInput.value.trim() : '';

        const submitBtn = addDomainForm.querySelector('button[type="submit"]');
        if (submitBtn) {
            submitBtn.disabled = true;
            submitBtn.innerHTML = `<span class="spinner-border spinner-border-sm me-1"></span> Registering...`;
        }

        let bodyParams = `domainName=${encodeURIComponent(domainName)}`;
        if (githubRepo) bodyParams += `&githubRepo=${encodeURIComponent(githubRepo)}`;
        if (githubToken) bodyParams += `&githubToken=${encodeURIComponent(githubToken)}`;

        fetch('domains/add', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: bodyParams
        })
        .then(res => res.json())
        .then(data => {
            if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.innerHTML = `<i class="bi bi-plus-circle me-1"></i> Register Domain`;
            }

            if (data.success) {
                showToast(data.message, 'success');
                const modalElem = document.getElementById('addDomainModal');
                if (modalElem) {
                    const modal = bootstrap.Modal.getInstance(modalElem);
                    if (modal) modal.hide();
                }
                setTimeout(() => window.location.reload(), 1200);
            } else {
                showToast(data.message, 'danger');
            }
        })
        .catch(err => {
            if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.innerHTML = `<i class="bi bi-plus-circle me-1"></i> Register Domain`;
            }
            showToast('Error adding domain: ' + err, 'danger');
        });
    });
}

/**
 * Delete Domain Function
 */
function deleteDomain(domainId, domainName) {
    if (!confirm(`Are you sure you want to remove the domain "${domainName}" and revoke its API key?`)) {
        return;
    }

    fetch('domains/delete', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: `domainId=${encodeURIComponent(domainId)}`
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            showToast(data.message, 'success');
            setTimeout(() => window.location.reload(), 1000);
        } else {
            showToast(data.message, 'danger');
        }
    })
    .catch(err => {
        showToast('Error removing domain: ' + err, 'danger');
    });
}

function validateEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

/**
 * Universal Client-Side Search & Filter for Tables
 */
function initQuickSearchFilters() {
    const tableSearchInput = document.getElementById('tableSearchInput');
    if (tableSearchInput) {
        tableSearchInput.addEventListener('input', () => {
            const query = tableSearchInput.value.toLowerCase().trim();
            const rows = document.querySelectorAll('.table-saas tbody tr, .table tbody tr');
            rows.forEach(row => {
                const text = row.innerText.toLowerCase();
                row.style.display = text.includes(query) ? '' : 'none';
            });
        });
    }
}

/**
 * Bootstrap HTML5 Client-Side Form Validation
 */
function initFormValidation() {
    const forms = document.querySelectorAll('.needs-validation');
    Array.from(forms).forEach(form => {
        form.addEventListener('submit', event => {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add('was-validated');
        }, false);
    });
}
