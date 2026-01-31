#!/bin/bash
#
# .agent Performance Benchmark Runner
# Version: 2.0.0
# Purpose: Measure and track .agent system performance
# Usage: ./benchmark-runner.sh [workflow_name]
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BENCHMARK_FILE=".agent/benchmarks/performance-metrics.yml"
TIMESTAMP=$(date +%Y-%m-%d)
TEMP_DIR=".agent/benchmarks/.tmp"
REPORT_DIR=".agent/benchmarks/reports"

# Ensure directories exist
mkdir -p "$TEMP_DIR"
mkdir -p "$REPORT_DIR"

echo -e "${BLUE}=== .agent Performance Benchmark ===${NC}"
echo "Date: $TIMESTAMP"
echo "Version: $(cat .agent/VERSION)"
echo ""

# Function to measure workflow execution time
measure_workflow() {
    local workflow_name=$1
    local workflow_file=".agent/workflows/${workflow_name}.md"
    
    if [ ! -f "$workflow_file" ]; then
        echo -e "${YELLOW}⚠ Workflow not found: $workflow_name${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Measuring: $workflow_name${NC}"
    
    # Start timer
    local start_time=$(date +%s.%N)
    
    # Run workflow (simulated - in real scenario, trigger actual workflow)
    # For now, we just measure file read time as proxy
    cat "$workflow_file" > /dev/null
    
    # End timer
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    echo "  Duration: ${duration}s"
    
    # Get baseline from YAML
    local baseline=$(grep -A 3 "^  ${workflow_name}:" "$BENCHMARK_FILE" | grep "baseline:" | awk '{print $2}')
    
    if [ ! -z "$baseline" ]; then
        # Calculate difference
        local diff=$(echo "scale=2; (($duration - $baseline) / $baseline) * 100" | bc)
        
        if (( $(echo "$diff > 0" | bc -l) )); then
            echo -e "  ${RED}↑ +${diff}% slower than baseline${NC}"
        else
            echo -e "  ${GREEN}↓ ${diff}% faster than baseline${NC}"
        fi
        
        # Check regression threshold
        local threshold=$(grep -A 4 "^  ${workflow_name}:" "$BENCHMARK_FILE" | grep "regression_threshold:" | awk '{print $2}')
        
        if (( $(echo "$diff > $threshold" | bc -l) )); then
            echo -e "  ${RED}🚨 ALERT: Regression threshold exceeded!${NC}"
            echo "$workflow_name,$duration,$baseline,$diff,$TIMESTAMP" >> "$TEMP_DIR/alerts.csv"
        fi
    fi
    
    # Save measurement
    echo "$workflow_name,$duration,$TIMESTAMP" >> "$TEMP_DIR/measurements.csv"
}

# Function to measure all workflows
measure_all_workflows() {
    echo -e "${BLUE}=== Measuring All Workflows ===${NC}\n"
    
    # Get list of workflows
    local workflows=$(ls .agent/workflows/*.md | xargs -n 1 basename | sed 's/\.md$//')
    
    local count=0
    for workflow in $workflows; do
        measure_workflow "$workflow"
        ((count++))
        echo ""
    done
    
    echo -e "${GREEN}✓ Measured $count workflows${NC}\n"
}

# Function to measure agent response time
measure_agents() {
    echo -e "${BLUE}=== Measuring Agent Response Time ===${NC}\n"
    
    # Get list of agents
    local agents=$(ls .agent/agents/*.md 2>/dev/null | xargs -n 1 basename | sed 's/\.md$//' || echo "")
    
    if [ -z "$agents" ]; then
        echo -e "${YELLOW}⚠ No agents found${NC}\n"
        return
    fi
    
    local count=0
    for agent in $agents; do
        local agent_file=".agent/agents/${agent}.md"
        
        echo -e "${BLUE}Measuring: $agent${NC}"
        
        # Simulate first response time (file access)
        local start=$(date +%s.%N)
        head -n 1 "$agent_file" > /dev/null
        local end=$(date +%s.%N)
        local first_response=$(echo "$end - $start" | bc)
        
        # Simulate complete task time (full file read)
        start=$(date +%s.%N)
        cat "$agent_file" > /dev/null
        end=$(date +%s.%N)
        local complete_time=$(echo "$end - $start" | bc)
        
        echo "  First response: ${first_response}s"
        echo "  Complete: ${complete_time}s"
        
        echo "$agent,$first_response,$complete_time,$TIMESTAMP" >> "$TEMP_DIR/agent_measurements.csv"
        ((count++))
        echo ""
    done
    
    echo -e "${GREEN}✓ Measured $count agents${NC}\n"
}

# Function to measure skill loading time
measure_skills() {
    echo -e "${BLUE}=== Measuring Skill Loading Time ===${NC}\n"
    
    # Sample 10 random skills for quick measurement
    local skills=$(ls .agent/skills/*/SKILL.md 2>/dev/null | shuf -n 10 || echo "")
    
    if [ -z "$skills" ]; then
        echo -e "${YELLOW}⚠ No skills found${NC}\n"
        return
    fi
    
    local total_time=0
    local count=0
    
    for skill_file in $skills; do
        local skill_name=$(dirname "$skill_file" | xargs basename)
        
        # Measure load time
        local start=$(date +%s.%N)
        cat "$skill_file" > /dev/null
        local end=$(date +%s.%N)
        local load_time=$(echo "($end - $start) * 1000" | bc)  # Convert to ms
        
        total_time=$(echo "$total_time + $load_time" | bc)
        ((count++))
    done
    
    local avg_time=$(echo "scale=2; $total_time / $count" | bc)
    echo -e "${BLUE}Average skill load time: ${avg_time}ms${NC}\n"
    
    echo "average,$avg_time,$TIMESTAMP" >> "$TEMP_DIR/skill_measurements.csv"
}

