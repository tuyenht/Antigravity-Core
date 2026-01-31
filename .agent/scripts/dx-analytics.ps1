# DX Analytics Script
# Collects and displays developer experience metrics
# References: .agent/dx-analytics.yml

param(
    [switch]$Dashboard,
    [switch]$ROI,
    [switch]$Quality,
    [switch]$Bottlenecks,
    [switch]$Recommendations,
    [string]$Period = "week",
    [string]$Export,
    [switch]$Help
)

# Colors
$Red = "Red"
$Yellow = "Yellow"
$Green = "Green"
$Cyan = "Cyan"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Help {
    Write-ColorOutput "DX Analytics Script" $Cyan
    Write-ColorOutput "===================" $Cyan
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\dx-analytics.ps1 -Dashboard       # Show full dashboard"
    Write-Host "  .\dx-analytics.ps1 -ROI             # Show automation ROI"
    Write-Host "  .\dx-analytics.ps1 -Quality         # Show quality metrics"
    Write-Host "  .\dx-analytics.ps1 -Bottlenecks     # Show detected bottlenecks"
    Write-Host "  .\dx-analytics.ps1 -Recommendations # Show AI recommendations"
    Write-Host "  .\dx-analytics.ps1 -Period month    # Change period (day/week/month)"
    Write-Host "  .\dx-analytics.ps1 -Export file.md  # Export to markdown"
    Write-Host "  .\dx-analytics.ps1 -Help            # Show this help"
    Write-Host ""
}

# Metrics storage file
$MetricsFile = ".agent/memory/dx-analytics.json"

function Get-Metrics {
    if (Test-Path $MetricsFile) {
        return Get-Content $MetricsFile | ConvertFrom-Json
    }
    else {
        # Return default/sample metrics
        return @{
            last_updated = Get-Date -Format "yyyy-MM-dd"
            dx_score     = 85
            dx_trend     = "+3"
            velocity     = @{
                tasks_per_day        = 6.5
                avg_duration_minutes = 28
                lines_generated      = 1850
                commits_per_day      = 7
            }
            automation   = @{
                code_generator_uses             = 25
                code_generator_time_saved_hours = 12.5
                auto_healing_fixes              = 67
                auto_healing_time_saved_hours   = 5.6
                ai_review_issues_caught         = 18
                ai_review_time_saved_hours      = 3.0
                triage_routing_accuracy         = 88
            }
            quality      = @{
                test_coverage        = 82
                test_coverage_prev   = 78
                standards_compliance = 100
                lint_errors          = 0
                type_errors          = 0
                perf_violations      = 0
                perf_violations_prev = 2
            }
            agents       = @{
                most_used                 = @("code-generator-agent", "ai-code-reviewer", "test-generator", "backend-specialist", "triage-agent")
                least_used                = @("game-designer", "pc-game-developer", "mobile-game-developer")
                avg_response_time_seconds = 4.2
                success_rate              = 94
            }
        }
    }
}

function Save-Metrics {
    param($Metrics)
    
    # Ensure directory exists
    $dir = Split-Path $MetricsFile
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    $Metrics | ConvertTo-Json -Depth 10 | Set-Content $MetricsFile
}

function Calculate-DXScore {
    param($Metrics)
    
    # Weighted scoring
    $velocityScore = [math]::Min(100, ($Metrics.velocity.tasks_per_day / 5) * 25)
    $automationScore = [math]::Min(100, ($Metrics.automation.triage_routing_accuracy / 90) * 25)
    $qualityScore = [math]::Min(100, ($Metrics.quality.test_coverage / 80) * 25)
    $agentScore = [math]::Min(100, ($Metrics.agents.success_rate / 95) * 25)
    
    return [math]::Round($velocityScore + $automationScore + $qualityScore + $agentScore)
}

