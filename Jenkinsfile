// Jenkinsfile
pipeline {
  agent any

  environment {
    BACKEND_IMAGE  = "devnotes-backend:latest"
    FRONTEND_IMAGE = "devnotes-frontend:latest"
    KIND_NODE      = "devnotes-control-plane"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Backend Image') {
      steps {
        dir('backend') {
          echo "Building ${BACKEND_IMAGE}"
          sh "docker build -t ${BACKEND_IMAGE} ."
        }
      }
    }

    stage('Build Frontend Image') {
      steps {
        dir('frontend') {
          echo "Building ${FRONTEND_IMAGE}"
          sh "docker build -t ${FRONTEND_IMAGE} ."
        }
      }
    }

    stage('Load into Kind') {
      steps {
        echo "Pushing ${BACKEND_IMAGE} into ${KIND_NODE}"
        sh """
          docker save ${BACKEND_IMAGE} \
          | docker exec -i ${KIND_NODE} \
              ctr -n=k8s.io images import -
        """
        echo "Pushing ${FRONTEND_IMAGE} into ${KIND_NODE}"
        sh """
          docker save ${FRONTEND_IMAGE} \
          | docker exec -i ${KIND_NODE} \
              ctr -n=k8s.io images import -
        """
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          kubectl apply -f k8s/backend-deployment.yaml
          kubectl apply -f k8s/backend-service.yaml
          kubectl apply -f k8s/frontend-deployment.yaml
          kubectl apply -f k8s/frontend-service.yaml
          kubectl apply -f k8s/ingress.yaml
          kubectl apply -f k8s/persistent-volume.yaml
          kubectl apply -f k8s/persistent-volume-claim.yaml
        '''
      }
    }
  }

  post {
    always {
      echo "Pipeline finished with status: ${currentBuild.currentResult}"
    }
  }
}
