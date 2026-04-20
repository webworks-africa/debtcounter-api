FROM r-base:4.3.1

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev

RUN R -e "install.packages(c('plumber','jsonlite','dplyr','lubridate','httr','rvest','readr'), repos='https://cloud.r-project.org')"

WORKDIR /app
COPY . /app

EXPOSE 8000

CMD ["Rscript", "api.R"]