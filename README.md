# checkm2
Container image for `checkm2`.

## Quick Usage

```bash
# Pull the image
docker pull docker.io/picotainers/checkm2:latest

# Run the tool
docker run --rm docker.io/picotainers/checkm2:latest checkm2 --help
```

## Usage with mounted data

```bash
docker run --rm -v "$(pwd):/data" docker.io/picotainers/checkm2:latest checkm2 --help
```
