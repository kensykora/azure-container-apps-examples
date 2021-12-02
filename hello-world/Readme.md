```bash
# Run the docker build
docker build -t kensykora/hello-world-abcd .

# Run locally
docker run -p 8080:80 kensykora/hello-world-abcd 

# Push to docker hub
docker push kensykora/hello-world-abcd
```
