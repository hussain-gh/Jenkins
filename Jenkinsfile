pipeline {
  agent {
    docker { image 'node:16-alpine' }
    //label 'java-build-deploy'
  }
  stages {
    stage('Test') {
      steps {
        sh 'node --version'
      }
    }
  }
}