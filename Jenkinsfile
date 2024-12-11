pipeline {
    environment {
        IMAGE_NAME = "alpinehelloworld-project"
        IMAGE_TAG = "latest"
        STAGING = "mini-projet-jenkins-staging"
        PRODUCTION = "mini-projet-jenkins-production"
        APP_CONTAINER_PORT = "80"
        APP_EXPOSED_PORT = "82"
        STAGING_APP =  "https://mini-projet-jenkins-staging-e373209396c2.herokuapp.com"
        PRODUCTION_APP = "https://mini-projet-jenkins-production-2d5d1b05ea59.herokuapp.com"
    }
    agent none
    stages {
        stage ('Build image'){
            agent any
            steps {
                script {
                    sh 'docker build -t toshiroskynet/$IMAGE_NAME:$IMAGE_TAG .'
                }
            }
        }
        stage ('Run container based on builded image'){
            agent any
            steps {
                script {
                    sh '''
                        docker run --name $IMAGE_NAME -d -p $APP_EXPOSED_PORT:$APP_CONTAINER_PORT -e PORT=$APP_CONTAINER_PORT toshiroskynet/$IMAGE_NAME:$IMAGE_TAG
                        sleep 15
                    '''
                }
            }
        }
        stage ('Test image'){
            agent any
            steps {
                script {
                    sh '''
                        curl http://172.17.0.1:$APP_EXPOSED_PORT | grep -i 'Dimension'
                    '''
                }
            }
        }
        stage ('Clean container'){
            agent any
            steps {
                script {
                    sh '''
                        docker stop $IMAGE_NAME
                        docker rm $IMAGE_NAME
                    '''
                }
            }
        }
        stage ('Push to registry'){
            agent any
            environment {
                DOCKERHUB_API_KEY = credentials('dockerhub')
            }
            steps {
                script {
                    sh '''
                        docker push toshiroskynet/$IMAGE_NAME:$IMAGE_TAG
                        sleep 10
                    '''
                }
            }
        }
        stage ('Push image in staging and deploy it'){
            when {
                expression { GIT_BRANCH == 'origin/stage' }
            }
            agent any
            environment {
                HEROKU_API_KEY = credentials('heroku_api_key')
            }
            steps {
                script {
                    sh '''
                        curl -fsSL https://deb.nodesource.com/setup_16.x | bash
                        apt-get install -y nodejs
                        npm i -g heroku@7.68.0
                        heroku container:login
                        heroku create $STAGING || echo "project already exist"
                        heroku container:push -a $STAGING web
                        heroku container:release -a $STAGING web
                    '''
                }
            }
        }
        stage ('Test stage image'){
            agent any
            steps {
                script {
                    sh '''
                        curl $STAGING_APP | grep -i 'Dimension'
                    '''
                }
            }
        }
        stage ('Push image in production and deploy it'){
            when {
                expression { GIT_BRANCH == 'origin/main' }
            }
            agent any
            environment {
                HEROKU_API_KEY = credentials('heroku_api_key')
            }
            steps {
                script {
                    sh '''
                        input "Want to deploy on prod?"
                        curl -fsSL https://deb.nodesource.com/setup_16.x | bash
                        apt-get install -y nodejs
                        npm i -g heroku@7.68.0
                        heroku container:login
                        heroku create $PRODUCTION || echo "project already exist"
                        heroku container:push -a $PRODUCTION web
                        heroku container:release -a $PRODUCTION web
                    '''
                }
            }
        }
        stage ('Test production image'){
            agent any
            steps {
                script {
                    sh '''
                        curl $PRODUCTION_APP | grep -i 'Dimension'
                    '''
                }
            }
        }
    }
    post {
        success {
            slackSend (color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
        failure {
            slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }   
    } 
}