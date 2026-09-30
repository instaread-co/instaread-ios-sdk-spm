# Releasing

This repository is only a pointer. A release means publishing the SDK's compiled XCFramework here
and moving that pointer.

**Normally nobody does this by hand.** Two separate steps in the SDK repository's Actions tab,
like Android's build and its Maven Central publish:

1. **SDK Release Builder** with the new version — builds and releases the SDK there. Nothing
   reaches this repository yet; the release can be tested (React Native, partner zips) first.
2. **Publish Swift Package** with the same version, once it has proven stable — puts that
   release's XCFramework here. It needs the `SPM_REPO_TOKEN` secret; see `spm-release.yml`.

The manual steps below are what that workflow does, for when it cannot run.

1. In the SDK repository, build the release binary:

   ```sh
   scripts/build-xcframework.sh
   ```

   It writes `build/xcframework/InstareadSDK-<version>.xcframework.zip` and prints its SHA-256 —
   the same value `swift package compute-checksum` produces, which is what Swift verifies.

2. Here, update `Package.swift` — the version in `url`, and `checksum` — then commit and push.

3. Tag that commit with the version (`1.6.1`, no `v`) and push the tag:

   ```sh
   git tag 1.6.1 && git push origin 1.6.1
   ```

   Swift reads `Package.swift` **as of that tag**, so the tag has to come after the commit in
   step 2. The tag is also what `from: "1.6.1"` resolves to.

4. Create the GitHub release **for that existing tag** and attach the zip:

   ```sh
   gh release create 1.6.1 path/to/InstareadSDK-1.6.1.xcframework.zip --verify-tag
   ```

   In this order, not release first: creating a release with a new tag makes GitHub create the
   tag on whatever `main` is at that moment — the old `Package.swift`, pointing at the previous
   version's binary — and the `git tag` in step 3 then fails because the tag already exists.

Nothing else lives here. The SDK's source, tests and documentation stay in its own private
repository.
