# To run use:
#    docker build -t awk-raycaster .
#    docker run --rm -it awk-raycaster

FROM alpine:latest
RUN apk update && apk add gawk
COPY awkaster.awk /build/awkaster.awk
ENTRYPOINT ["gawk", "-f", "/build/awkaster.awk"]
