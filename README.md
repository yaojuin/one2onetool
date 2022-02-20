# one2onetool

## Jenkins Setup
The CICD pipeline is ran on Jenkins master in Docker Desktop for simplicity. Ideally, build agents should be used in a production grade Jenkins instance. This particular pipeline will deploy to AWS ECS.

- Build custom jenkins image using the Dockerfile provided
` docker build -f ./Dockerfile_jenkins -t <tagName> . `
- Use the built docker image and run it with host volume mounts on jenkins home directory, docker socket and .aws (for credentials purposes)
` docker run -d -v "/d/jenkins":/var/jenkins_home -v //var/run/docker.sock:/var/run/docker.sock -v "/c/Users/Yao Juin/.aws":/$HOME/.aws -p 8080:8080 -p 50000:50000 <image_id>`
- Alternatively, you can mount using the UI from Docker Desktop 
    - D:\jenkins ---> /var/jenkins_home
    - C:\Users\Yao Juin\.aws ---> /var/jenkins_home/.aws
    - //var/run/docker.sock ---> /var/run/docker.sock
 
- Access Jenkins through localhost:8080 on your web browser and setup Jenkins with initial admin credentials. Initial password can be found in the container logs.
- Choose to use the recommended plugins and additionally also install Docker Pipeline Plugin and Docker plugin
- Install and start ngrok to expose jenkins to github webhook. Copy the the HTTPS ngrok URL and append /github-webhook/ to it and paste it under Settings --> Webhook ---> Payload URL in    the Github repository.
`  Navigate to the directory ngrok is installed and run the following command from CMD "./ngrok http 8080" `
- Set gmail smtp and add credentials for email notification purposes under Configure Jenkins (smtp.gmail.com port 465). Take note to set the gmail account used to allow "Less Secure App Access". The account cannot have MFA enabled for this option to be available.
- Create pipeline job in jenkins to monitor on both staging branch and release branch. 

## AWS Resources Used

- ECS
    - EC2
    - Task Definitions with correct DATA_FILE environment variable set for staging and prod respectively.

## Possible Improvements

- Before building docker image step, scanning code for sensitive information and static code analysis can be implemented to improve on code quality.\
- Jenkins Shared Library can be used to further modularise the pipeline steps to make them reusable.
- Depending on workflow, approval step can be injected before deploying the release branch to ensure some form of release control.
- A better choice for Email SMTP would be to use AWS SES.