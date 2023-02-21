# jenkins_notes

## My personal notes about Jenkins

This is my self-study guide on how to use `Jenkins` to deploy `AWS SAM templates`.  It uses the [Jenkins Multibranch Pipelines](https://www.jenkins.io/doc/book/pipeline/multibranch/)
to deploy into different environments (dev, prod).  It also sends a Slack notification when the job starts and when the job completes.  For the build environment, it uses the [Python 3.9](https://gallery.ecr.aws/sam/build-python3.9)
image available from the [SAM Image Repository](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-image-repositories.html).

### Example Notes
* In the example file, the following replacements will be needed:
* * `project-name`: the code repo name (for example)
* * `user`: a valid username for the github repo
* * `user@example.com`: contact info

### Example File

[Jenkinsfile](Jenkinsfile)
