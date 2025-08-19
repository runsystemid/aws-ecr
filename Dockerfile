
FROM amazonlinux:2

# Install system dependencies and Docker
RUN amazon-linux-extras install docker -y

# Install unzip (needed for AWS CLI installation)
RUN yum install -y unzip cronie

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
	unzip awscliv2.zip && \
	./aws/install && \
	rm -rf awscliv2.zip aws/

# Verify installations
RUN aws --version && docker --version

# Set working directory
WORKDIR /app

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Add ECR login wrapper for cron
COPY ecr-login.sh /usr/local/bin/ecr-login.sh
RUN chmod +x /usr/local/bin/ecr-login.sh

# Add crontab file
COPY ecr-cron /etc/cron.d/ecr-cron
RUN chmod 0644 /etc/cron.d/ecr-cron

# Set entrypoint script to run at container startup
ENTRYPOINT ["/entrypoint.sh"]
