FROM mcr.microsoft.com/devcontainers/python:3.13-bookworm

# Install pip for Python 3.13
RUN python -m pip install --upgrade pip


# Install the packages required for development
COPY requirements-dev.txt .
COPY src/python/requirements.txt src/python/
COPY data/requirements.txt data/
RUN pip install -r requirements-dev.txt

ENV ENVIRONMENT=container