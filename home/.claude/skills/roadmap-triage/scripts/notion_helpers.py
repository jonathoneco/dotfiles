"""Reusable helpers for in-place Notion roadmap-mirror edits.

Loads the Notion token from the gitignored `.mcp.json` at the repo root.
Never echo the token in output — these helpers keep it local to function scope.

Block alphabet (per wrangle-notion-capture HOUSE-STYLE):
    heading_2, paragraph, bulleted_list_item, numbered_list_item, code, divider.
NEVER callout, toggle, child_page, mention-typed rich_text, to_do, is_toggleable headings.

Example use::

    from notion_helpers import (
        client, find_block_by_text,
        patch_block_rich_text, insert_after, delete_block,
        plain, linked, code, bold, bold_link, gh_url,
        numbered_item, bulleted_item, paragraph,
    )

    nc = client()
    page_id = "363884ec-3621-81e8-9487-c59835d411a1"

    # Find a block by text prefix
    target = find_block_by_text(nc, page_id, "#161 Batched live-deploy")

    # Append " (R4A, bug)" to a paragraph's rich_text
    blk = nc.get(f"/v1/blocks/{target['id']}")
    rt = blk["paragraph"]["rich_text"]
    rt.append(plain(" (R4A, bug)"))
    patch_block_rich_text(nc, target["id"], "paragraph", rt)

    # Insert a new numbered list item after another block
    new_blk = numbered_item([
        bold_link("#306", gh_url(306)),
        plain(" LO file-delete affordance — "),
        code("[Build · Critical · LO surface · R4H feature]"),
    ])
    insert_after(nc, page_id, target["id"], [new_blk])

    # Drop a block
    delete_block(nc, target["id"])
"""

from __future__ import annotations

import json
import urllib.request
from pathlib import Path
from typing import Any

NOTION_API_HOST = "https://api.notion.com"  # path arg should start with `/v1/...`
NOTION_VERSION = "2022-06-28"
DEFAULT_MCP_PATH = Path("/home/jonco/src/wrangle/.mcp.json")
GH_ISSUE_BASE = "https://github.com/jonathoneco/wrangle/issues"


# ---------------------------------------------------------------------------
# Client
# ---------------------------------------------------------------------------


class NotionClient:
    """Minimal Notion REST client. Token never appears in str(self)."""

    def __init__(self, token: str):
        self._token = token

    def _headers(self, content_type: bool = False) -> dict[str, str]:
        h = {
            "Authorization": f"Bearer {self._token}",
            "Notion-Version": NOTION_VERSION,
        }
        if content_type:
            h["Content-Type"] = "application/json"
        return h

    def get(self, path: str) -> dict[str, Any]:
        req = urllib.request.Request(NOTION_API_HOST + path, headers=self._headers())
        return json.load(urllib.request.urlopen(req))

    def patch(self, path: str, payload: dict[str, Any]) -> dict[str, Any]:
        req = urllib.request.Request(
            NOTION_API_HOST + path,
            data=json.dumps(payload).encode(),
            headers=self._headers(content_type=True),
            method="PATCH",
        )
        return json.load(urllib.request.urlopen(req))

    def post(self, path: str, payload: dict[str, Any]) -> dict[str, Any]:
        req = urllib.request.Request(
            NOTION_API_HOST + path,
            data=json.dumps(payload).encode(),
            headers=self._headers(content_type=True),
            method="POST",
        )
        return json.load(urllib.request.urlopen(req))

    def delete(self, path: str) -> dict[str, Any]:
        req = urllib.request.Request(
            NOTION_API_HOST + path,
            headers=self._headers(),
            method="DELETE",
        )
        return json.load(urllib.request.urlopen(req))

    def __repr__(self) -> str:  # never leak the token
        return "NotionClient(token=<redacted>)"


def client(mcp_path: Path = DEFAULT_MCP_PATH) -> NotionClient:
    """Load the Notion token from .mcp.json and return a NotionClient."""
    token = json.loads(mcp_path.read_text())["mcpServers"]["notion"]["env"]["NOTION_TOKEN"]
    return NotionClient(token)


# ---------------------------------------------------------------------------
# Rich-text builders
# ---------------------------------------------------------------------------


def plain(text: str) -> dict[str, Any]:
    return {"type": "text", "text": {"content": text}}


def linked(text: str, url: str) -> dict[str, Any]:
    return {"type": "text", "text": {"content": text, "link": {"url": url}}}


def code(text: str) -> dict[str, Any]:
    return {"type": "text", "text": {"content": text}, "annotations": {"code": True}}


def bold(text: str) -> dict[str, Any]:
    return {"type": "text", "text": {"content": text}, "annotations": {"bold": True}}


