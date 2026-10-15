pipeline {
  agent any
  environment {
    DH_USER = 'manojkudocker'
    DH_CREDS = credentials('dockerhub-creds')
  }
  stages {
    stage('Build') {
      steps {
        script { env.REPO = (env.BRANCH_NAME == 'master') ? 'prod' : 'dev' }
        sh "./build.sh ${DH_USER}/${REPO} ${BUILD_NUMBER}"
      }
    }
    stage('Push') {
      steps {
        sh 'echo $DH_CREDS_PSW | docker login -u $DH_CREDS_USR --password-stdin'
        sh "docker push ${DH_USER}/${REPO}:${BUILD_NUMBER}"
        sh "docker push ${DH_USER}/${REPO}:latest"
      }
    }
    stage('Deploy') {
      steps {
        sh "./deploy.sh ${DH_USER}/${REPO} ${BUILD_NUMBER}"
      }
    }
  }
  post { always { sh 'docker logout || true' } }
}
