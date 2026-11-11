# Instructions for this repository

## Conventions and Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in BCP 14 ([RFC2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC8174](https://www.rfc-editor.org/rfc/rfc8174)) when, and only when, they appear in all capitals, as shown here.

## Code review

When you are asked to do a code review and the user gives you the list of changes or files, then you MUST review only those files.

When you are asked to do a code review and the user gives you no list of changes or files then:
  * list all changed files with `git status`
  * look at the changed files you SHALL use `git diff`, `cat`, or any analogous command on your operating system.

During a code review, you MUST NOT change any file, but changes to files MAY occur after the code review.

You MUST write conclusion at the end of the code review as either "ready to commit", "changes requested" (plus a list of required changes), or "rejected".

## Never run

You MUST NOT run any of these commands regardless of the situation or urgency:

  * `git commit`
  * `git push`
  * `git reset`
