ARG SOURCEIMAGE=gitlab-container-registry.minerva.loc/plattform/foundation/dockerimages/minio-custom-image
ARG SOURCETAG=latest
FROM $SOURCEIMAGE:$SOURCETAG

COPY certificates/MinervaRootCA-2039.cer /usr/local/share/ca-certificates/MinervaRootCA-2039.cer
COPY certificates/minrootca.cer /usr/local/share/ca-certificates/minrootca.cer
COPY certificates/minrootca2039.cer /usr/local/share/ca-certificates/minrootca2039.cer
COPY certificates/SKEROOTCA2033.cer /usr/local/share/ca-certificates/SKEROOTCA2033.cer
COPY ./conf/certificates/*.cer /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust