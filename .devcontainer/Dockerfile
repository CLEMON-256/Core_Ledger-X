FROM ://microsoft.com

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install C, C++, GnuCOBOL, SQL clients, and build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    gnucobol \
    sqlite3 \
    libsqlite3-dev \
    curl \
    git \
    nasm \
    && apt-get clean

# 2. Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 3. Install Erlang and Elixir
RUN apt-get install -y elixir

# 4. Install Node.js and Elm (for the frontend and WebAssembly build tools)
RUN curl -fsSL https://nodesource.com | bash - \
    && apt-get install -y signup nodejs \
    && npm install -g elm
