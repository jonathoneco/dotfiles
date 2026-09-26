# Filing and grooming

Read this before writing tickets to the tracker, or before grooming a project that already has tickets. Read the project's tracker doc too: it sets fields, labels, the estimate scale, and milestones, and it holds that tracker's quirks. Set every field it names. When you hit a quirk it doesn't list, add it there.

## Filing a batch

1. **Wait for the go.** Nothing is written to the tracker until the user gives the go for this effort, in the words they named for it (such as "file the batch"). Until then tickets are drafts in the effort's folder.
2. **Make every pointer openable.** Rewrite local draft names to tracker keys, inline anything that points into a notes folder or `/tmp`, and confirm the SHA each ticket was read at.
3. **Re-read before each write, read back after.** Fetch the ticket's current state before changing it, and compare the written ticket against its draft afterwards. Your own receipt comments change a ticket's updated time, so a staleness check compares content, not timestamps.
4. **Close with a receipt.** Every close, merge, or move gets a comment saying why and where the work went. A condensed ticket lists the tickets it absorbed as acceptance checks; each absorbed ticket closes as a duplicate of it.
5. **Keep a filing log** in the effort's folder: one line per write, with the ticket, the operation, and the result.

Done when every drafted ticket is filed and reads back as drafted, every close carries a receipt, and the log has a line for each write.

## Grooming a project

1. **Settle what has merged.** For each ticket, check `main` for the work before believing its status. Work that merged but doesn't finish the ticket stays open with what remains stated.
2. **Reshape.** Apply the sizing and relationship rules in [`SKILL.md`](SKILL.md): fold duplicates, condense repeated patterns into one ticket, move each finding to the project that owns it. Moving a ticket to another project settles where it lives; the ticket still gets groomed there.
3. **Bring back a groomed project** before anyone drives it: what closed, what merged, what moved, and what is ready.

## Tracker budget

Trackers rate-limit per user, and a batch shares that limit with every other tool on the account. Read each ticket body once per batch, cache the full body, and write from the cache.
