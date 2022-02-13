pipeline {
    agent {
        dockerfile { args '--entrypoint=""' additionalBuildArgs '--target test'
        }
    }
    stages {
        stage('Test') {
            steps {
                sh '''
                cd /usr/src/app
                npm run test

                '''
            }
        }
    }
}