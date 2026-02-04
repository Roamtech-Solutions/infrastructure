# Dockerfile for ERPNext Wallet App
FROM frappe/erpnext:version-15

USER root

# 🔥 FIX: Force /bin/sh to bash (required for bench build)
RUN apt-get update && apt-get install -y bash \
    && ln -sf /bin/bash /bin/sh

# Install Node.js and Yarn if not present (skip if your base image already has them)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    npm install -g yarn

# Copy local source only if not building from Git
COPY --chown=frappe:frappe . /tmp/build/
RUN mkdir -p /home/frappe/frappe-bench/apps/app && \
        cp -r /tmp/build/* /home/frappe/frappe-bench/apps/app/ && \
        rm -rf /tmp/build;

# Fix ownership for the frappe user
RUN chown -R frappe:frappe /home/frappe/frappe-bench/apps/app

USER frappe

# Install the app's Python dependencies using pip
WORKDIR /home/frappe/frappe-bench
RUN /home/frappe/frappe-bench/env/bin/pip install -e ./apps/app
# # Build assets (this is the key step)
# RUN bench build --production --hard-link
# # Build assets and copy to a safe location
# RUN bench build --production --hard-link && \
#      mkdir -p /assets-built && \
#      cp -r sites/assets/* /assets-built/

RUN bench build --production --hard-link && \
    mkdir -p /home/frappe/frappe-bench/assets-built && \
    cp -r sites/assets/* /home/frappe/frappe-bench/assets-built/

# (Optional) Clean up node_modules and yarn cache to reduce image size
USER root
RUN rm -rf /home/frappe/frappe-bench/apps/*/node_modules && \
    yarn cache clean

USER frappe
# The app will be installed into the site by the Kubernetes init job,
# not written into the image here.

