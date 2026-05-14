## Summary

<!-- 1–3 bullets describing the change. -->

## Why

<!-- What problem does this solve? Link issues. -->

## Test plan

- [ ] `bash -n install.sh lib/*.sh scripts/*.sh` passes
- [ ] `shellcheck install.sh lib/*.sh scripts/*.sh` passes
- [ ] `shfmt -bn -i 4 -ci -d install.sh lib/*.sh scripts/*.sh` is clean
- [ ] `./install.sh --dry-run --no-log` succeeds
- [ ] Re-running `./install.sh` on a system that already has this change applied is a no-op (idempotent)

## Notes

<!-- Anything reviewers should look at carefully. Breaking changes? New manual steps? -->
