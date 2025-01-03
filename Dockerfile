# --- Build stage ---
# Need to use ubuntu instead of debian to get a recent Java version
FROM ubuntu:noble AS build

WORKDIR /app

# Install packages required for building
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y gcc g++ make gnucobol zlib1g-dev curl openjdk-21-jre-headless && \
    rm -rf /var/lib/apt/lists/*

# Perform data extraction first to allow Docker to cache this layer
COPY Makefile .
RUN make data

# Copy source files and build
COPY main.cob .
COPY src ./src
COPY cpp ./cpp
COPY blobs ./blobs
RUN make -j $(nproc)

# --- Runtime stage ---
FROM ubuntu:noble

WORKDIR /app

# Install runtime packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y gnucobol zlib1g tini && \
    rm -rf /var/lib/apt/lists/*

# Copy the build results
COPY --from=build /app/cobolcraft .
COPY --from=build /app/blobs ./blobs
COPY --from=build /app/data/generated/reports/*.json ./data/generated/reports/
COPY --from=build /app/data/generated/data ./data/generated/data

# Run the server within Tini (to handle signals properly)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/app/cobolcraft"]
