# Performance Benchmarking System

**Version:** 2.0.0  
**Created:** 2026-01-17  
**Purpose:** Track .agent system performance and prevent regressions

---

## Quick Start

### Run Benchmark

```bash
# Measure all workflows, agents, skills
./agent/benchmarks/benchmark-runner.sh

# Measure specific workflow
./agent/benchmarks/benchmark-runner.sh security-audit
```

### View Results

```bash
# Latest report
cat .agent/benchmarks/reports/performance-report-$(date +%Y-%m-%d).md

# All reports
ls .agent/benchmarks/reports/
```

---

## System Components

### 1. Performance Metrics (YAML)
**File:** `performance-metrics.yml`

**Tracks:**
- Workflow execution time (23 workflows)
- Agent response time (6+ agents)
- Resource usage (memory, disk, network)
- Skill loading time
- System startup time

**Baselines:** Set at v2.0.0 release

---

### 2. Benchmark Runner (Script)
**File:** `benchmark-runner.sh`

**Features:**
- Auto-measure all components
- Compare vs baselines
- Detect regressions
- Generate reports
- Alert on threshold violations

---

### 3. Reports
**Directory:** `reports/`

**Format:** Markdown reports with tables

**Example:**
```
performance-report-2026-01-17.md
performance-report-2026-01-24.md
performance-report-2026-01-31.md
```

---

## Metrics Explained

### Workflow Execution Time
Time to complete a workflow from start to finish.

**Baseline:** Average time at v2.0.0 release  
**Target:** ≤ baseline  
**Regression Threshold:** +20% (configurable per workflow)

**Example:**
```yaml
code-review-automation:
  baseline: 45.0s
  current: 48.0s
  regression: +6.7% ✓ OK (< 20%)
```

---

### Agent Response Time
Time for agent to respond and complete tasks.

**Metrics:**
- **First Response:** Time to acknowledge task
- **Complete:** Time to finish task

**Baseline:** v2.0.0 measurements

---

### Resource Usage
System resource consumption.

**Tracked:**
- Memory (idle & active)
- Disk I/O (reads/writes)
- Network (API calls, data transfer)

**Alerts:** Triggered if usage increases > 30%

---

### Skill Loading Time
Time to load skill into memory.

**Measured:** Average across 10 random skills  
**Target:** < 100ms per skill

---

### System Startup
Cold vs warm start time.

**Cold Start:** First .agent access (disk read)  
**Warm Start:** Cached access (memory read)

**Targets:**
- Cold: < 2.0s (current baseline: 3.0s)
- Warm: < 0.3s (current baseline: 0.5s)

---

## Regression Detection

### How It Works

1. **Measure:** Run benchmark
2. **Compare:** Current vs baseline
3. **Calculate:** % difference
4. **Check:** Exceeds threshold?
5. **Alert:** If yes, flag for investigation

### Thresholds

**Default:** 20% increase triggers alert

**Per-component override:**
```yaml
security-audit:
  baseline: 30.0
  regression_threshold: 15  # Stricter for critical workflow
```

---

## Reporting

### Automated Reports

Generated after each benchmark run:

```markdown
# Performance Benchmark Report

Date: 2026-01-17
Version: 2.0.0

## Summary
Workflows Measured: 23
Agents Measured: 6
Regressions Detected: ✓ None

## Detailed Measurements
| Workflow | Duration | vs Baseline |
|----------|----------|-------------|
| security-audit | 28.5s | -5.0% ✓ |
| ... | ... | ... |
```

---

## Performance Trends

### Tracking Over Time

The system tracks trends:

**Improving:** 🎉 Getting faster  
**Degrading:** 🚨 Getting slower (investigate!)  
**Stable:** ✓ Consistent (good)

**Example:**
```yaml
trends:
  improving:
    - workflow: optimize
      improvement: -15%  # 15% faster!
      
  degrading:
    - workflow: deploy
      degradation: +12%  # Needs investigation
```

---

## Usage Patterns

### Weekly Measurement
```bash
# Add to cron or GitHub Actions
# Every Monday at 9 AM
0 9 * * 1 cd /project && ./.agent/benchmarks/benchmark-runner.sh
```

### Pre-Release
```bash
# Before cutting release
./agent/benchmarks/benchmark-runner.sh

# Check for regressions
cat .agent/benchmarks/reports/performance-report-latest.md
```

### CI/CD Integration
```yaml
# .github/workflows/performance.yml
name: Performance Check
on: [pull_request]
jobs:
  benchmark:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Benchmark
        run: ./.agent/benchmarks/benchmark-runner.sh
      - name: Check Regressions
        run: |
          if grep -q "regression(s) detected" .agent/benchmarks/reports/*.md; then
            echo "Performance regressions found!"
            exit 1
          fi
```

---

## Performance Goals

### v2.1.0 Targets
- code-review-automation: -10% (45s → 40.5s)
- Average skill load: -20% (100ms → 80ms)
- Memory usage: -15%

### v2.2.0 Targets
- Cold start: -33% (3.0s → 2.0s)
- Agent response: -20% across all agents

---

## Troubleshooting

### High Execution Time

**Possible causes:**
- Resource contention
- Network latency
- Disk I/O bottleneck
- Memory pressure

**Investigation:**
1. Check system resources
2. Review recent changes
3. Profile specific workflow
4. Optimize bottlenecks

---

### False Positives

**If legitimate changes increase time:**

1. Update baseline in `performance-metrics.yml`
2. Document reason in `CHANGELOG.md`
3. Adjust threshold if needed

**Example:**
```yaml
# Added comprehensive security checks
security-audit:
  baseline: 35.0  # Was 30.0, updated for v2.1.0
  notes: "Added 5 new OWASP checks"
```

---

## Best Practices

### ✅ DO
- Run benchmarks weekly
- Investigate regressions immediately
- Update baselines thoughtfully
- Track trends over time
- Optimize bottlenecks

### ❌ DON'T
- Ignore regressions
- Update baselines without reason
- Run on loaded systems (skews results)
- Skip measurements
- Optimize prematurely (measure first!)

---

## Files

```
.agent/benchmarks/
├── performance-metrics.yml    # Baseline data
├── benchmark-runner.sh        # Measurement script
├── README.md                  # This file
├── reports/                   # Generated reports
│   ├── performance-report-2026-01-17.md
│   └── ...
└── .tmp/                      # Temporary data (gitignored)
```

---

## Future Enhancements

### Planned (v2.1+)
- [ ] Historical charting (graphs over time)
- [ ] Comparison between versions
- [ ] Automated optimization suggestions
- [ ] Percentile tracking (p50, p95, p99)
- [ ] Real-time monitoring dashboard

---

## Support

**Questions?** See:
- `.agent/INTEGRATION-GUIDE.md` - General usage
- `.agent/CHANGELOG.md` - Version history
- Performance metrics YAML - Configuration

---

**Start tracking performance today!** 🚀

```bash
./agent/benchmarks/benchmark-runner.sh
```
