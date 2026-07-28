---
created: 2026-05-31
updated: 2026-05-31
sources: 1
---

# Docker Sandbox Network Policy

Configuration note for Docker sandboxes (`sbx`) network policy.

## Default policy options

When the sandbox daemon (`sandboxd`) starts for the first time, it prompts for a default network policy:

1. **Open** — All network traffic allowed, no restrictions.
2. **Balanced** — Default deny, with common dev sites allowed.
3. **Locked Down** — All network traffic blocked unless explicitly allowed.

## Current setting

Network policy is set to **Open**. All outbound network traffic is allowed.

## Daemon details

- **PID**: 96468
- **Socket**: `/Users/hassan/Library/Application Support/com.docker.sandboxes/sandboxes/sandboxd/sandboxd.sock`
- **Logs**: `/Users/hassan/Library/Application Support/com.docker.sandboxes/sandboxes/sandboxd/daemon.log`

## Managing the policy

Reset the default policy (re-prompts for selection):

```bash
sbx policy reset
```

Allow or deny specific hosts:

```bash
sbx policy allow network <host>
sbx policy deny network <host>
```
