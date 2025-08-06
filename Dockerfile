# Dockerfile
# Use the official AWS Lambda Python base image
FROM public.ecr.aws/lambda/python:3.11

# Copy the requirements file into the image
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Install the specified packages
RUN pip install -r requirements.txt

# Copy your Lambda function code and the context directory into the image
COPY lambda_function.py ${LAMBDA_TASK_ROOT}
COPY context/ ${LAMBDA_TASK_ROOT}/context/

# Set the CMD to your handler.
CMD [ "lambda_function.lambda_handler" ]