def bold_link(text: str, url: str) -> dict[str, Any]:
    return {
        "type": "text",
        "text": {"content": text, "link": {"url": url}},
        "annotations": {"bold": True},
    }


def gh_url(issue_number: int) -> str:
    """Canonical GitHub URL for a wrangle issue."""
    return f"{GH_ISSUE_BASE}/{issue_number}"


# ---------------------------------------------------------------------------
# Block builders
# ---------------------------------------------------------------------------


def _wrap(block_type: str, rich_text: list[dict[str, Any]]) -> dict[str, Any]:
    return {"object": "block", "type": block_type, block_type: {"rich_text": rich_text}}


def paragraph(rich_text: list[dict[str, Any]]) -> dict[str, Any]:
    return _wrap("paragraph", rich_text)


def heading_2(rich_text: list[dict[str, Any]]) -> dict[str, Any]:
    return _wrap("heading_2", rich_text)


def bulleted_item(rich_text: list[dict[str, Any]]) -> dict[str, Any]:
    return _wrap("bulleted_list_item", rich_text)


def numbered_item(rich_text: list[dict[str, Any]]) -> dict[str, Any]:
    return _wrap("numbered_list_item", rich_text)


def code_block(content: str, language: str = "plain text") -> dict[str, Any]:
    return {
        "object": "block",
        "type": "code",
        "code": {
            "rich_text": [{"type": "text", "text": {"content": content}}],
            "language": language,
        },
    }


def divider() -> dict[str, Any]:
    return {"object": "block", "type": "divider", "divider": {}}


# ---------------------------------------------------------------------------
# Block ops
# ---------------------------------------------------------------------------


def get_children(nc: NotionClient, parent_id: str, page_size: int = 100) -> list[dict[str, Any]]:
    """Return all top-level children of `parent_id`. Single page only; paginate manually if needed."""
    return nc.get(f"/v1/blocks/{parent_id}/children?page_size={page_size}")["results"]


def find_block_by_text(
    nc: NotionClient,
    parent_id: str,
    text_match: str,
    block_type: str | None = None,
) -> dict[str, Any] | None:
    """Find the first child block whose rendered plain_text starts with `text_match`.

    Optionally filter by block type ("numbered_list_item", "paragraph", etc.).
    """
    for blk in get_children(nc, parent_id):
        t = blk["type"]
        if block_type and t != block_type:
            continue
        rich_text = blk.get(t, {}).get("rich_text", [])
        rendered = "".join(r.get("plain_text", "") for r in rich_text)
        if rendered.startswith(text_match) or text_match in rendered:
            return blk
    return None


def patch_block_rich_text(
    nc: NotionClient,
    block_id: str,
    block_type: str,
    new_rich_text: list[dict[str, Any]],
) -> dict[str, Any]:
    """Replace a block's rich_text array. `block_type` must match the block's actual type
    (paragraph / numbered_list_item / bulleted_list_item / heading_2)."""
    return nc.patch(
        f"/v1/blocks/{block_id}",
        {block_type: {"rich_text": new_rich_text}},
    )


def insert_after(
    nc: NotionClient,
    parent_id: str,
    after_block_id: str,
    new_blocks: list[dict[str, Any]],
) -> dict[str, Any]:
    """Insert `new_blocks` immediately after `after_block_id` within `parent_id`."""
    return nc.patch(
        f"/v1/blocks/{parent_id}/children",
        {"children": new_blocks, "after": after_block_id},
    )


def append_children(
    nc: NotionClient,
    parent_id: str,
    new_blocks: list[dict[str, Any]],
) -> dict[str, Any]:
    """Append new blocks at the END of a parent's children list."""
    return nc.patch(f"/v1/blocks/{parent_id}/children", {"children": new_blocks})


def delete_block(nc: NotionClient, block_id: str) -> dict[str, Any]:
    """Soft-delete (archive) a block. Reversible via PATCH archived=false within 30 days."""
    return nc.delete(f"/v1/blocks/{block_id}")


# ---------------------------------------------------------------------------
# Verification helpers
# ---------------------------------------------------------------------------


def render_text(blk: dict[str, Any]) -> str:
    """Render a block's plain_text content for grep verification."""
    t = blk.get("type", "")
    rich_text = blk.get(t, {}).get("rich_text", [])
    return "".join(r.get("plain_text", "") for r in rich_text)


def verify_mirror(
    nc: NotionClient,
    parent_id: str,
    expectations: dict[str, str],
) -> dict[str, bool]:
    """Confirm each expected text fragment appears in some child block.

    `expectations` maps a label → text-fragment-that-must-be-found.
    Returns label → True/False.
    """
    rendered = [render_text(b) for b in get_children(nc, parent_id)]
    return {label: any(fragment in r for r in rendered) for label, fragment in expectations.items()}
