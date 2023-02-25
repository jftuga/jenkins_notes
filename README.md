# Jenkins Notes

## My personal notes about Jenkins

This is my self-study guide on how to use `Jenkins` to deploy `AWS SAM templates`.  It uses the [Jenkins Multibranch Pipelines](https://www.jenkins.io/doc/book/pipeline/multibranch/)
to deploy into different environments (dev, prod).  It also sends a Slack notification when the job starts and when the job completes.  For the build environment, it uses the [Python 3.9](https://gallery.ecr.aws/sam/build-python3.9)
image available from the [SAM Image Repository](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-image-repositories.html).

## Jenkins Configuration

### Branch Sources

* Credentials: `read-only user`

| Behavior | Settings | Notes |
| -------- | -------- | ----- |
| Discover Branches | Exclude branches that are also files as PRs | reduces redundant effort
| Discover pull requests from origin | Merging the pull request with the current target branch | best option for my work flow; example: merge feature-branch to main
| Discover pull requests from forks | Merging the pull request with the current target branch | *(See above)*
| Trust | Forks in the same account | best option for my work flow
| Filter by name | Exclude | *(any research such as Spikes)*

* Property strategy: `all branches get the same properties`

### Build Configuration

* Mode: `by Jenkinsfile`
* Script Path: `build/Jenkinsfile`


### Scan Multibranch Pipeline Triggers

* Build when a change is pushed: `checked`
* All other options: `unchecked`

### Orphaned Item Strategy

* Discard old items: `checked`


## Example Notes
* In the example file, the following replacements will be needed:
* * `project-name`: the code repo name (for example)
* * `user`: a valid username for the github repo
* * `user@example.com`: contact info

___

## Searching for complete sections

[ripgrep](https://github.com/BurntSushi/ripgrep) is a grep alternative that is faster and has more [features](https://github.com/BurntSushi/ripgrep/blob/master/FAQ.md). For example, it honors `.gitignore` when deciding which files to inspect.  One option that I learned about recently is the --multiline option which permits matches to span multiple lines.  I like to use this with the `(?s)` modifier (aka `--multiline-dotall`).  This causes a dot (within a regular expression) to also match newline characters. You can install ripgrep via homebrew. Although the package name is `ripgrep`, the command is `rg`.

I like to use this ripgrep search for finding “code sections”.  For example, I have a `Jenkinsfile` that has a stage named `Configure assume role`, but I’d like to see the entire stage, not just that one line, but rather a group of lines matching the entire stage.

To do this, I can run this command:

```bash
$ rg --multiline '(?s)stage.*?Configure assume role.*?}.*?}.*?}' Jenkinsfile

57:    stages {
58:        stage('Configure assume role') {
59:            steps {
60:                sh 'mkdir -p /root/.aws'
61:                withCredentials([file(credentialsId: 'account-baseline-stacksets-jenkins', variable: 'config')]) {
62:                    sh "cp \$config /root/.aws/config"
63:                }
64:            }
65:            steps {
66:                sh 'echo this is step 2...'
67:                }
```

This is a regular expression that:
* matches newlines via `(?s)`
* searches for anything starting with `stage` followed by anything (such as non-alphanumeric characters)
* followed by my desired search string: `Configure assume role`
* followed by three ending curly braces. This will obviously be dependent on how and where you want to end your reg expr match.
* Note that `.*?` will match the shortest possible string, while using `.*` will match the longest. If I did not include the `?` then this command would match until the end of file, which is not my desired outcome.
* [Python Regex Greedy vs Non-Greedy Quantifiers](https://blog.finxter.com/python-regex-greedy-vs-non-greedy-quantifiers)

Another optimization is to use regular expression repetition qualifiers.  In this case, I need three consecutive `}` to end the match. What if I needed 15? This would get ugly.  You can use the syntax of `{n}` where `n` is the number of matches you want.  This immediately follows the regular expression portion that you want to match on, which may need to be wrapped between `()`.  You can also use `{min,max}` to set lower and upper bounds.

In my example, I could shorten the command to the following and get the same result.  Note that I wrapped `.*?` inside of parenthesis so that the `{3}` would work correctly.  This makes it easier to see smaller or larger portions of the stage by adjusting this number.

```bash
rg --multiline '(?s)stage.*?Configure assume role(.*?}){3}' Jenkinsfile
```