# Function to measure system startup
measure_startup() {
    echo -e "${BLUE}=== Measuring System Startup ===${NC}\n"
    
    # Measure cold start (first access to .agent)
    echo "Measuring cold start..."
    local start=$(date +%s.%N)
    ls -R .agent > /dev/null
    local end=$(date +%s.%N)
    local cold_start=$(echo "$end - $start" | bc)
    
    echo "  Cold start: ${cold_start}s"
    
    # Measure warm start (cached access)
    echo "Measuring warm start..."
    start=$(date +%s.%N)
    ls -R .agent > /dev/null
    end=$(date +%s.%N)
    local warm_start=$(echo "$end - $start" | bc)
    
    echo "  Warm start: ${warm_start}s"
    echo ""
    
    echo "cold_start,$cold_start,$TIMESTAMP" >> "$TEMP_DIR/startup_measurements.csv"
    echo "warm_start,$warm_start,$TIMESTAMP" >> "$TEMP_DIR/startup_measurements.csv"
}

# Function to detect regressions
detect_regressions() {
    echo -e "${BLUE}=== Checking for Regressions ===${NC}\n"
    
    if [ -f "$TEMP_DIR/alerts.csv" ]; then
        local alert_count=$(wc -l < "$TEMP_DIR/alerts.csv")
        echo -e "${RED}🚨 $alert_count regression(s) detected!${NC}"
        echo ""
        echo "Details:"
        cat "$TEMP_DIR/alerts.csv" | while IFS=',' read -r workflow duration baseline diff date; do
            echo "  - $workflow: ${diff}% slower (${duration}s vs ${baseline}s baseline)"
        done
        echo ""
        return 1
    else
        echo -e "${GREEN}✓ No regressions detected${NC}\n"
        return 0
    fi
}

# Function to generate report
generate_report() {
    echo -e "${BLUE}=== Generating Performance Report ===${NC}\n"
    
    local report_file="$REPORT_DIR/performance-report-${TIMESTAMP}.md"
    
    cat > "$report_file" << EOF
# Performance Benchmark Report

**Date:** $TIMESTAMP  
**Version:** $(cat .agent/VERSION)

---

## Summary

EOF
    
    # Add workflow measurements
    if [ -f "$TEMP_DIR/measurements.csv" ]; then
        local workflow_count=$(wc -l < "$TEMP_DIR/measurements.csv")
        echo "**Workflows Measured:** $workflow_count" >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    # Add agent measurements
    if [ -f "$TEMP_DIR/agent_measurements.csv" ]; then
        local agent_count=$(wc -l < "$TEMP_DIR/agent_measurements.csv")
        echo "**Agents Measured:** $agent_count" >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    # Add regressions
    if [ -f "$TEMP_DIR/alerts.csv" ]; then
        local alert_count=$(wc -l < "$TEMP_DIR/alerts.csv")
        echo "**Regressions Detected:** 🚨 $alert_count" >> "$report_file"
        echo "" >> "$report_file"
        
        echo "## Regressions" >> "$report_file"
        echo "" >> "$report_file"
        cat "$TEMP_DIR/alerts.csv" | while IFS=',' read -r workflow duration baseline diff date; do
            echo "- **$workflow**: +${diff}% slower (${duration}s vs ${baseline}s)" >> "$report_file"
        done
        echo "" >> "$report_file"
    else
        echo "**Regressions Detected:** ✓ None" >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    echo "---" >> "$report_file"
    echo "" >> "$report_file"
    echo "## Detailed Measurements" >> "$report_file"
    echo "" >> "$report_file"
    
    # Add workflow details
    if [ -f "$TEMP_DIR/measurements.csv" ]; then
        echo "### Workflows" >> "$report_file"
        echo "" >> "$report_file"
        echo "| Workflow | Duration | Date |" >> "$report_file"
        echo "|----------|----------|------|" >> "$report_file"
        cat "$TEMP_DIR/measurements.csv" | while IFS=',' read -r workflow duration date; do
            echo "| $workflow | ${duration}s | $date |" >> "$report_file"
        done
        echo "" >> "$report_file"
    fi
    
    # Add agent details
    if [ -f "$TEMP_DIR/agent_measurements.csv" ]; then
        echo "### Agents" >> "$report_file"
        echo "" >> "$report_file"
        echo "| Agent | First Response | Complete | Date |" >> "$report_file"
        echo "|-------|----------------|----------|------|" >> "$report_file"
        cat "$TEMP_DIR/agent_measurements.csv" | while IFS=',' read -r agent first complete date; do
            echo "| $agent | ${first}s | ${complete}s | $date |" >> "$report_file"
        done
        echo "" >> "$report_file"
    fi
    
    echo -e "${GREEN}✓ Report generated: $report_file${NC}\n"
}

# Function to cleanup temp files
cleanup() {
    echo -e "${BLUE}Cleaning up...${NC}"
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}✓ Done${NC}\n"
}

# Main execution
main() {
    local workflow_name=$1
    
    if [ ! -z "$workflow_name" ]; then
        # Measure specific workflow
        measure_workflow "$workflow_name"
    else
        # Measure everything
        measure_all_workflows
        measure_agents
        measure_skills
        measure_startup
        detect_regressions
        generate_report
    fi
    
    cleanup
}

# Run main
main "$@"
