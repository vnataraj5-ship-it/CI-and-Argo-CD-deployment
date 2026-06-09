pipeline {

    agent any

    environment {

        AWS_REGION = 'ap-south-1'
        ACCOUNT_ID = '583067668082'
        ECR_REPO = 'python-app'

        IMAGE_TAG = "${BUILD_NUMBER}"

        IMAGE_URI = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
    }

    stages {

        stage('Checkout') {

            steps {

                git branch: 'main',
                url: 'https://github.com/vnataraj5-ship-it/CI-and-Argo-CD-deployment.git'

                echo 'Code Checkout Successful'
            }
        }

stage('SonarQube Analysis') {

    steps {

        script {

            def scannerHome = tool 'sonar-scanner'

            withSonarQubeEnv('sonar-server') {

                sh """
                ${scannerHome}/bin/sonar-scanner \
                -Dsonar.projectKey=python-app \
                -Dsonar.projectName=python-app \
                -Dsonar.sources=.
                """
            }
        }
    }
}

        stage('Build Docker Image') {

            steps {

                sh '''
                docker build -t ${ECR_REPO}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Push Image To ECR') {

            steps {

                withAWS(credentials: 'aws-creds', region: "${AWS_REGION}") {

                    withCredentials([
                        usernamePassword(
                            credentialsId: 'github-creds',
                            usernameVariable: 'GITHUB_USER',
                            passwordVariable: 'GITHUB_TOKEN'
                        )
                    ]) {

                        sh '''

                        echo "Logging into AWS ECR..."

                        aws ecr get-login-password \
                        --region ${AWS_REGION} | docker login \
                        --username AWS \
                        --password-stdin \
                        ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com


                        echo "Tagging Docker Image..."

                        docker tag ${ECR_REPO}:${IMAGE_TAG} ${IMAGE_URI}


                        echo "Pushing Docker Image..."

                        docker push ${IMAGE_URI}


                        echo "Updating Kubernetes Deployment File..."

                        sed -i "s|image:.*|image: ${IMAGE_URI}|g" k8/deployment.yaml


                        echo "Committing Updated Manifest..."

                        git config user.email "jenkins@local"
                        git config user.name "Jenkins"

                        git add k8/deployment.yaml

                        git commit -m "Updated image tag to ${IMAGE_TAG}" || true


                        echo "Pushing Updated Manifest To GitHub..."

                        git push https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/vnataraj5-ship-it/CI-and-Argo-CD-deployment.git HEAD:main

                        '''
                    }
                }
            }
        }
    }

    post {

        success {

            echo 'Pipeline Completed Successfully'
        }

        failure {

            echo 'Pipeline Failed'
        }
    }
}
