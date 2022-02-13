pipeline {
    agent none
    stages {
        stage('Test') {
            agent {
        dockerfile { args '--entrypoint=""' additionalBuildArgs '--target test'
        }
    }
            steps {
                sh '''
                cd /usr/src/app
                npm run test

                '''
            }
        }
    }
}