# Commit Changelog Format

Generate a changelog entry from the staged diff using these rules:

1. Start with the exact heading supplied in the generation context.
2. Write in English and describe only changes evidenced by the diff.
3. Use concise numbered items grouped by file, directory, or logical module.
4. Explain behavior and purpose rather than listing individual changed lines.
5. Include documentation, tests, dependencies, configuration, and removed files when present.
6. Do not use horizontal separators or code fences.
7. Finish with a `### Conclusion` section of no more than three short paragraphs.

Output only the Markdown changelog entry.
