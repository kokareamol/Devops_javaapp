pipeline {
    agent {
        node {
            label 'maven'
        }
    }
environment{
    PATH = "/opt/apache-maven-3.9.6/bin:$PATH"
}
    stages {
        stage("Build") {
            steps {
                 echo "----------- build started ----------"
                sh 'mvn clean deploy -Dmaven.test.skip=true'
                 echo "----------- build complted ----------"
            }
        }
        
        stage("Unit Test") {
            steps {
                 echo "-----------unit test started ----------"
                sh 'mvn surefire-report:report'
                 echo "----------- unit test completed complted ----------"
            }
        }
    
        stage('SonarQube Analysis') {
        environment {    
          scannerHome = tool 'valaxy-sonar-scanner'
        }
        steps{
        withSonarQubeEnv('valaxy-sonarqube-server') { // If you have configured more than one global server connection, you can specify its name
          sh "${scannerHome}/bin/sonar-scanner"
        }
    }
  }
}
}