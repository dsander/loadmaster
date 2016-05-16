# Loadmaster

Loadmaster builds Docker images for your project's pull request publicly without exposing the registry credentials.

This project was started because, to my knowledge, no public CI service has the ability to build Docker images for a project's pull request without exposing the registry credentials.

## How it works

1. Set up Loadmaster on your server/VPS
2. Configure the Docker images Loadmaster should build for your project
3. Configure your Github repository to send Loadmaster a webhook for pull request actions
3. For every new/updated Pull Request a new docker image will be build and pushed to the Docker Hub

## Installation

Use the provided `docker-compose.yml` and run `docker-compose up -d` on your server.

## Contributing

I am still learning about Elixir and Phoenix, feedback and suggestions on how to improve the code are very welcome!
