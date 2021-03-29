FROM openshift/golang-builder:1.10 AS builder
ENV __doozer=update BUILD_RELEASE=3 BUILD_VERSION=v3.11.404 OS_GIT_MAJOR=3 OS_GIT_MINOR=11 OS_GIT_PATCH=404 OS_GIT_TREE_STATE=clean OS_GIT_VERSION=3.11.404-3 SOURCE_GIT_TREE_STATE=clean 
ENV __doozer=merge OS_GIT_COMMIT=2ea5517 OS_GIT_VERSION=3.11.404-3-2ea5517 SOURCE_DATE_EPOCH=1551375602 SOURCE_GIT_COMMIT=2ea5517e5d33531ee8b838c70666e484a79cd49d SOURCE_GIT_TAG=v5.2.0-beta3-3037-g2ea5517e5d SOURCE_GIT_URL=https://github.com/openshift/grafana 

ENV GOPATH="/go"
ENV GOBIN="${GOPATH}/bin"
ENV PATH="${GOBIN}:${PATH}"
RUN mkdir -p $GOBIN

COPY . $GOPATH/src/github.com/grafana/grafana

#RUN yum install -y make git
RUN cd $GOPATH/src/github.com/grafana/grafana && go run build.go build
RUN cp $GOPATH/src/github.com/grafana/grafana/bin/linux-$(go env GOARCH)/grafana-server /usr/bin/
RUN rm -rf $GOPATH/src/github.com/grafana/grafana/.git

FROM openshift3/ose-base:v3.11.404.20210318.061743
ENV __doozer=update BUILD_RELEASE=3 BUILD_VERSION=v3.11.404 OS_GIT_MAJOR=3 OS_GIT_MINOR=11 OS_GIT_PATCH=404 OS_GIT_TREE_STATE=clean OS_GIT_VERSION=3.11.404-3 SOURCE_GIT_TREE_STATE=clean 
ENV __doozer=merge OS_GIT_COMMIT=2ea5517 OS_GIT_VERSION=3.11.404-3-2ea5517 SOURCE_DATE_EPOCH=1551375602 SOURCE_GIT_COMMIT=2ea5517e5d33531ee8b838c70666e484a79cd49d SOURCE_GIT_TAG=v5.2.0-beta3-3037-g2ea5517e5d SOURCE_GIT_URL=https://github.com/openshift/grafana 

ENV GOPATH="/go"
ENV GOBIN="${GOPATH}/bin"
ENV PATH="${GOBIN}:${PATH}"
RUN mkdir -p $GOBIN

COPY --from=builder /usr/bin/grafana-server /usr/bin/grafana-server
COPY --from=builder $GOPATH/src/github.com/grafana/grafana $GOPATH/src/github.com/grafana/grafana


# doesn't require a root user.
USER 1001

WORKDIR $GOPATH/src/github.com/grafana/grafana
ENTRYPOINT ["/usr/bin/grafana-server"]

LABEL \
        io.k8s.display-name="Grafana" \
        io.k8s.description="Grafana is an open source, feature rich metrics dashboard and graph editor for Graphite, Elasticsearch, OpenTSDB, Prometheus and InfluxDB." \
        io.openshift.tags="openshift" \
        maintainer="Frederic Branczyk <fbranczy@redhat.com>" \
        License="GPLv2+" \
        vendor="Red Hat" \
        name="openshift3/grafana" \
        com.redhat.component="grafana-container" \
        io.openshift.maintainer.product="OpenShift Container Platform" \
        io.openshift.maintainer.component="Monitoring" \
        release="3" \
        io.openshift.build.commit.id="2ea5517e5d33531ee8b838c70666e484a79cd49d" \
        io.openshift.build.source-location="https://github.com/openshift/grafana" \
        io.openshift.build.commit.url="https://github.com/openshift/grafana/commit/2ea5517e5d33531ee8b838c70666e484a79cd49d" \
        version="v3.11.404"
