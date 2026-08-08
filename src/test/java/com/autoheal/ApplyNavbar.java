package com.autoheal;

import java.nio.file.*;
import java.io.IOException;
import java.util.regex.*;

public class ApplyNavbar {
    public static void main(String[] args) throws IOException {
        String baseDir = "c:/Users/sahil/OneDrive/Desktop/Major project/src/main/webapp/";
        String[] files = {"diagnostics.jsp", "team.jsp", "audit.jsp", "approvals.jsp", "guardrails.jsp", "simulation.jsp"};

        String navbar = "    <!-- Top Dashboard Navbar -->\n" +
            "    <nav class=\"navbar navbar-saas\">\n" +
            "        <div class=\"container-fluid px-4\">\n" +
            "            <div class=\"d-flex align-items-center gap-4\">\n" +
            "                <a class=\"navbar-brand d-flex align-items-center gap-2\" href=\"${pageContext.request.contextPath}/dashboard\">\n" +
            "                    <i class=\"bi bi-cpu-fill text-primary fs-3\"></i>\n" +
            "                    <span class=\"brand-gradient\">AutoHeal Console</span>\n" +
            "                </a>\n\n" +
            "                <!-- Main Navigation Links -->\n" +
            "                <div class=\"d-none d-md-flex align-items-center gap-1\">\n" +
            "                    <a href=\"${pageContext.request.contextPath}/dashboard\" class=\"btn btn-sm btn-saas-outline border-0\">\n" +
            "                        <i class=\"bi bi-speedometer2 me-1\"></i> Dashboard\n" +
            "                    </a>\n" +
            "                    <a href=\"${pageContext.request.contextPath}/logs\" class=\"btn btn-sm btn-saas-outline border-0\">\n" +
            "                        <i class=\"bi bi-terminal-fill me-1\"></i> Live Logs\n" +
            "                    </a>\n" +
            "                    <a href=\"${pageContext.request.contextPath}/rules\" class=\"btn btn-sm btn-saas-outline border-0\">\n" +
            "                        <i class=\"bi bi-magic me-1\"></i> Healing Rules\n" +
            "                    </a>\n" +
            "                    \n" +
            "                    <!-- AI & Approvals -->\n" +
            "                    <div class=\"dropdown\">\n" +
            "                        <button class=\"btn btn-sm btn-saas-outline border-0 dropdown-toggle\" type=\"button\" data-bs-toggle=\"dropdown\">\n" +
            "                            <i class=\"bi bi-robot me-1\"></i> AI Engine\n" +
            "                        </button>\n" +
            "                        <ul class=\"dropdown-menu shadow-sm shadow-lg border-secondary\">\n" +
            "                            <li><a class=\"dropdown-item text-dark\" href=\"${pageContext.request.contextPath}/diagnostics\"><i class=\"bi bi-search me-2\"></i> Diagnostics</a></li>\n" +
            "                            <li><a class=\"dropdown-item text-dark\" href=\"${pageContext.request.contextPath}/approvals\"><i class=\"bi bi-check2-square me-2\"></i> Approvals Queue</a></li>\n" +
            "                        </ul>\n" +
            "                    </div>\n\n" +
            "                    <!-- Administration -->\n" +
            "                    <div class=\"dropdown\">\n" +
            "                        <button class=\"btn btn-sm btn-saas-outline border-0 dropdown-toggle\" type=\"button\" data-bs-toggle=\"dropdown\">\n" +
            "                            <i class=\"bi bi-shield-lock me-1\"></i> Admin\n" +
            "                        </button>\n" +
            "                        <ul class=\"dropdown-menu shadow-sm shadow-lg border-secondary\">\n" +
            "                            <li><a class=\"dropdown-item text-dark\" href=\"${pageContext.request.contextPath}/team\"><i class=\"bi bi-people me-2\"></i> Team Management</a></li>\n" +
            "                            <li><a class=\"dropdown-item text-dark\" href=\"${pageContext.request.contextPath}/audit\"><i class=\"bi bi-clock-history me-2\"></i> Audit Trail</a></li>\n" +
            "                            <li><hr class=\"dropdown-divider border-secondary\"></li>\n" +
            "                            <li><a class=\"dropdown-item text-dark\" href=\"${pageContext.request.contextPath}/guardrails\"><i class=\"bi bi-shield-lock me-2\"></i> Guardrails</a></li>\n" +
            "                            <li><a class=\"dropdown-item text-dark\" href=\"${pageContext.request.contextPath}/simulation\"><i class=\"bi bi-play-circle me-2\"></i> Simulation Console</a></li>\n" +
            "                        </ul>\n" +
            "                    </div>\n" +
            "                </div>\n" +
            "            </div>\n" +
            "            \n" +
            "            <div class=\"d-flex align-items-center gap-3\">\n" +
            "                <!-- Tenant Org Badge -->\n" +
            "                <div class=\"d-none d-md-flex align-items-center gap-2 px-3 py-1.5 rounded-pill bg-light border border-secondary border-opacity-30\">\n" +
            "                    <i class=\"bi bi-buildings text-primary\"></i>\n" +
            "                    <span class=\"text-dark fw-semibold small\"><c:out value=\"${sessionScope.orgName}\" default=\"Organization\" /></span>\n" +
            "                </div>\n\n" +
            "                <!-- User Profile & Role -->\n" +
            "                <div class=\"dropdown\">\n" +
            "                    <button class=\"btn btn-saas-outline d-flex align-items-center gap-2 py-1.5 px-3 dropdown-toggle\" type=\"button\" data-bs-toggle=\"dropdown\">\n" +
            "                        <div class=\"bg-primary text-dark rounded-circle d-flex align-items-center justify-content-center fw-bold\" style=\"width:28px; height:28px; font-size:12px;\">\n" +
            "                            <c:out value=\"${sessionScope.user.fullName.substring(0, 1)}\" default=\"U\" />\n" +
            "                        </div>\n" +
            "                        <span class=\"text-dark small fw-medium\"><c:out value=\"${sessionScope.user.fullName}\" default=\"User\" /></span>\n" +
            "                        <span class=\"badge badge-role\"><c:out value=\"${sessionScope.user.role}\" default=\"MEMBER\" /></span>\n" +
            "                    </button>\n" +
            "                    <ul class=\"dropdown-menu shadow-sm dropdown-menu-end shadow-lg border-secondary\">\n" +
            "                        <li><h6 class=\"dropdown-header text-muted\"><c:out value=\"${sessionScope.user.email}\" /></h6></li>\n" +
            "                        <li><hr class=\"dropdown-divider border-secondary\"></li>\n" +
            "                        <li><a class=\"dropdown-item text-danger\" href=\"${pageContext.request.contextPath}/logout\"><i class=\"bi bi-box-arrow-right me-2\"></i> Sign Out</a></li>\n" +
            "                    </ul>\n" +
            "                </div>\n" +
            "            </div>\n" +
            "        </div>\n" +
            "    </nav>\n\n" +
            "    <!-- Main Container -->\n" +
            "    <div class=\"container-fluid px-4 py-4\">";

        for (String file : files) {
            Path path = Paths.get(baseDir + file);
            if (!Files.exists(path)) continue;

            String content = new String(Files.readAllBytes(path));

            // Inject theme.css if missing
            if (!content.contains("theme.css")) {
                content = content.replace("</title>", "</title>\n    <!-- Custom CSS -->\n    <link href=\"${pageContext.request.contextPath}/assets/css/theme.css\" rel=\"stylesheet\">");
            }

            // Remove sidebar CSS block if present
            content = content.replaceAll("(?s)<style>\\s*body \\{ background-color.*?\\.sidebar \\{.*?\\s*</style>", "");
            
            // Replace sidebar layout with navbar
            content = content.replaceAll("(?s)<div class=\"container-fluid\">\\s*<div class=\"row\">\\s*<!-- Sidebar Navigation.*?<main class=\"[^\"]*\">", Matcher.quoteReplacement(navbar));
            
            // Wait, for files that just have `<div class="row">` without `<!-- Sidebar Navigation`, adjust regex:
            content = content.replaceAll("(?s)<div class=\"container-fluid\">\\s*<div class=\"row\">\\s*<nav id=\"sidebarMenu\".*?</nav>\\s*<main class=\"[^\"]*\">", Matcher.quoteReplacement(navbar));

            // Replace closing tags
            content = content.replace("</main>\n    </div>\n</div>", "</div>");
            content = content.replace("</main>\r\n    </div>\r\n</div>", "</div>");
            content = content.replace("</main>\r\n\t</div>\r\n</div>", "</div>"); // just in case
            content = content.replace("</main>\n\t</div>\n</div>", "</div>"); // just in case
            
            // Another fallback for closing tags: regex
            content = content.replaceAll("(?s)</main>\\s*</div>\\s*</div>", "</div>");

            Files.write(path, content.getBytes());
            System.out.println("Processed " + file);
        }
    }
}