function Show-Dashboard {
    param($Metrics)
    
    $dxScore = Calculate-DXScore $Metrics
    
    Write-ColorOutput "📊 DX Analytics Dashboard" $Cyan
    Write-ColorOutput "=========================" $Cyan
    Write-Host ""
    Write-Host "Period: Last $Period"
    Write-Host "Last Updated: $($Metrics.last_updated)"
    Write-Host ""
    
    # DX Score
    $scoreColor = if ($dxScore -ge 80) { $Green } elseif ($dxScore -ge 60) { $Yellow } else { $Red }
    Write-ColorOutput "DX Score: $dxScore/100 ($($Metrics.dx_trend) vs last week)" $scoreColor
    Write-Host ""
    
    # Velocity
    Write-ColorOutput "⚡ Velocity" $Cyan
    Write-Host "   Tasks/Day:      $($Metrics.velocity.tasks_per_day) (target: 5)"
    Write-Host "   Avg Duration:   $($Metrics.velocity.avg_duration_minutes) min (target: 30)"
    Write-Host "   Lines Generated: $($Metrics.velocity.lines_generated)"
    Write-Host "   Commits/Day:    $($Metrics.velocity.commits_per_day)"
    Write-Host ""
    
    # Automation ROI
    Show-ROI $Metrics
    
    # Quality
    Show-Quality $Metrics
}

function Show-ROI {
    param($Metrics)
    
    Write-ColorOutput "🤖 Automation ROI" $Cyan
    Write-Host ""
    Write-Host "   Agent                Uses    Time Saved"
    Write-Host "   -------------------- ------  ----------"
    Write-Host "   code-generator       $($Metrics.automation.code_generator_uses.ToString().PadLeft(6))  $($Metrics.automation.code_generator_time_saved_hours)h"
    Write-Host "   auto-healing         $($Metrics.automation.auto_healing_fixes.ToString().PadLeft(6))  $($Metrics.automation.auto_healing_time_saved_hours)h"
    Write-Host "   ai-code-reviewer     $($Metrics.automation.ai_review_issues_caught.ToString().PadLeft(6))  $($Metrics.automation.ai_review_time_saved_hours)h"
    Write-Host ""
    
    $totalSaved = $Metrics.automation.code_generator_time_saved_hours + 
    $Metrics.automation.auto_healing_time_saved_hours + 
    $Metrics.automation.ai_review_time_saved_hours
    
    Write-ColorOutput "   Total Time Saved: $totalSaved hours 🎉" $Green
    Write-Host ""
}

function Show-Quality {
    param($Metrics)
    
    Write-ColorOutput "📈 Quality Metrics" $Cyan
    Write-Host ""
    
    $q = $Metrics.quality
    
    # Test coverage
    $coverageTrend = if ($q.test_coverage -gt $q.test_coverage_prev) { "⬆️" } elseif ($q.test_coverage -lt $q.test_coverage_prev) { "⬇️" } else { "➡️" }
    $coverageColor = if ($q.test_coverage -ge 80) { $Green } else { $Yellow }
    Write-Host "   Test Coverage:   " -NoNewline
    Write-ColorOutput "$($q.test_coverage)% (was $($q.test_coverage_prev)%) $coverageTrend" $coverageColor
    
    # Standards compliance
    $complianceColor = if ($q.standards_compliance -eq 100) { $Green } else { $Yellow }
    Write-Host "   Standards:       " -NoNewline
    Write-ColorOutput "$($q.standards_compliance)%" $complianceColor
    
    # Errors
    $errorsColor = if ($q.lint_errors -eq 0 -and $q.type_errors -eq 0) { $Green } else { $Red }
    Write-Host "   Lint/Type Errors:" -NoNewline
    Write-ColorOutput " $($q.lint_errors) / $($q.type_errors)" $errorsColor
    
    # Performance violations
    $perfTrend = if ($q.perf_violations -lt $q.perf_violations_prev) { "⬆️" } else { "➡️" }
    $perfColor = if ($q.perf_violations -eq 0) { $Green } else { $Yellow }
    Write-Host "   Perf Violations: " -NoNewline
    Write-ColorOutput "$($q.perf_violations) (was $($q.perf_violations_prev)) $perfTrend" $perfColor
    
    Write-Host ""
}

