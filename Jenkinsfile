pipeline {
    agent {
        dockerfile { args '--entrypoint=""' args '--target test'
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