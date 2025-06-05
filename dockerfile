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
wget -q https://repos.influxdata.com/influxdb.key
echo '23a1c8836f0afc5ed24e0486339d7cc8f6790b83886c4c96995b88a061c5bb5d influxdb.key' | sha256sum -c && cat influxdb.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/influxdb.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdb.gpg] https://repos.influxdata.com/debian stable main' | tee /etc/apt/sources.list.d/influxdata.list

# Aktualisiere Paketlisten und installiere InfluxDB
RUN apt-get update && apt-get install -y influxdb2 influxdb2-cli

# Installation von Grafana
RUN mkdir -p /etc/apt/keyrings/
    wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list
    apt-get update && apt-get install -y grafana

# Installation von Webmin
RUN apt-get update && apt-get install -y webmin

# Installation von Telegram-CLI (via git)
RUN apt-get install -y telegraf

# Öffne Ports
EXPOSE 80 443 3000 8086 10000

# Starte InfluxDB, Grafana und Webmin beim Containerstart
CMD service influxdb start && \
    service grafana-server start && \
    service webmin start && \
    tail -f /dev/null
