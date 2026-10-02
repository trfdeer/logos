---
name: budget-categorize
description: >-
  Assign the correct Actual Budget category (and tags) to an expense, income,
  or transfer using the m2mig taxonomy. Use when the user asks where a
  purchase, payment, or income item should be categorized, asks to review or
  bulk-categorize transactions, or asks about the budget taxonomy, groups, or
  tagging rules.
---

# Categorize Transactions

Assign each transaction to exactly **one** category from the fixed taxonomy
below, plus zero or more tags. Never invent categories: if nothing fits, use
`Unsorted/Misc` and say so. The full background lives in
`docs/budget-taxonomy.md` (funding rules and one-time cleanup live there; this
skill is the per-transaction decision procedure).

## The taxonomy

| Group         | Categories                                                                                                                                                |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Bills & Fixed | Rent · Electricity · Water · Internet · Mobile · Trash Disposal · Health Insurance · Subscriptions · Digital Tools · Home Trips                           |
| Essentials    | Meal · Groceries · Household · Public Transport · Fuel · Medicines · Hygiene · Laundry · College · Food (Other)                                           |
| Lifestyle     | Eating Out · Cab · Games · Movies/Concerts · Clothing · Vacations/Trips · Gifts · Donation · Purchases (Other)                                            |
| Irregular     | Major Purchases · Vehicle Maintenance · Home Maintenance · Shifting · Deposit · Income Tax · Government Fees / Documents · Family Support · Work Expenses |
| Income        | Salary · Freelance · Bonus · Allowance · Interest · Cashback · Refund · Gift · Balance Adjustments · Other Income                                         |
| Investments   | Mutual Funds · Pension · Securities · Physical Assets                                                                                                     |
| Finance       | Card Fees · Bank Fees                                                                                                                                     |
| Unsorted      | Misc                                                                                                                                                      |

Category definitions that aren't obvious from the name:

- **Home Trips** — the monthly home↔work-city commute: flight, airport cabs on
  both ends, travel-day food.
- **Meal** — regular food from the local mess/eateries. Groceries = food bought
  to cook. Eating Out = restaurants (Fast Food merged in).
- **Household** — daily household consumables and small replacements: bulbs,
  garbage bags, cleaning supplies, small kitchen items.
- **Digital Tools** — quietly-renewing online services: email, domains, cloud
  storage, non-work AI subscriptions.
- **Securities** — marketable/paper investments outside mutual funds: direct
  stocks, ETFs, bonds, SGBs, digital gold, FDs.
- **Physical Assets** — gold/silver/metal bought to _hold_ value (coins, bars).
  Metal you wear (jewellery with making charges) is consumption →
  `Major Purchases`. Paper gold (ETFs, SGBs, digital gold) → `Securities`.
- **Shifting** — moving house costs, _including_ agent/brokerage fees.
- **Government Fees / Documents** — official one-off fees: driving license
  issuing/renewal, passport, vehicle registration/RC, certified copies. Not
  transport (no ride happened) and not Purchases (Other) — they're mandatory,
  not discretionary. Keep `Income Tax` separate: it's a large annual lump;
  document fees are small and sporadic.
- **Family Support** — money given to support family members (parents,
  grandparents, siblings): cash transfers, covering their bills/travel/medical.
  Not `Gifts` — Gifts is occasional present-giving; Family Support is ongoing
  support for people you're responsible for. Bought-for-them items on their
  behalf (e.g., their train tickets) also go here, not Gifts.
- **Work Expenses** — costs incurred to earn freelance/work income: referral
  or commission fees paid to introducers, work-specific tools and subscriptions.
  The matching expense side of `Freelance` income: record the income **gross**
  and the commission as a separate expense — never net them. Tag both `#work`.
  Rare spend, so it lives under Irregular; promote out if freelancing picks up.
- **Purchases (Other)** — small discretionary buys and one-offs (occasional
  books, cables, accessories). A waiting room, not a landfill.
- **Balance Adjustments** — opening/correction balance entries, not real income.

## Core rules (apply in order)

1. **Transfers are never categorized.** Money moving between the user's own
   accounts is category-less. Off-budget (investment) accounts cannot hold
   categories at all.
2. **Purpose beats type.** Categorize by _why_ the money was spent, not by what
   the receipt looks like. The same payee can land in different categories:
   a flight home in the monthly commute → Home Trips; a leisure flight →
   Vacations/Trips. An airport cab → Home Trips; a discretionary city cab →
   Cab; a cab to an exam hall → College.
3. **Replacement vs acquisition.** Replacing something the user already had →
   Maintenance (Home or Vehicle). Buying something they didn't have → Major
   Purchases. A 50k battery backup because the old one died → Home
   Maintenance; a 50k home theater → Major Purchases. New tires → Vehicle
   Maintenance; a new bike → Major Purchases.
4. **The threshold.** ~₹2,000 and/or built to last years separates
   Household/Maintenance from Major Purchases. A ₹200 bulb → Household; a
   ₹4,000 vacuum → Major Purchases; ₹5,000 good headphones → Major Purchases.