function Show-Bottlenecks {
    param($Metrics)
    
    Write-ColorOutput "🔍 Bottlenecks Detected" $Cyan
    Write-Host ""
    
    $bottlenecks = @()
    
    # Check triage accuracy
    if ($Metrics.automation.triage_routing_accuracy -lt 90) {
        $bottlenecks += @{
            Category = "Automation"
            Issue    = "triage-agent routing accuracy: $($Metrics.automation.triage_routing_accuracy)%"
            Target   = "90%"
            Action   = "Review routing patterns for common misroutes"
        }
    }
    
    # Check test coverage
    if ($Metrics.quality.test_coverage -lt 80) {
        $bottlenecks += @{
            Category = "Quality"
            Issue    = "Test coverage: $($Metrics.quality.test_coverage)%"
            Target   = "80%"
            Action   = "Use test-generator for new code"
        }
    }
    
    # Check agent response time
    if ($Metrics.agents.avg_response_time_seconds -gt 5) {
        $bottlenecks += @{
            Category = "Performance"
            Issue    = "Agent response time: $($Metrics.agents.avg_response_time_seconds)s"
            Target   = "5s"
            Action   = "Optimize agent prompts"
        }
    }
    
    # Check least used agents
    if ($Metrics.agents.least_used.Count -gt 0) {
        $bottlenecks += @{
            Category = "Utilization"
            Issue    = "Underutilized agents: $($Metrics.agents.least_used -join ', ')"
            Target   = "Regular usage"
            Action   = "Consider deprecating or integrating"
        }
    }
    
    if ($bottlenecks.Count -eq 0) {
        Write-ColorOutput "✅ No bottlenecks detected!" $Green
    }
    else {
        foreach ($b in $bottlenecks) {
            Write-Host "   ⚠️ [$($b.Category)] $($b.Issue)"
            Write-Host "      Target: $($b.Target)"
            Write-Host "      Action: $($b.Action)"
            Write-Host ""
        }
    }
}

function Show-Recommendations {
    param($Metrics)
    
    Write-ColorOutput "💡 AI Recommendations" $Cyan
    Write-Host ""
    
    $recommendations = @()
    
    # Based on metrics
    if ($Metrics.velocity.tasks_per_day -lt 5) {
        $recommendations += "Use code-generator-agent more for boilerplate tasks"
    }
    
    if ($Metrics.automation.triage_routing_accuracy -lt 90) {
        $recommendations += "Update triage-agent patterns for better routing"
    }
    
    if ($Metrics.quality.test_coverage -lt 80) {
        $recommendations += "Enable test-generator for all new code"
    }
    
    if ($Metrics.quality.perf_violations -gt 0) {
        $recommendations += "Review performance budgets with performance-check.ps1"
    }
    
    if ($Metrics.agents.least_used.Count -gt 2) {
        $recommendations += "Consider consolidating or deprecating unused agents"
    }
    
    if ($recommendations.Count -eq 0) {
        Write-ColorOutput "✅ System is performing optimally!" $Green
    }
    else {
        $priority = 0
        foreach ($r in $recommendations) {
            $priority++
            $prioLabel = if ($priority -le 2) { "HIGH" } elseif ($priority -le 4) { "MEDIUM" } else { "LOW" }
            $prioColor = if ($priority -le 2) { $Red } elseif ($priority -le 4) { $Yellow } else { $Green }
            Write-Host "   " -NoNewline
            Write-ColorOutput "[$prioLabel]" $prioColor -NoNewline
            Write-Host " $r"
        }
    }
    
    Write-Host ""
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

$Metrics = Get-Metrics

if ($Dashboard -or (-not $ROI -and -not $Quality -and -not $Bottlenecks -and -not $Recommendations)) {
    Show-Dashboard $Metrics
    Show-Bottlenecks $Metrics
}
elseif ($ROI) {
    Show-ROI $Metrics
}
elseif ($Quality) {
    Show-Quality $Metrics
}
elseif ($Bottlenecks) {
    Show-Bottlenecks $Metrics
}
elseif ($Recommendations) {
    Show-Recommendations $Metrics
}

# Export if requested
if ($Export) {
    # TODO: Export to markdown
    Write-Host "Exporting to $Export..."
}
