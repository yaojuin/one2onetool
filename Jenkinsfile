pipeline {
    agent {
        dockerfile { args '--entrypoint=""' additionalBuildArgs '--target test'
        }
    }
    stages {
        stage('Test') {
            steps {
                sh 'echo test'
            }
        }
    }
}