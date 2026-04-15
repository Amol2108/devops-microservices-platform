pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/Amol2108/devops-microservices-platform.git'
            }
        }

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