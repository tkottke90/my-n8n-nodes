# My N8N Nodes

This repo contains a collection of custom N8N Nodes that I have developed for my own use.  

## Setup

Setup has been made easy by a `setup.sh` script in the `bin` folder.  Simply run the following command from the root of the project:

```bash
./bin/setup.sh
``` 

The script will check for dependencies, install them if necessary, and build the project.  It will also optionally start the Docker container if Docker is installed. 

## Development

To deploy your changes to the local n8n development environment, run the following command from the root of the project:

```bash
./bin/deploy-local.sh
```

## More information

Refer to our [documentation on creating nodes](https://docs.n8n.io/integrations/creating-nodes/) for detailed information on building your own nodes.

## License

[MIT](https://github.com/n8n-io/n8n-nodes-starter/blob/master/LICENSE.md)
