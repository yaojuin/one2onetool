pipeline {
    agent {
        dockerfile { additionalBuildArgs '--entrypoint='''}
    }
    stages {
        stage('Test') {
            steps {
                sh 'npm run test'
            }
        }
    }
}