// Jenkinsfile
pipeline {
  agent any

  environment {
    BACKEND_IMAGE  = "devnotes-backend:latest"
    FRONTEND_IMAGE = "devnotes-frontend:latest"
    KIND_CLUSTER   = "devnotes"
  }

  stages {
  
    stage('Build Backend Image') {
      steps {
        dir('backend') {
          echo "Building ${env.BACKEND_IMAGE}"
          sh "docker build -t ${env.BACKEND_IMAGE} ."
        }
      }
    }

    stage('Build Frontend Image') {
      steps {
        dir('frontend') {
          echo "Building ${env.FRONTEND_IMAGE}"
          sh "docker build -t ${env.FRONTEND_IMAGE} ."
        }
      }
    }

    /*
    // You can uncomment these once you have `kind` and `kubectl` in Jenkins,
    // and you want Jenkins to load the images into kind and deploy:

    stage('Load Images into kind') {
      steps {
        sh "kind load docker-image ${env.BACKEND_IMAGE} --name ${env.KIND_CLUSTER}"
        sh "kind load docker-image ${env.FRONTEND_IMAGE} --name ${env.KIND_CLUSTER}"
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh "kubectl apply -f k8s/"
      }
    }
    */
  }

  post {
    always {
      echo "Pipeline finished with status: ${currentBuild.currentResult}"
    }
  }
}
