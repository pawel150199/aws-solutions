FROM public.ecr.aws/lambda/python:3.12

LABEL MAINTAINER pawel.polski99@gmail.com

COPY main.py requirements.txt .

RUN pip install -r requirements.txt

CMD [ "main.lambda_handler" ]