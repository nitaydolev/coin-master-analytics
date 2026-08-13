# Coin Master Analytics

SQL queries behind a full gaming analytics project: player behaviour traced from the first tutorial step through to the decision to pay, across three datasets. The core one holds 15.8M events from 26,576 players. 98% of them opened the store. 1.68% ever paid. These queries are how that was found, and what was proposed about it.

**Report:** [Google Doc](https://docs.google.com/document/d/17EkVPeVozpzkGG3yJgopeiF0uiVC8PaixIzPyPnO27k/edit?usp=sharing)
**Dashboard:** [Looker Studio](https://datastudio.google.com/u/0/reporting/b5641790-f0f8-4c83-800a-b65caf10b76a/page/p_20u3ip1d6d)

Data is synthetic, from the PPLTX analytics academy, and some figures do not behave like a live product. The methods are built to hold on real data; the numbers they return are not benchmarks. Everything runs in Google BigQuery.

---

## Read in this order

| Folder | What it answers |
|---|---|
| `tutorial/` | Do players finish onboarding, and does it teach them the game? |
| `main-kpis/` | How many play, how long they stay, and what they are worth |
| `product/` | Where the store funnel leaks |
| `dashboard/` | Serving tables behind the Looker Studio dashboard |

Folders are listed alphabetically by GitHub. The order above is the analytical one.

Every `.sql` file opens with a comment block: what it computes, at what grain, and why.

---

## Data sources

Three separate datasets, each suited to a different question.

| Dataset | Used by | Why |
|---|---|---|
| `final_project.tutorial` | `tutorial/` | Onboarding events across nine steps and five app versions |
| `final_project.fact` | `main-kpis/`, `product/` | 15.8M events from a closed install cohort, right for cohort economics |
| `PlayPltx` | `dashboard/` | Continuous daily installs, with country and platform, right for an operational dashboard |

---

## Notes

1. Inside `main-kpis/`, `build/` creates the derived tables, `kpis/` holds the metrics that read from them, and `validation/` holds the data quality checks. Run `build/` first.
2. CPI and ROAS are not computed. They need ad spend, which the source data does not have.