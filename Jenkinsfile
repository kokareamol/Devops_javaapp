def registry = 'https://amolkokare.jfrog.io'
def imageName = 'amolkokare.jfrog.io/docker-repo-docker-local/myapp'
def version   = '2.1.3'


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
        stage("Build Stage AK") {
            steps {
                 echo "----------- build started ----------"
                sh 'mvn clean deploy -Dmaven.test.skip=true'
                 echo "----------- build complted ----------"
            }
        }

        stage("Unit Test AK") {
            steps {
               echo "-----------unit test started ----------"
              sh 'mvn surefire-report:report'
               echo "----------- unit test completed complted ----------"
          }
        }

         
        stage('SonarQube Analysis AK') {
        environment {    
          scannerHome = tool 'sonar-scanner'
        }
        steps{
        withSonarQubeEnv('sonarqube-server') { // If you have configured more than one global server connection, you can specify its name
          sh "${scannerHome}/bin/sonar-scanner"
        }
    }
    }
  

        stage("Jar Publish to Jfrog") {
        steps {
            script {
                    echo '<--------------- Jar Publish Started --------------->'
                     def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"artifact-cred"
                     def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                     def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "jarstaging/(*)",
                              "target": "libs-release-local-libs-release/{1}",
                              "flat": "false",
                              "props" : "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
                     def buildInfo = server.upload(uploadSpec)
                     buildInfo.env.collect()
                     server.publishBuildInfo(buildInfo)
                     echo '<--------------- Jar Publish Ended --------------->'  
            
            }
        }   
    }

           
    stage(" Docker Build ") {
      steps {
        script {
           echo '<--------------- Docker Build Started --------------->'
           app = docker.build(imageName+":"+version)
           echo '<--------------- Docker Build Ends --------------->'
        }
      }
    }

    stage (" Docker Publish "){
        steps {
            script {
               echo '<--------------- Docker Publish Started --------------->'  
                docker.withRegistry(registry, 'artifact-cred'){
                    app.push()
                }    
               echo '<--------------- Docker Publish Ended --------------->'  
            }
        }
    } 

    stage("deploy") {
        steps {
             echo "-----------deploying on k8s cluster ----------"
            sh './deploy.sh'
             echo "----------- deployment successful ----------"
          }
        }
}       
}
