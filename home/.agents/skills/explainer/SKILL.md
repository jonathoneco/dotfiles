---
name: explainer
description: Explain a design the conversation has settled as an artifact a reader can judge without reading the code, grounded in product behavior and the code that produces it. Use when Jon says show me the design, or asks for an artifact to understand a design, a flow, or a review's findings.
---

# Explainer

The bar: a reader who will judge the design without opening the code can see what each part does for the user, what the code does to make that happen, and where it differs from today. Built on what is already decided; never a fresh start.

## Grounding

- Every part is explained twice: what the user sees or gets, and what the code does about it, with the file or symbol that does it.
- One real, named example runs through the whole design end to end: a specific document, record, or incident, not a stand-in.
- Where the design changes something, today and the proposal appear on the same example, side by side, so the one difference stands out.
- Every number carries its source and denominator, and a figure drawn for illustration says so.
- Every term is defined by what it does before a diagram uses it. One name and one color per thing, everywhere.

## Contents

- Opening: the problem as the story of the worked example.
- The design, part by part, in the order the example moves through it.
- Code blocks for schemas and implementation sketches; diagrams, such as Mermaid for flows, schemas, or state, where they show a mechanism better than prose.
- Today versus proposal on the same inputs, for each part that changes.
- What does not change for the user, and what is not in this work.
- The decisions the design rests on, each with its reason, and a recommendation on any still open.

## Update loop

The artifact is a working surface. As Jon pushes back, change the artifact in place and record each decision where the conversation keeps its rulings. Open questions carry a recommendation, not a shrug.
