# Use docs/adr Directory for ADR Location

## Status

Accepted

## Context

The ADR gptel tools in Doom Emacs previously allowed for variable locations to store Architectural Decision Records. This inconsistency caused confusion and made it difficult to maintain a standard project structure. It was also challenging for tools and team members to locate ADRs without prior knowledge of where they might be stored.

Many projects follow the convention of storing ADRs in a `docs/adr` directory at the project root. This is a widely adopted practice that makes ADRs discoverable and follows a pattern recognizable across different projects.

## Decision

We have modified the ADR gptel tools to always use the `docs/adr` directory located in the current projectile project root, regardless of any previously configured location.

Specifically, we updated the `gptel-adr--ensure-directory` function in `/Users/zell/.doom.d/gptel-tools/adr-tools.el` to always return the path to "docs/adr" in the current projectile project root:

```elisp
(defun gptel-adr--ensure-directory ()
  "Ensure the ADR directory exists."
  (let ((adr-dir (expand-file-name "docs/adr" (projectile-project-root))))
    (unless (file-exists-p adr-dir)
      (make-directory adr-dir t))
    adr-dir))
```

This change ensures that all functions that interact with ADRs use this standardized location.

## Consequences

### Positive
- Standardized location makes ADRs more discoverable
- Easier integration with other tools that expect ADRs in a conventional location
- Simplified code as there's no need to track or configure custom ADR locations
- Consistent with industry practices for storing architectural documentation

### Negative
- Existing projects using custom ADR locations will need to migrate their ADRs to the new location
- Less flexibility for teams that might have preferred custom locations

## References

- [ADR Tools by Nat Pryce](https://github.com/npryce/adr-tools) - A command-line tool for working with ADRs
- [Markdown Any Decision Records](https://adr.github.io/madr/) - A template for ADRs using Markdown
- [Projectile Documentation](https://docs.projectile.mx/projectile/index.html) - Project Interaction Library for Emacs