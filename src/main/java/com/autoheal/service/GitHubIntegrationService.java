package com.autoheal.service;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Base64;

public class GitHubIntegrationService {
    private static final String GITHUB_API_URL = "https://api.github.com";
    private static final HttpClient HTTP_CLIENT = HttpClient.newBuilder()
            .version(HttpClient.Version.HTTP_2)
            .connectTimeout(Duration.ofSeconds(10))
            .build();
    private static final Gson GSON = new Gson();

    /**
     * Executes the GitHub hotfix flow: Branch -> Commit -> PR -> Merge.
     */
    public boolean executeSourceCodeFix(String repo, String token, Long logId, String patchData) throws Exception {
        if (repo == null || token == null || repo.isEmpty() || token.isEmpty()) {
            throw new Exception("GitHub Repository or Token is missing for this domain.");
        }

        String branchName = "refs/heads/autoheal-hotfix-" + logId + "-" + System.currentTimeMillis();
        
        // 1. Get default branch SHA (assuming 'main')
        String baseSha = getBranchSha(repo, token, "main");
        if (baseSha == null) {
            // Fallback to 'master' if 'main' doesn't exist
            baseSha = getBranchSha(repo, token, "master");
        }
        
        if (baseSha == null) {
            throw new Exception("Could not find default branch (main or master) to branch from.");
        }

        // 2. Create new hotfix branch
        createBranch(repo, token, branchName, baseSha);

        // 3. Commit the patch (We simulate this by updating/creating a patch summary file to trigger CI/CD)
        commitPatch(repo, token, branchName.replace("refs/heads/", ""), logId, patchData);

        // 4. Create Pull Request
        int prNumber = createPullRequest(repo, token, branchName.replace("refs/heads/", ""), logId);

        // 5. Merge Pull Request
        mergePullRequest(repo, token, prNumber);

        return true;
    }

    private String getBranchSha(String repo, String token, String branch) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(GITHUB_API_URL + "/repos/" + repo + "/git/ref/heads/" + branch))
                .header("Authorization", "Bearer " + token)
                .header("Accept", "application/vnd.github.v3+json")
                .GET()
                .build();

        HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() == 200) {
            JsonObject json = GSON.fromJson(response.body(), JsonObject.class);
            return json.getAsJsonObject("object").get("sha").getAsString();
        }
        return null;
    }

    private void createBranch(String repo, String token, String refName, String sha) throws Exception {
        JsonObject body = new JsonObject();
        body.addProperty("ref", refName);
        body.addProperty("sha", sha);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(GITHUB_API_URL + "/repos/" + repo + "/git/refs"))
                .header("Authorization", "Bearer " + token)
                .header("Accept", "application/vnd.github.v3+json")
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(GSON.toJson(body)))
                .build();

        HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 201) {
            throw new Exception("Failed to create branch: " + response.body());
        }
    }

    private void commitPatch(String repo, String token, String branch, Long logId, String patchData) throws Exception {
        // We will create/update a file named 'autoheal-patch.txt' in the repo
        String path = "autoheal-patch-" + logId + ".txt";
        String contentBase64 = Base64.getEncoder().encodeToString(patchData.getBytes());

        JsonObject body = new JsonObject();
        body.addProperty("message", "AutoHeal: Applied patch for log " + logId);
        body.addProperty("content", contentBase64);
        body.addProperty("branch", branch);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(GITHUB_API_URL + "/repos/" + repo + "/contents/" + path))
                .header("Authorization", "Bearer " + token)
                .header("Accept", "application/vnd.github.v3+json")
                .header("Content-Type", "application/json")
                .PUT(HttpRequest.BodyPublishers.ofString(GSON.toJson(body)))
                .build();

        HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 201 && response.statusCode() != 200) {
            throw new Exception("Failed to commit patch: " + response.body());
        }
    }

    private int createPullRequest(String repo, String token, String headBranch, Long logId) throws Exception {
        JsonObject body = new JsonObject();
        body.addProperty("title", "AutoHeal Hotfix: Resolution for Log " + logId);
        body.addProperty("body", "This PR was automatically generated by AutoHeal Platform.");
        body.addProperty("head", headBranch);
        body.addProperty("base", "main"); // Usually 'main', should ideally fetch default branch

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(GITHUB_API_URL + "/repos/" + repo + "/pulls"))
                .header("Authorization", "Bearer " + token)
                .header("Accept", "application/vnd.github.v3+json")
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(GSON.toJson(body)))
                .build();

        HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 201) {
            // Fallback to base 'master' if 'main' fails
            body.addProperty("base", "master");
            request = HttpRequest.newBuilder()
                    .uri(URI.create(GITHUB_API_URL + "/repos/" + repo + "/pulls"))
                    .header("Authorization", "Bearer " + token)
                    .header("Accept", "application/vnd.github.v3+json")
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(GSON.toJson(body)))
                    .build();
            response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
            
            if (response.statusCode() != 201) {
                throw new Exception("Failed to create Pull Request: " + response.body());
            }
        }
        
        JsonObject json = GSON.fromJson(response.body(), JsonObject.class);
        return json.get("number").getAsInt();
    }

    private void mergePullRequest(String repo, String token, int prNumber) throws Exception {
        JsonObject body = new JsonObject();
        body.addProperty("commit_title", "AutoHeal Automated Merge PR #" + prNumber);
        body.addProperty("merge_method", "squash");

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(GITHUB_API_URL + "/repos/" + repo + "/pulls/" + prNumber + "/merge"))
                .header("Authorization", "Bearer " + token)
                .header("Accept", "application/vnd.github.v3+json")
                .header("Content-Type", "application/json")
                .PUT(HttpRequest.BodyPublishers.ofString(GSON.toJson(body)))
                .build();

        HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            throw new Exception("Failed to merge Pull Request: " + response.body());
        }
    }
}
