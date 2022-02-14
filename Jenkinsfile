pipeline {
    agent {
        label 'master'
    }
    stages {
        stage('Test') {
            
            agent {
        dockerfile { args '--entrypoint=""' additionalBuildArgs '--target test'
        }
    }
            when {
                expression { env.GIT_BRANCH == "origin/staging" }
            }
            steps {
                sh '''
                cd /usr/src/app
                npm run test

                '''
            }
        }
        stage('Build and Push ECR Staging') {
            when {
                expression { env.GIT_BRANCH == "origin/staging" }
            }
            steps {
                sh"""
        aws ecr-public get-login-password --profile jenkins --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
        docker build -t public.ecr.aws/t5z2m9x9/one2onetool:staging_${BUILD_ID} .
        docker push public.ecr.aws/t5z2m9x9/one2onetool:staging_${BUILD_ID}
        docker rmi public.ecr.aws/t5z2m9x9/one2onetool:staging_${BUILD_ID}
    """
            }
        }
        stage('Deploy to ECS Staging') {
            when {
                expression { env.GIT_BRANCH == "origin/staging" }
            }
            steps {
                // Grab the latest taskdef json and update to the current image build
    sh"""
        REGION=us-east-1
        CLUSTER=nodeapp
        FAMILY=one2onetool-staging
        SERVICE_NAME=one2onetool-staging

        aws ecs describe-task-definition --profile jenkins --task-definition \${FAMILY} --no-verify-ssl --region \${REGION} \| jq .taskDefinition \| jq 'del(.taskDefinitionArn)' \| jq 'del(.status)' \| jq 'del(.revision)' \| jq 'del(.requiresAttributes)' \| jq 'del(.compatibilities)' > task.json
        sed -i -e "s/staging_[0-9]\\+/\\staging_$BUILD_ID/g" task.json

        #Create new revision
        REVISION=`aws ecs register-task-definition --profile jenkins --no-verify-ssl --family \${FAMILY} --cli-input-json file://$WORKSPACE/task.json --region \${REGION} \| jq .taskDefinition.revision`
        SERVICES=`aws ecs describe-services --profile jenkins --no-verify-ssl --services \${SERVICE_NAME} --cluster \${CLUSTER} --region \${REGION} \| jq .failures[]`
        
        #Create or update service
        if [ "\$SERVICES" == "" ]; then
          echo "entered existing service"
          DESIRED_COUNT=`aws ecs describe-services --profile jenkins --no-verify-ssl --services \${SERVICE_NAME} --cluster \${CLUSTER} --region \${REGION} \| jq .services[].desiredCount`
          if [ \$DESIRED_COUNT = "0" ]; then
            DESIRED_COUNT="1"
          fi
          aws ecs update-service --profile jenkins --no-verify-ssl --cluster \${CLUSTER} --region \${REGION} --service \${SERVICE_NAME} --task-definition \${FAMILY}:\$REVISION --desired-count \$DESIRED_COUNT --force-new-deployment
        else
          echo "entered new service"
          aws ecs create-service --profile jenkins --no-verify-ssl --service-name \${SERVICE_NAME} --desired-count 1 --task-definition \${FAMILY} --cluster \${CLUSTER} --region \${REGION}
        fi
    """
            }
        }
        stage('Build and Push ECR Release Branch') {
            when {
                expression { env.GIT_BRANCH == "origin/release" }
            }
            steps {
                sh"""
        aws ecr-public get-login-password \
            --region us-east-1 \
            | docker login \
                --username AWS \
                --password-stdin 176499060410.dkr.ecr.us-east-1.amazonaws.com
        docker build -t public.ecr.aws/t5z2m9x9/one2onetool:prod_${BUILD_ID} .
        docker push public.ecr.aws/t5z2m9x9/one2onetool:prod_${BUILD_ID}
        docker rmi public.ecr.aws/t5z2m9x9/one2onetool:prod_${BUILD_ID}
    """
            }
        }
        stage('Deploy to ECS Release Branch') {
            when {
                expression { env.GIT_BRANCH == "origin/release" }
            }
            steps {
                // Grab the latest taskdef json and update to the current image build
    sh"""
        REGION=us-east-1
        CLUSTER=nodeapp
        FAMILY=one2onetool-prod
        SERVICE_NAME=one2onetool-prod

        aws ecs describe-task-definition --task-definition one2onetool --no-verify-ssl --region \${REGION} | jq .taskDefinition | jq 'del(.taskDefinitionArn)' | jq 'del(.status)' | jq 'del(.revision)' | jq 'del(.requiresAttributes)' | jq 'del(.compatibilities)' > task.json
        sed -i -e "s/prod_[0-9]\\+/\\prod_$BUILD_ID/g" task.json

        #Create new revision
        REVISION=`aws ecs register-task-definition --no-verify-ssl --family \${FAMILY} --cli-input-json file://$WORKSPACE/task.json --region \${REGION} | jq .taskDefinition.revision`
        SERVICES=`aws ecs describe-services --no-verify-ssl --services \${SERVICE_NAME} --cluster \${CLUSTER} --region \${REGION} | jq .failures[]`
        
        #Create or update service
        if [ "\$SERVICES" == "" ]; then
          echo "entered existing service"
          DESIRED_COUNT=`/usr/local/bin/aws ecs describe-services --no-verify-ssl --services \${SERVICE_NAME} --cluster \${CLUSTER} --region \${REGION} | jq .services[].desiredCount`
          if [ \$DESIRED_COUNT = "0" ]; then
            DESIRED_COUNT="1"
          fi
          /usr/local/bin/aws ecs update-service --no-verify-ssl --cluster \${CLUSTER} --region \${REGION} --service \${SERVICE_NAME} --task-definition \${FAMILY}:\$REVISION --desired-count \$DESIRED_COUNT --force-new-deployment
        else
          echo "entered new service"
          /usr/local/bin/aws ecs create-service --no-verify-ssl --service-name \${SERVICE_NAME} --desired-count 1 --task-definition \${FAMILY} --cluster \${CLUSTER} --region \${REGION}
        fi
    """
            }
        }
    }
    post {
        always {
                script {
                    if (env.GIT_BRANCH == 'origin/staging')

                    emailext body: '''${SCRIPT, template="groovy-html.template"}''',
                            mimeType: 'text/html',
                            subject: '[STAGING] $DEFAULT_SUBJECT',
                            recipientProviders: [developers(), requestor()],
                            attachLog: true
                    else if (env.GIT_BRANCH == 'origin/release')

                    emailext body: '''${SCRIPT, template="groovy-html.template"}''',
                            mimeType: 'text/html',
                            subject: '[PRODUCTION] $DEFAULT_SUBJECT',
                            recipientProviders: [developers(), requestor()],
                            attachLog: true
                }
            }
        }   
}