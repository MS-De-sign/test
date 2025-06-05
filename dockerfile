FROM debian:latest

# Aktualisiere und installiere grundlegende Pakete
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    apt-transport-https \
    software-properties-common \
    gnupg2

# Füge den neuen InfluxDB GPG-Schlüssel hinzu
RUN curl --silent --location -O \
    https://repos.influxdata.com/influxdata-archive.key
RUN echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
    | sha256sum --check - && cat influxdata-archive.key \
    | gpg --dearmor \
    | tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
    && echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
    | tee /etc/apt/sources.list.d/influxdata.list

# Aktualisiere Paketlisten und installiere InfluxDB
RUN apt-get update && apt-get install -y influxdb2 influxdb2-cli

# Installation von Grafana
RUN mkdir -p /etc/apt/keyrings/
RUN wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null
RUN echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list
RUN apt-get update && apt-get install -y grafana

# Installation von Webmin
RUN curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
RUN sh webmin-setup-repo.sh
RUN apt-get install webmin --install-recommends

# Installation von Telegram-CLI (via git)
RUN apt-get install -y telegraf

# Öffne Ports
EXPOSE 80 443 3000 8086 10000

# Starte InfluxDB, Grafana und Webmin beim Containerstart
CMD service influxdb start && \
    service grafana-server start && \
    service webmin start && \
    tail -f /dev/null
