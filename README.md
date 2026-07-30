# Coin Master Analytics

Gaming analytics capstone project. SQL, KPI modelling, dashboard design and A/B test planning for a free to play mobile title.

## About

Coin Master (Moon Active) is used as the analytical framing. The underlying data is synthetic course data from PPLTX and does not represent the real game.

The dataset covers 26,576 users over a 1,355 day window. All users installed inside a 70 day window, so this is a closed cohort: a retention and monetization story rather than an acquisition one.

## Repository structure

queries/main-kpis/build/       source of truth table, user-day grain
queries/main-kpis/kpis/        acquisition, engagement, monetization, retention
queries/main-kpis/validation/  data quality checks
queries/product/               analysis behind the feature proposal
queries/tutorial/              funnel and time to complete

## Selected findings

Revenue fell 98% between 2022 and 2024 while ARPDAU held between $0.0575 and $0.0516. The decline is a volume story, not a monetization one.

84% of users reached the checkout and did not pay. 22,382 started a purchase and cancelled it, against 446 who completed one.

Classic day-N retention rises with day number, an artifact of sparse activity. Rolling retention is the usable curve: 83.05% at D30.

## Tools

BigQuery, Google Data Studio, VS Code, G*Power.