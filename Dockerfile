FROM r-base:4.3.1

# Install system dependencies (FIX HERE)
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev

# Install R packages
RUN R -e "install.packages(c('plumber','jsonlite','dplyr','lubridate','httr','rvest','readr'), repos='https://cloud.r-project.org')"

WORKDIR /app
COPY . /app

EXPOSE 8000

CMD ["Rscript", "api.R"]