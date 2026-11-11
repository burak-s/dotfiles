# Development Rules

## General

- Do not create unnecessary abstractions.
- Prefer modifying existing code over introducing new layers.
- Do not create test file for each feature use existing test files.
- Do not introduce a new dependency unless there is a clear reason.
- Follow the existing architecture and naming conventions before inventing new ones.
- Do not rewrite unrelated code while implementing a feature.
- Keep changes scoped to the requested task.
- Do not create md files if its not asked to do so.
- Do not forget translations if you are working on frontend repos.

## Environment files and secrets

- Treat `.env` and every `.env.*` file (including `.env.production`, `.env.qa`, `.env.local`, and `.env.example`) as private at any directory depth.
- Do not read, create, edit, delete, copy, stage, commit, or upload these files without explicit permission for the specific file and operation. A general coding task is not permission.
- Do not access their contents indirectly through shell commands, search tools, scripts, subprocesses, symlinks, encodings, Git history/diffs, or tools that load and print environment values. Exclude these files from broad searches and content scans.
- Never expose secrets in messages, logs, command output, patches, or generated files. Ask for variable names or a sanitized example instead of reading secret values.
- If a task requires an environment-file change, explain the required change without opening the file and let the user apply it, unless they explicitly authorize that operation.
- Git ignore patterns are not access controls and do not protect already tracked files. Do not bypass these restrictions with force-add or similar workarounds.
