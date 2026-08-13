# Coin Master Analytics

SQL for a gaming analytics project: player behaviour from the first tutorial step through to the decision to pay.

**Report:** [Google Doc](link)
**Dashboard:** [Looker Studio](link)

Data is synthetic, from the PPLTX analytics academy. Everything runs in Google BigQuery.

---

## Read in this order

| Folder | What it answers |
|---|---|
| `tutorial/` | Do players finish onboarding, and does it teach them the game? |
| `main-kpis/` | How many play, how long they stay, and what they are worth |
| `product/` | Where the store funnel leaks |
| `dashboard/` | Serving tables behind the Looker Studio dashboard |

Folders are listed alphabetically by GitHub. The order above is the analytical one.

---

## Layout

```
queries/
├── tutorial/          funnel, drop-off, time to complete
├── main-kpis/
│   ├── build/         user_day_summary, the derived source of truth
│   ├── kpis/          acquisition, engagement, retention, monetization
│   └── validation/    data quality checks
├── product/           store funnel and cancellation analysis
└── dashboard/         daily_dashboard, retention
```

Every `.sql` file opens with a comment block: the KPI it computes, the grain of the output, and any decision that needed justifying.

---

## Notes

`main-kpis/build/user_day_summary.sql` runs first. Most other queries read from the table it creates.

CPI and ROAS are not computed. They need ad spend, which the source data does not have.

The dashboard runs on a second dataset with continuous daily installs, since the main dataset is a closed cohort.