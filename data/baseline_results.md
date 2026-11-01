# ClarityAI Product Analytics Baseline

**Snapshot date:** 2026-10-03  
**Scope:** External users only; owner accounts excluded.

This document records the aggregate results from the October 3, 2026 baseline analysis. It is a historical snapshot and is separate from the later Power BI dashboard dataset.

## 1. Basic Product Funnel

| Metric | Result |
|---|---:|
| External registered users | 69 |
| External users who analyzed | 46 |
| External users who never analyzed | 23 |
| External total analyses | 134 |

## 2. Analysis Frequency

| Analyses per user | Users |
|---:|---:|
| 1 | 31 |
| 2 | 7 |
| 3 | 2 |
| 5 | 4 |
| 7 | 1 |
| 56 | 1 |

One high-volume user accounts for 56 analyses. This is important context when interpreting overall activity.

## 3. One-Time vs Repeat Users

| Metric | Result |
|---|---:|
| External users who analyzed | 46 |
| One-time users | 31 |
| Repeat users | 15 |
| Repeat user percentage | 32.61% |

## 4. External Analysis Volume

| Metric | Result |
|---|---:|
| External total analyses | 134 |
| Analyses from one-time users | 31 |
| Analyses from repeat users | 103 |

## 5. Repeat Analysis Timing

A repeat analysis is compared with the user's immediately preceding analysis.

| Metric | Result |
|---|---:|
| Repeat analyses | 88 |
| Within 24 hours | 68 |
| Within 7 days | 79 |
| Within 24 hours | 77.27% |
| Within 7 days | 89.77% |

## 6. External Analysis Score Summary

| Metric | Result |
|---|---:|
| Minimum score | 5 |
| Average score | 77.71 |
| Median score | 85 |
| Maximum score | 100 |

## 7. Daily Analysis Activity

The original daily-level result table is intentionally not published because it contains many low-count date rows. The public SQL version uses weekly aggregation for this query instead. Re-run Query 7 in the SQL file to obtain the corresponding weekly aggregate output.

## 8. External Users Who Never Analyzed

| Metric | Result |
|---|---:|
| External users who never analyzed | 23 |
| Earliest signup month | March 2026 |
| Latest signup month | April 2026 |

Exact signup timestamps are intentionally omitted.

## 9. Job Tracker Adoption

| Metric | Result |
|---|---:|
| External registered users | 69 |
| Users using tracker | 3 |
| Total job applications | 3 |

## 10. Time to First Analysis

| Metric | Result |
|---|---:|
| External analyzed users | 46 |
| Average days to first analysis | 1.88 |
| Median days to first analysis | 0.00 |

## 11. Score Change Per Repeating User

| Metric | Result |
|---|---:|
| Repeat users | 15 |
| Average first score | 68.20 |
| Average latest score | 79.27 |
| Average score change | +11.07 |

This is an observed change between first and latest recorded scores. It does not establish that the product caused the improvement.

## 12. Weekly Signup & Activation

| Signup week | Signups | Analyzed | Never analyzed |
|---|---:|---:|---:|
| 2026-03-16 | 1 | 1 | 0 |
| 2026-03-23 | 9 | 6 | 3 |
| 2026-03-30 | 33 | 23 | 10 |
| 2026-04-06 | 18 | 12 | 6 |
| 2026-04-13 | 7 | 3 | 4 |
| 2026-04-27 | 1 | 1 | 0 |

## 13. Weekly Analysis Activity (Top User Excluded)

| Week | Analyses | Users |
|---|---:|---:|
| 2026-03-16 | 2 | 1 |
| 2026-03-23 | 5 | 5 |
| 2026-03-30 | 33 | 22 |
| 2026-04-06 | 20 | 15 |
| 2026-04-13 | 6 | 3 |
| 2026-04-20 | 4 | 2 |
| 2026-06-01 | 1 | 1 |
| 2026-07-06 | 2 | 1 |
| 2026-07-13 | 2 | 1 |
| 2026-08-03 | 1 | 1 |
| 2026-08-24 | 2 | 1 |

## 14. Score Change Distribution (Top User Excluded)

| Metric | Result |
|---|---:|
| Repeat users | 14 |
| Improved | 10 |
| Unchanged | 2 |
| Declined | 2 |
| Average change | 11.86 |
| Median change | 5.5 |

## 15. Score Data Completeness

| Metric | Result |
|---|---:|
| Total analyses | 134 |
| Null scores | 0 |

## Interpretation Notes

- These figures represent the October 3, 2026 baseline and must not be mixed with later dashboard figures.
- Repeat usage is not the same as retention. Retention requires measuring return activity across defined time periods or cohorts.
- Score changes are descriptive observations, not proof of causal product impact.
- The highest-volume user's activity materially affects total usage; the SQL includes separate analyses that exclude that user for comparison.
- Daily-level activity rows and exact signup timestamps were withheld from this public results document to reduce the risk of identifying individual users.
