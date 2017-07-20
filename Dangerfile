# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 700

# commit_lint.check

if git.commits.any? { |c| c.message =~ /^Merge branch 'master'/ }
  warn 'Please rebase to get rid of the merge commits in this PR'
end

# Commit Messages
commit_lint.check warn: :all

todoist.warn_for_todos
the_coding_love.random

slather.configure("ZendeskSDK/ZendeskSDK.xcodeproj", "ZendeskSDK", options: {
  workspace: ' ZendeskSDK.xcworkspace/',
})

markdown("-------")
markdown("<details>")
markdown("<summary>Slather File Info </summary>")
markdown("")
markdown("```")
markdown(File.read("coverage.res"))
markdown("```")
markdown("")
markdown("</details>")

slather.show_coverage
