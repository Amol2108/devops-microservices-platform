pipeline {
    agent any

    stages {

        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Amol2108/devops-microservices-platform.git'
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

        stage('Push Images to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push ironman21/backend-app:v1
                    docker push ironman21/frontend-app:v1
                    '''
                }
            }
        }

    }
}