# Releasing

This repository is only a pointer. A release means publishing the SDK's compiled XCFramework here
and moving that pointer.

1. In the SDK repository, build the release binary:

   ```sh
   scripts/build-xcframework.sh
   ```

   It writes `build/xcframework/InstareadSDK-<version>.xcframework.zip` and prints its SHA-256 —
   the same value `swift package compute-checksum` produces, which is what Swift verifies.

2. Here, create a GitHub release tagged with that version (`1.6.0`, no `v`) and attach the zip.
   The tag is what `from: "1.6.0"` resolves to, so it has to match.

3. Update `Package.swift` — the version in `url`, and `checksum` — then commit and push.

4. Tag this repository with the same version and push the tag:

   ```sh
   git tag 1.6.0 && git push origin 1.6.0
   ```

   Swift reads `Package.swift` **as of that tag**, so the tag has to come after the commit in
   step 3. Tagging first points the release at the previous version's binary.

Nothing else lives here. The SDK's source, tests and documentation stay in its own private
repository.
