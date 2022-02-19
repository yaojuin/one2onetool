# one2onetool

## Instructions
The CICD pipeline is ran on Jenkins master in Docker Desktop for simplicity. Build agents should be used in a production grade Jenkins instance.

- Build custom jenkins image using the Dockerfile provided
- Use the built docker image and run it with host volume mounts on jenkins home directory, docker socket and .aws (for credentials purposes)
` docker run -d -v D:\jenkins:/var/jenkins_home -v //var/run/docker.sock:/var/run/docker.sock -v C:\Users\Yao Juin\.aws:/$HOME/.aws -p 8080:8080 -p 50000:50000 <image_id>`
- Setup Jenkins with initial admin credentials
- Install and start ngrok to expose jenkins to github webhook
` ./ngrok http 8080 `
- Set gmail smtp and add credentials for email notification purposes under Configure Jenkins (smtp.gmail.com port 465)
- Create pipeline job in jenkins to monitor on both staging branch and release branch. 