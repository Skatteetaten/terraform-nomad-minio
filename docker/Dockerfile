ARG SOURCEIMAGE=minio/minio
ARG SOURCETAG=latest
FROM $SOURCEIMAGE:$SOURCETAG

COPY certs/MinervaRootCA-2039.crt /usr/local/share/ca-certificates/MinervaRootCA-2039.crt
COPY certs/minrootca.crt /usr/local/share/ca-certificates/minrootca.crt
COPY certs/minrootca2039.crt /usr/local/share/ca-certificates/minrootca2039.crt
COPY certs/SKEROOTCA2033.crt /usr/local/share/ca-certificates/SKEROOTCA2033.crt
COPY ./conf/certificates/*.cer /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust