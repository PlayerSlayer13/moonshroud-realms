# Moonshroud Realms — Deploy Workflow Reference

Keep this open whenever you're pushing changes. Three repos, and the rule that trips
things up every time: **pushing to a source repo never updates the GM site by itself.**
The GM site only updates when its own submodule pointers get bumped, separately, every
single time.

---

## The three repos

| Repo | Local path | What lives here |
|---|---|---|
| `moonshroud-realms` | `C:\Projects\moonshroud-realms` | The public site (playerslayer.net). Everything players can see. |
| `moonshroud-realms-secrets` | `C:\Projects\moonshroud-realms-secrets` | GM-only content: World Secrets, Campaign Secrets, Atlas. Private repo. |
| `moonshroud-realms-gm` | `C:\Projects\moonshroud-realms-gm` | The GM site (gm.playerslayer.net). Doesn't hold real content itself — it pulls in the other two repos plus the theme as **submodules** and merges them at build time. |

---

## Step 1 — Push your actual changes

Edit files, then from inside whichever repo you changed:

```
git add -A
git commit -m "Describe what changed"
git push
```

Do this in `moonshroud-realms` if you edited public content. Do this in
`moonshroud-realms-secrets` if you edited GM-only content. **If you changed both in one
session, you do this step twice, once in each repo.**

At this point: the public site (playerslayer.net) is already updated, if you pushed to
`moonshroud-realms` — its own GitHub Action rebuilds it automatically on every push, no
extra step needed. **The GM site has not updated yet, no matter which repo you just
pushed to.** That's Step 2, always.

---

## Step 2 — Sync the GM site (do this after EVERY push, to either source repo)

Always start these from a fresh terminal, or explicitly `cd` to the full path shown —
don't chain `cd ..` from wherever you happened to be for Step 1. `moonshroud-realms-secrets`
(the real repo) and `moonshroud-realms-gm\secrets` (a submodule folder with a similar name
inside a different repo) are easy to mix up, and relative `cd ..` is exactly how that
mix-up happens.

**If you pushed to `moonshroud-realms` (public content):**
```
cd C:\Projects\moonshroud-realms-gm\main-site
git pull origin main
cd C:\Projects\moonshroud-realms-gm
git add main-site
git commit -m "Update main-site submodule to latest"
git push
```

**If you pushed to `moonshroud-realms-secrets` (GM-only content):**
```
cd C:\Projects\moonshroud-realms-gm\secrets
git pull origin main
cd C:\Projects\moonshroud-realms-gm
git add secrets
git commit -m "Update secrets submodule to latest"
git push
```

**If you pushed to BOTH in the same session, run BOTH blocks above, one after the
other.** They don't interfere with each other — `main-site` and `secrets` are
independent folders inside `moonshroud-realms-gm`.

---

## Step 3 — Check it actually built

Go to `moonshroud-realms-gm` on GitHub → **Actions tab**. Wait for the latest run to go
green (1–3 minutes typically). If it's red, click into it → click the failed **build**
step → read the actual error line (usually starts with `ERROR`) and send that to me
directly rather than just "it's not working" — that error line almost always says
exactly which file and what's wrong.

Then check the GM site in an **incognito window** (not a regular tab) to rule out
browser caching as a false alarm.

---

## Quick decision tree

- "I changed something on the public site and want it live on gm.playerslayer.net too" →
  Step 1 in `moonshroud-realms`, then Step 2's **main-site** block.
- "I changed a GM-only secret/atlas file" → Step 1 in `moonshroud-realms-secrets`, then
  Step 2's **secrets** block.
- "I did both" → both Step 1's, then both Step 2 blocks.
- "The GM site still looks wrong after all that" → Step 3. Check Actions first, before
  assuming anything about caching or waiting longer.

---

## Separate: updating the campaign date

Different tool entirely — `update-campaign-date.ps1` (in `moonshroud-realms\scripts\`)
handles moving the in-game date forward. It already runs Step 1 AND Step 2's main-site
block for you automatically, since a date change only ever touches the public repo. Run
it, confirm the diff it shows you, let it push both repos, then still do Step 3 to
confirm the build went green.

```
.\update-campaign-date.ps1 -MonthName "Frostwatch" -Day 12
```

This script does **not** touch the `secrets` submodule — if you also changed GM-only
content in the same sitting, you still need Step 2's secrets block by hand afterward.
