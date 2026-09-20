# The Stack

One `gh stack` per **Ticket**. Every **Layer** is a branch in it, and the pull request that will eventually carry it. `/build` builds the stack as it goes — one branch per layer, pushed — and creates nothing on GitHub; the shipping half submits the whole stack once, as drafts.

The flows below are the push and resume halves of the stack. They assume the `gh-stack` extension: `gh extension install github/gh-stack` where `gh stack` is missing.

## Building it

The stack starts where the ticket's work starts: the trunk, or the alignment's own branch when the contract put a document on one — that branch is the stack's base layer, and the layers stack above it.

```sh
gh stack init --base main <first-layer-branch>   # create the stack at its first layer
gh stack add <next-layer-branch>                 # each later layer on top of the one below
```

`gh stack init` adopts existing branches and creates missing ones, so an interrupted stack is rebuilt by naming its branches bottom to top:

```sh
gh stack init <layer-1> <layer-2> <layer-3>
```

Branch names are semantic throughout — `feat/` or `fix/`, then what the layer delivers (`feat/build-fit`, `feat/build-layers`) — never a number, because a number says nothing when it is read a week later.

## Pushing a layer

```sh
gh stack push
```

Pushes every active branch in the current stack, with a per-branch `--force-with-lease`. It creates nothing on GitHub — no pull request, no draft. Run it once a layer's tree is clean and its commits are in; running it again changes nothing, and a rejected branch is fixed and pushed again without disturbing the branches already up.

**No pull request exists before the shipping half.** `gh stack push` is this flow's whole remote act.

## Resuming

A run re-entered against the same ticket reads the ticket's own stack rather than planning the layers again. `gh stack view` alone is ambiguous — the trunk belongs to every stack in the repo — so attach to the stack by one of its branches first:

```sh
gh stack checkout <layer-branch>     # attach to the ticket's stack by a branch it owns
gh stack view --json                 # every layer, its branch and its state
```

Then read, in this order, and re-derive nothing:

1. the ticket's **fit record** — the commands, the witnesses and the paths secrets live at, proven at a commit;
2. the ticket's **plan** — the layers, their bases, and what each owns;
3. the ticket's **layer records**, bottom to top — what is built, vetted and pushed;
4. the **stack** — which branches exist on the remote and the tip of the highest one.

The first layer without a record is where the run resumes: brief its builder at that branch's tip, push it, and carry on from the vetting step. A layer with a record whose criterion is still open resumes at its fix round, not at its cut.
