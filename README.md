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
