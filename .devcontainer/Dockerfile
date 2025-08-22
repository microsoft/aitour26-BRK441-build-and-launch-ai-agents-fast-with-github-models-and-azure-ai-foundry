FROM mcr.microsoft.com/devcontainers/python:3.13-bookworm

# Install pip for Python 3.13
RUN python -m pip install --upgrade pip


# Install the packages required for development
COPY requirements-dev.txt .
COPY data/requirements.txt data/
RUN pip install -r requirements-dev.txt && \
    pip install -r data/requirements.txt

ENV ENVIRONMENT=container
