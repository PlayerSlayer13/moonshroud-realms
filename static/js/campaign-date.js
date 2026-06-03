// ============================================================
// Campaign Date — single source of truth
// Update these three values after each session.
// ============================================================

const CAMPAIGN_MONTH_NAMES = [
  "Wintermark",   // 0
  "Dawnsreach",   // 1
  "Brightening",  // 2
  "Rainmoot",     // 3
  "Bloomtide",    // 4
  "Goldmantle",   // 5
  "Highsun",      // 6
  "Emberwane",    // 7
  "Harvestide",   // 8
  "Frostwatch",   // 9
  "Redleaf",      // 10
  "Long Dusk",    // 11
  "Wandering"     // 12
];

const CAMPAIGN_DATE = {
  year:  700,
  month: 8,    // 0-indexed — Harvestide
  day:   23
};

// Derived label — do not edit this line
CAMPAIGN_DATE.label = CAMPAIGN_MONTH_NAMES[CAMPAIGN_DATE.month] + ", Day " + CAMPAIGN_DATE.day + ", " + CAMPAIGN_DATE.year + "AG";
