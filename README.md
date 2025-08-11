# My N8N Nodes

This repo contains a collection of custom N8N Nodes that I have developed for my own use.

## Installation

### Quick Install (Latest Version)

To install the latest version of these custom nodes in your n8n instance, run this one-liner:

```bash
curl -sSL https://raw.githubusercontent.com/tkottke90/my-n8n-nodes/master/bin/install.sh | bash
```

### Manual Install with Options

For more control over the installation process, download the install script first:

```bash
# Download the install script
wget https://raw.githubusercontent.com/tkottke90/my-n8n-nodes/master/bin/install.sh
chmod +x install.sh

# Show available options
./install.sh --help

# Install latest version
./install.sh

# Install specific version
./install.sh -v v1.2.3

# List available versions
./install.sh -L

# Preview what would be installed (dry run)
./install.sh --dry-run
```

### Installation Details

The install script will:
- Download the latest release (or specified version) from GitHub
- Extract and install files to your `~/.n8n/custom` directory
- Skip `package.json` and `tsconfig.buildinfo` files to avoid conflicts
- Track the installed version in `~/.n8n/custom/.my-n8n-nodes.version`
- Prompt for confirmation if reinstalling the same version

**Note:** You may need to restart n8n after installation to see the new nodes.

## Setup

Setup has been made easy by a `setup.sh` script in the `bin` folder.  Simply run the following command from the root of the project:

```bash
./bin/setup.sh
``` 

The script will check for dependencies, install them if necessary, and build the project.  It will also optionally start the Docker container if Docker is installed. 

### Development

To deploy your changes to the local n8n development environment, run the following command from the root of the project:

```bash
./bin/deploy-local.sh
```

### Contributing

Contributions are welcome!  Please submit a pull request or open an issue.  I am always open to feedback and suggestions.

## More information

Refer to our [documentation on creating nodes](https://docs.n8n.io/integrations/creating-nodes/) for detailed information on building your own nodes.

## License

[MIT](https://github.com/n8n-io/n8n-nodes-starter/blob/master/LICENSE.md)
