def mvn
def DockerTag() {
	def tag = sh script: 'git rev-parse HEAD', returnStdout:true
	return tag
	}	
pipeline {
  agent { label 'master' }
    tools {
      maven 'Maven'
      jdk 'JAVA_HOME'
    }
  environment{
  	DOCKER_TAG = DockerTag()
 }
  stages {
    stage ('Maven Build') {
      steps {
        script {
          mvn= tool (name: 'Maven', type: 'maven') + '/bin/mvn'
        sh "${mvn} clean package"
        }
      }
    }
    stage('Build Docker Image'){
      steps {
        sh 'docker build . -t dileep95/spring:${DOCKER_TAG}'
        }
      }  
     stage('Docker Container'){
       steps{
       withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'docker_pass', usernameVariable: 'docker_user')]) {
       	  sh 'docker login -u ${docker_user} -p ${docker_pass}'
          sh 'docker push dileep95/spring:${DOCKER_TAG}'
	  sh 'docker run -d -p 8050:8050 --name SpringbootApp dileep95/spring:${DOCKER_TAG}'
        }
      }
    }    	
    stage('ssh'){
	steps{
              sh "chmod +x replace.sh"
	      sh "./replace.sh ${DOCKER_TAG}"
                sshagent(['k8s']) {	      
			sh "scp -o StrictHostKeyChecking=no services.yml changed-pod.yml prithdileep@104.154.78.159:/home/prithdileep"
		script{
		try{
		  sh "ssh prithdileep@104.154.78.159 kubectl create -f ."
		  }
		catch(error){
		sh "ssh prithdileep@104.154.78.159 kubectl apply -f ."
            }
        }
    }
   }
  } 
	}
post {
    always {
sh 'echo "This will always run"'
mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br>URL: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "Success: Project name -> ${env.JOB_NAME}", to: "prithdileep@gmail.com";
    }
    failure {
sh 'echo "This will run only if failed"'
      mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br>URL: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "ERROR: Project name -> ${env.JOB_NAME}", to: "prithdileep@gmail.com";
    }
  }
}