5. **Subscriptions tree.** Would the user cancel it to save money? →
   `Subscriptions` (Lifestyle). Is it for earning money (freelance work)? →
   `Work Expenses` (suggest creating it if it doesn't exist). Does it quietly
   renew (email, domain, cloud, AI)? → `Digital Tools`. Annual bills (domain
   registrar): note that the budget is annual ÷ 12.
6. **Habits vs events.** A recurring habit (a book most months) deserves its
   own envelope; a one-off goes to Purchases (Other). If the same kind of spend
   shows up in a catch-all 2–3 times, suggest promoting it to its own category.
7. **Donations** (temple, festivals, charity) → `Donation`. Festival
   seasonality is a budgeting concern (rollover), not a categorization one —
   do not invent festival categories unless the whole season bundle is being
   planned as one number.
8. **Income** → the matching Income category. Reimbursements/refunds → `Refund`
   (kept separate for reimbursement tracking). Cashback → `Cashback`. Salary →
   `Salary`, freelance → `Freelance`, interest → `Interest`.
9. **Ambiguity policy.** Pick the single best category, then state the
   assumption in one line. If two categories are genuinely defensible, say so
   and let the user pick — do not split the amount.

## Worked examples

| Transaction                                    | Category                                | Why                                                  |
| ---------------------------------------------- | --------------------------------------- | ---------------------------------------------------- |
| Monthly flight home (₹4,500)                   | Bills & Fixed / Home Trips              | routine commute, not leisure                         |
| Cab to the airport (both ends)                 | Bills & Fixed / Home Trips              | part of the trip's cost                              |
| Cab to an exam hall                            | Essentials / College                    | cost of the commitment                               |
| Goa trip: flights, hotel, cabs                 | Lifestyle / Vacations/Trips             | leisure purpose; tag `#goa-2026` for total-trip cost |
| Battery backup dies, new one ₹50,000           | Irregular / Home Maintenance            | replacement of existing home infrastructure          |
| New home theater ₹50,000                       | Irregular / Major Purchases             | acquisition, not replacement                         |
| Bulb because the last one broke (₹200)         | Essentials / Household                  | small daily replacement                              |
| Garbage bags, dish soap, cleaning supplies     | Essentials / Household                  | house-running consumables                            |
| Mess/tiffin monthly bill                       | Essentials / Meal                       | regular food                                         |
| Restaurant dinner, food delivery               | Lifestyle / Eating Out                  | discretionary food                                   |
| Spotify, Netflix                               | Lifestyle / Subscriptions               | would cancel to save money                           |
| Email hosting, cloud storage, domain renewal   | Bills & Fixed / Digital Tools           | quietly renews                                       |
| AI subscription used for freelance work        | (Work Expenses)                         | earning money; suggest the category if missing       |
| Non-fiction book (occasional)                  | Lifestyle / Purchases (Other)           | one-off                                              |
| Books twice a month                            | (Books)                                 | habit → suggest promoting to its own envelope        |
| Phone case ₹400, USB cable ₹300                | Lifestyle / Purchases (Other)           | small accessory, under threshold                     |
| Temple donation ₹500, Diwali pandal collection | Lifestyle / Donation                    | donations are donations; payee records the festival  |
| Exam printing, photocopies                     | Essentials / College                    | academic misc                                        |
| Card annual fee, ATM charge                    | Finance / Card Fees or Bank Fees        | banking costs                                        |
| Salary credit                                  | Income / Salary                         | —                                                    |
| UPI cashback                                   | Income / Cashback                       | —                                                    |
| Refund for a returned item                     | Income / Refund                         | reimbursement tracking                               |
| Rent deposit top-up                            | Irregular / Deposit                     | —                                                    |
| Moving house costs incl. agent/broker fee      | Irregular / Shifting                    | agent fee is a transaction cost of the move          |
| Driving license issuing fee                    | Irregular / Government Fees / Documents | mandatory official fee, not a ride or purchase       |
| Monthly transfer to parents                    | Irregular / Family Support              | ongoing support for family, not occasional gifting   |
| 20% referral fee on a freelance job            | Irregular / Work Expenses               | cost of earning the income; income logged gross      |
| Monthly SIP into a fund                        | Investments / Mutual Funds              | —                                                    |
| PPF contribution                               | Investments / Pension                   | retirement-oriented lock-in                          |
| Direct stocks, ETFs, bonds, FDs                | Investments / Securities                | marketable/paper investments                         |
| Gold coins/bars bought to hold                 | Investments / Physical Assets           | held as metal, not worn; jewellery → Major Purchases |

## Transport routing

| Ride                                     | Category                      |
| ---------------------------------------- | ----------------------------- |
| Daily commute (bus/train/metro)          | Essentials / Public Transport |
| Own vehicle fuel                         | Essentials / Fuel             |
| Discretionary city rides                 | Lifestyle / Cab               |
| Airport, both ends                       | Bills & Fixed / Home Trips    |
| Exam halls / institution-mandated travel | Essentials / College          |

## Tags

Tags are hashtags inside the transaction's **notes** — they carry
cross-cutting context that cuts across categories. Tags never replace the
category decision.

- Syntax: `#tag` anywhere in notes. No whitespace inside a tag
  (`#camelCase`, `#snake_case` fine). Multiple tags per transaction allowed.
  Case-sensitive: `#tax` ≠ `#Tax`. `##` escapes a literal `#`.
- **Trip tags:** tag every transaction of a specific trip (across whatever
  categories it touches) so a filter gives total trip cost:
  `#goa-2026`, `#diwali-home`.
- **Recurring cross-cutting contexts** worth standardizing:
  `#reimburse` (will be paid back), `#tax` (tax-relevant), `#work` (freelance
  expense), `#gift-for` (gifts bought for others).
- When bulk-tagging history, prefer a rule (`notes contains X → append #tag`)
  over hand-editing.
- Suggest a tag only when it answers a question a category can't ("what did
  the whole trip cost", "how much is reimbursable") — not as decoration.

## Output format

For each transaction: **Group / Category**, then tags if any, then a one-line
reason or assumption when the choice isn't obvious. When suggesting a new
category (habit promotion, Work Expenses), call it out explicitly instead of
silently using a catch-all. For batches, group decisions by payee first and
confirm the payee→category mapping before applying.
