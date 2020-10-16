# frozen_string_literal: true

has_app_changes = !git.modified_files.grep(/FueledUtils/).empty?
if !git.modified_files.include?('CHANGELOG.md') && has_app_changes
  warn("Please include a CHANGELOG entry to credit yourself! \nYou can find it at [CHANGELOG.md](https://github.com/Fueled/ios-utilities/blob/develop/CHANGELOG.md).", :sticky => false)
  markdown <<-MARKDOWN
Here's an example of your CHANGELOG entry:
```markdown
- #{github.pr_title}\s\s
  [#{github.pr_author}](https://github.com/#{github.pr_author})
  [#pull_request_number](https://github.com/Fueled/ios-utilities/pulls/pull_request_number)
```
*note*: There are two invisible spaces after the entry's text.
MARKDOWN
end
