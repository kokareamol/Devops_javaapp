pipeline {
    agent {
        node{
            label 'maven_slave'
        }
    }

    stages {
        stage('testing connectivity') {
            steps {
                echo 'Hello from slave'
            }
        }
    }
}