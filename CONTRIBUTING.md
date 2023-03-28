# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue,
email, or any other method with the owners of this repository before making a change.

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Pull Request Process

1. Update the README.md with details of changes or adding features if appropriate.
2. Run lhs_git_scan_secret (Running docker and using git scan secret to make sure there is no sensitive data)
3. Once all outstanding comments and checklist items have been addressed, your contribution will be merged! Merged PRs will be included in the next release. The module maintainers take care of updating the CHANGELOG as they merge.

## Checklists for contributions

- [ ] Add [semantics prefix](#semantic-pull-requests) to your PR or Commits (at least one of your commit groups)
- [ ] Passing sensitive data checking
- [ ] README.md has been updated after adding or changing features

## Semantic Pull Requests
To generate changelog, Pull Requests or Commits must have semantic and must follow conventional specs below:
- `[Add]` - add description
- `[Update]` - update description
- `[Remove]` - remove somethings such as functions, temp file, ...
- `[Improvement]` - for enhancements
- `[Feat]` – a new feature is introduced with the changes
- `[Fix]` - a bug fix has occurred
- `[Chore]` – for updating dependencies
- `[Refactor]` - refactored code that neither fixes a bug nor adds a feature
- `[Docs]` - updates to documentation such as a the README or other markdown files
- `[Style]` - related to code formatting such as white-space, missing semi-colons, and so on
- `[Test]` - including new or correcting previous tests
- `[Perf]` – performance improvements
- `[CiCd]` - continuous integration and continuous delivery related
- `[Build]` – changes that affect the build system or external dependencies
- `[Revert]` - reverts a previous commit
- `[Release]` - Your Release description (Comment for the PR)

The `[Chore]` prefix skipped during changelog generation.