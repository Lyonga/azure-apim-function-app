# Test Environment Placeholder

This environment is a placeholder scaffold that mirrors the active `dev` v2
layout.

Use `test` as the review template for a nonprod validation environment. If a
client separates `qa` and `stage`, duplicate this pattern into those
environments rather than changing the global control-plane model.

Before making `test` deployable, replace placeholders with real values:

- platform subscription id: `<replace-with-test-platform-subscription-id>`
- workload subscription id: `<replace-with-test-workload-subscription-id>`
- backend keys under `stacks/test/...`
- environment-specific naming and tags

Do not treat this placeholder as an active CI target until that replacement is
done.
