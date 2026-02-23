pipeline {
  agent any // Adjust to your Jenkins agent label

  environment {
    REGISTRY       = 'docker.io' // e.g., 'docker.io' or 'registry.example.com'
    REPO           = 'pschpra/spring-docker'
    IMAGE          = "${REPO}"
    IMAGE_TAG      = "${env.BUILD_NUMBER}"
    IMAGE_LATEST   = 'latest'
    DOCKER_CREDS   = 'docker-pat-prakash' // Jenkins credentials ID
    JAVA_HOME      = tool(name: 'jdk17', type: 'hudson.model.JDK')
    MAVEN_HOME     = tool(name: 'maven3', type: 'hudson.tasks.Maven$MavenInstallation')
    PATH           = "${MAVEN_HOME}/bin:/usr/lib/jvm/java-17-openjdk-amd64/bin:${env.PATH}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Test') {
      steps {
        sh 'java -version'
        sh 'mvn -version'
        sh 'mvn -B -e -DskipTests dependency:go-offline'
        // sh 'mvn -B -e clean verify'
        sh 'mvn package'
      }
      //post {
       // always {
       //   junit 'target/surefire-reports/*.xml'
        //}
      //}
    }

    stage('Docker Build') {
      steps {
        script {
          sh """
            docker build -t ${IMAGE}:${IMAGE_TAG} -t ${IMAGE}:${IMAGE_LATEST} .
          """
        }
      }
    }

    stage('Docker Login & Push') {
      // when { expression { return env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master' } }
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDS, passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
          sh """
            echo "$DOCKER_PASS" | docker login ${REGISTRY} -u "$DOCKER_USER" --password-stdin
            docker push ${IMAGE}:${IMAGE_TAG}
            docker push ${IMAGE}:${IMAGE_LATEST}
            docker logout ${REGISTRY}
          """
        }
      }
    }

    // Optional: Deploy (replace with your actual deploy steps)
     stage('Deploy') {
       // when { branch 'main' }
       steps {
         sh 'echo "Deploying ${IMAGE}:${IMAGE_TAG}..."'
         sh 'docker run -d -p 3003:3002 --name myapps ${IMAGE}:${IMAGE_TAG}'
       }
     }
  }

  post {
    success { echo "Build ${env.BUILD_NUMBER} OK — image ${IMAGE}:${IMAGE_TAG}" }
    failure { echo "Build ${env.BUILD_NUMBER} FAILED" }
    //always  { cleanWs() }
  }
}
