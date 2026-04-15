pipeline {
    agent any

    stages {
    

        stage('Build Backend Image') {
            steps {
                sh 'docker build -t ironman21/backend-app:v1 ./app/backend'
            }
        }

        stage('Build Frontend Image') {
            steps {
                sh 'docker build -t ironman21/frontend-app:v1 ./app/frontend'
            }
        }
    }
}