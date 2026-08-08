package com.autoheal.guardrail;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

public class RateLimiter {
    // Maps domainId to a list of execution timestamps (milliseconds)
    private static final ConcurrentHashMap<Long, List<Long>> executionHistory = new ConcurrentHashMap<>();
    
    public static int maxExecutions = 3;
    public static long timeWindowMs = 15 * 60 * 1000; // 15 minutes

    public static void recordExecution(Long domainId) {
        long now = System.currentTimeMillis();
        executionHistory.computeIfAbsent(domainId, k -> new CopyOnWriteArrayList<>()).add(now);
    }

    public static boolean isLoopDetected(Long domainId) {
        List<Long> history = executionHistory.get(domainId);
        if (history == null) return false;

        long now = System.currentTimeMillis();
        long thresholdTime = now - timeWindowMs;
        
        // Clean up old entries
        history.removeIf(timestamp -> timestamp < thresholdTime);

        return history.size() >= maxExecutions;
    }
    
    public static void setMaxExecutions(int max) {
        maxExecutions = max;
    }
    
    public static int getExecutionCount(Long domainId) {
        List<Long> history = executionHistory.get(domainId);
        if (history == null) return 0;
        long now = System.currentTimeMillis();
        history.removeIf(timestamp -> timestamp < (now - timeWindowMs));
        return history.size();
    }
}
