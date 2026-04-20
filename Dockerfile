# FORCE REBUILD
FROM r-base:4.3.1

# Install ALL required system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    libgit2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev

# Install ALL required R packages (FULL SET)
RUN R -e "install.packages(c(
    'plumber',
    'jsonlite',
    'dplyr',
    'tidyr',
    'lubridate',
    'httr',
    'rvest',
    'readr',
    'stringr',
    'purrr',
    'tibble',
    'tidyselect',
    'curl',
    'openssl',
    'xml2'
), repos='https://cloud.r-project.org')"

WORKDIR /app
COPY . /app

EXPOSE 8000

CMD ["Rscript", "api.R"]