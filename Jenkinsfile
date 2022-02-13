pipeline {
    agent {
        dockerfile { args '--entrypoint=""'
        }
    }
    stages {
        stage('Test') {
            steps {
                sh 'npm run test'
            }
        }
    }
}