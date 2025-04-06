#!/bin/sh

sudo groupadd -f node_exporter

sudo useradd -g node_exporter --no-create-home --shell /bin/false node_exporter

sudo mkdir /etc/node_exporter

sudo chown node_exporter:node_exporter /etc/node_exporter

cd /tmp

mkdir node_exporter_download

cd node_exporter_download

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

tar -xvf node_exporter-1.8.2.linux-amd64.tar.gz

sudo mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/bin/

sudo chown node_exporter:node_exporter /usr/bin/node_exporter

sudo cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
    [Unit]
    Description=Node Exporter
    Documentation=https://prometheus.io/docs/guides/node-exporter/
    Wants=network-online.target
    After=network-online.target

    [Service]
    User=node_exporter
    Group=node_exporter
    Type=simple
    Restart=on-failure
    ExecStart=/usr/bin/node_exporter \
     --web.listen-address=:9229

    [Install]
    WantedBy=multi-user.target
EOF

sudo chmod 664 /etc/systemd/system/node_exporter.service

sudo rm -rf /tmp/node_exporter_download

sudo systemctl daemon-reload

sudo systemctl start node_exporter.service

sudo systemctl enable node_exporter.service
