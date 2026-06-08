pipeline {

    agent any

    environment {

        AWS_REGION = "ap-south-1"

        ECR_REPO = "python-app"

        ACCOUNT_ID = "583067668082"

        IMAGE_TAG = "${BUILD_NUMBER}"

    }

    stages {

        stage('Checkout') {

            steps {

                git branch: 'main',
                url: 'https://github.com/vnataraj5-ship-it/java-app-cicd.git'


            }
        }

        stage('SonarQube Analysis') {

            steps {

                withSonarQubeEnv('sonarqube') {

                    sh '''
                    sonar-scanner \
                    -Dsonar.projectKey=python-app \
                    -Dsonar.sources=.
                    '''
                }
            }
        }

        stage('Build Docker Image') {

            steps {

                sh '''
                docker build \
                -t python-app:${IMAGE_TAG} .
                '''
            }
        }

        stage('Push Image To ECR') {

            steps {

                withAWS(credentials: 'aws-ecr',
                        region: 'ap-south-1') {

                    sh '''
                    aws ecr get-login-password \
                    --region ap-south-1 | docker login \
                    --username AWS \
                    --password-stdin \
                    ${ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com

                    docker tag python-app:${IMAGE_TAG} \
                    ${ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/python-app:${IMAGE_TAG}

                    docker push \
                    ${ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/python-app:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Update Deployment YAML') {

            steps {

                sh """
                sed -i 's|image:.*|image: ${ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/python-app:${IMAGE_TAG}|g' k8s/deployment.yaml
                """
            }
        }

        stage('Push Manifest To GitHub') {

            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: 'github-creds',
                        usernameVariable: 'USER',
                        passwordVariable: 'TOKEN'
                    )
                ]) {

                    sh '''
                    git config user.email "jenkins@gmail.com"
                    git config user.name "jenkins"

                    git add .

                    git commit -m "Updated image ${BUILD_NUMBER}"

                    git push
                    '''
                }
            }
        }
    }
}
