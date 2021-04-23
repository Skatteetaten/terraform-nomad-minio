ARG SOURCEIMAGE=minio/minio
ARG SOURCETAG=latest
FROM $SOURCEIMAGE:$SOURCETAG
COPY ./conf/certificates/*.cer /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust