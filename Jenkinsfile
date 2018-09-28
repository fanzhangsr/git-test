#!groovy 
pipeline {  
    agent any 
     stages {
        stage('Debugging'){
            steps { 

                echo '------------------------------------------------'
                echo 'Print Shell Varibles'
                echo sh(returnStdout: true, script: 'env')
                echo '------------------------------------------------'
            }
        }
        stage('Validation') {
              when{
                expression  
                {
                    return BRANCH_NAME != "master"
                }
            }
            steps { 
                echo 'Building..' 
                sh '''
                   ansible-playbook apache-verify-deploy.yml -i verify-env/ 
                '''
            }
        }
        stage('Deploy') {
            when{
                expression  
                {
                    return BRANCH_NAME == "master"
                }
            }
            steps { 
                echo 'Deploying....'
                            // Disabled deployment on purpose so no changes push to QA
            /*******************************************************/
                sh '''
                   ansible-playbook apache-verify-deploy.yml -i preview-env/ --tags restart
                   '''
            /********************************************************/
            }
        }
     }
        post {
        always {
            echo 'Build finished'
            deleteDir() /* clean up our workspace */
        }
  success {
            echo 'Build succeeeded!'
            script{
            mail (
                 bcc: '', 
                 body: """<p>STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
            <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""", 
                 cc: '', from: 'hbcdigitalunix@s5a.com', 
                 mimeType: 'text/html', 
                 replyTo: '', 
                 subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'", 
                 to: 'hbcdigitalin'
                 )
                 if (BRANCH_NAME == "master"){  
                  slackSend (color: '#00FF00',channel: "#off5th_preview_env", message: "Deployment SUCCEEDED: ${env.JOB_NAME} ${env.BUILD_NUMBER}")
                }}
        }
        unstable {
            echo 'UnStable not sure'
        }
        failure {
            echo 'Build Failed'
            mail (
                 bcc: '', 
                 body: """<p>STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
            <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""", 
                 cc: '', from: 'hbcdigitalunix@s5a.com', 
                 mimeType: 'text/html', 
                 replyTo: '', 
                 subject: "FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'", 
                 to: 'ed_perry@s5a.com'
                 )
                  slackSend (color: '#FF0000', 
                           channel: "#off5th_preview_env", 
                           message: "Build FAILED: ${env.JOB_NAME} ${env.BUILD_NUMBER}")
                 
        }
        changed {
            echo 'Build Changes detected'
        }
} 
} 
