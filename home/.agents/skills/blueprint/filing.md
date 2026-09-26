# Filing and grooming

Writing tickets to the tracker, and grooming a project that already has tickets. The project's tracker doc holds that tracker's quirks; when you hit one it doesn't list, add it there.

Write to the tracker only after the user gives the go for this effort, in the words they named for it (such as "file the batch"). Until then tickets are drafts in the effort's folder, and grooming changes are a proposal.

Trackers rate-limit per user, and a batch shares that limit with every other tool on the account. Read each ticket once per operation, and write from what you read.

## Filing a batch

1. **Map drafts to the tracker.** Rewrite local draft names to tracker keys, and confirm the SHA each ticket was read at.
2. **Read once before each write, read back once after.** Fetch the ticket's current body just before changing it, then compare the written ticket against its draft. Your own receipt comments change a ticket's updated time, so a staleness check compares content, not timestamps.
3. **Close with a receipt.** Every close, merge, or move gets a comment saying why and where the work went. A condensed ticket lists each absorbed ticket's key beside the place it covers; each absorbed ticket closes as a duplicate of it.
4. **Keep a filing log** in the effort's folder: one line per write, with the ticket, the operation, and the result.

Done when every drafted ticket is filed and reads back as drafted, every close carries a receipt, and the log has a line for each write.

## Grooming a project

1. **Settle what has merged.** For each ticket, check `main` for the work before believing its status. Work that merged but doesn't finish the ticket stays open with what remains stated.
2. **Propose the reshape.** Apply the sizing and relationship rules in [`SKILL.md`](SKILL.md): fold duplicates, condense repeated patterns into one ticket, move each finding to the project that owns it. Moving a ticket to another project settles where it lives; the ticket still gets groomed there. Bring the proposal to the user: what closes, what merges, what moves, and what is ready.
3. **Apply it after the go**, by the filing steps above.

Done when every ticket is closed with a receipt, open with what remains stated, or moved, and the user has the groomed project.
