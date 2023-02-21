#!/usr/bin/env groovy
@Library('tools') _

// how to use "sam deploy" from with Jenkins using a multibranch pipeline

// required replacements:
// "project-name" with the code repo name (for example)
// "user" with a valid username for github repo
// "user@example.com" with contact info

pipeline {
    // if a buld runs longer than one hour, there is a problem
    options {
        disableConcurrentBuilds()
        timeout(time: 60, unit: 'MINUTES')
    }

    // available options
    // https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-image-repositories.html
    agent {
        kubernetes {
            label 'project-name'
            defaultContainer 'build'
            yaml '''
                apiVersion: v1
                kind: Pod
                spec:
                  serviceAccountName: project-name-jenkins
                  containers:
                  - name: build
                    image: public.ecr.aws/sam/build-python3.9:latest
                    tty: true
                    command:
                    - cat
            '''
        }
    }

    // Use ternary operater based off of BRANCH_NAME
    // if branch name = "main", then we are in production
    // any other branch name, then we are in development
    environment {
        STACK_NAME = "project-name"
        ENV_NAME = "${env.BRANCH_NAME == "main" ? "prod" : "dev"}"
        FROM_EMAIL_ADDR = "user@example.com"
        ACCTID = "${env.BRANCH_NAME == "main" ? "123456789012" : "987654321098"}"
        CF_EXEC_ARN = "arn:aws:iam::${ACCTID}:role/CloudFormationExecutionRole"
        TAGS = "contact=user@example.com environment=${ENV_NAME} repo=https://github.com/user/project-name"
        SLACK_CHANNEL = "${env.BRANCH_NAME == "main" ? "#user-notifications" : "committer"}"
    }

    stages {
        // output the last 3 commits, useful for troubleshooting
        stage("git config") {
            steps {
                sh """
                    git log -n 3
                """
            }
        }

        // send slack notification that the build is starting
        // depending on how busy the Jenkins server is, this not always immediate
        stage("slack start") {
            steps {
                notify slack: "committer", message: "Build <$env.RUN_DISPLAY_URL|$currentBuild.fullDisplayName> is starting."
            }
        }

        // assume the role that will be used to run Jenkins AWS commands
        stage('Configure assume role') {
            steps {
                sh 'mkdir -p /root/.aws'
                withCredentials([file(credentialsId: 'project-name-jenkins', variable: 'config')]) {
                    sh "cp \$config /root/.aws/config"
                }
            }
        }

        // not always necessary, just show this possibility
        // useful when dev is slightly different that prod
        stage('dev deploy') {
            when { not { branch 'main' } }
            steps {
                script {
                    def REGIONS = ['us-east-2']
                    for (REGION in REGIONS) {
                        sh """
                            export SAM_CLI_TELEMETRY=0
                            sam build -t template.yml
                            sam deploy \
                                --profile ${ENV_NAME} \
                                --region ${REGION} \
                                --stack-name ${STACK_NAME} \
                                --role-arn ${CF_EXEC_ARN} \
                                --capabilities CAPABILITY_NAMED_IAM \
                                --s3-bucket user-artifacts-${ACCTID}-${REGION} \
                                --s3-prefix ${STACK_NAME}-${ENV_NAME} \
                                --no-fail-on-empty-changeset \
                                --tags ${TAGS}
                        """
                    }
                }
            }
        }

        // pass in environment variables based on branch name where
        // branch name is either "main"; anything else is considered dev (see above)
        stage('Prod Deploy') {
            when { branch 'main' }
            steps {
                script {
                    def REGIONS = ['us-east-1', 'us-west-2', 'eu-west-2']
                    for (REGION in REGIONS) {
                        sh """
                            export SAM_CLI_TELEMETRY=0
                            sam build -t template.yml
                            sam deploy \
                                --profile ${ENV_NAME} \
                                --region ${REGION} \
                                --stack-name ${STACK_NAME} \
                                --role-arn ${CF_EXEC_ARN} \
                                --capabilities CAPABILITY_NAMED_IAM \
                                --s3-bucket user-artifacts-${ACCTID}-${REGION} \
                                --s3-prefix ${STACK_NAME}-${ENV_NAME} \
                                --no-fail-on-empty-changeset \
                                --tags ${TAGS}
                        """
                    }
                }
            }
        }
    }

    // send slack notification with build result
    post {
        always {
            notify slack: "${SLACK_CHANNEL}", message: "Build <$env.RUN_DISPLAY_URL|$currentBuild.fullDisplayName> completed with status: $currentBuild.currentResult"
        }
    }
}