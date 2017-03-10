FROM alpine:3.5
MAINTAINER Bradley Beddoes <bradleybeddoes@gmail.com>

ADD s6/1.19.1.1/s6-overlay-amd64.tar.gz /

# Base
ENV PACKAGES="musl linux-headers build-base libffi libffi-dev openssl \
              openssl-dev nginx git ca-certificates yaml-dev \
              python3 python3-dev bash"

RUN echo \
  && apk add --update --no-cache $PACKAGES \
  && mkdir /run/nginx \

  && python3 -m ensurepip \
  && pip3 install --upgrade pip setuptools

# OIDC
ENV OIDC_ROOT="/opt/oidc" \
    ROHE_OIDC_PROJECTS="pyjwkest pyoidc otest oidctest" \
    OPENIDC_OIDC_PROJECTS="fedoidc" \
    OIDC_PROJECTS="pyjwkest pyoidc otest fedoidc oidctest"

## Acquire testing tool and dependencies
RUN mkdir -p $OIDC_ROOT \
    && for project in $ROHE_OIDC_PROJECTS ; do git clone https://github.com/rohe/${project}.git ${OIDC_ROOT}/${project}; done \
    && for project in $OPENIDC_OIDC_PROJECTS ; do git clone https://github.com/openidc/${project}.git ${OIDC_ROOT}/${project}; done

## Build testing tool and dependencies
RUN for project in $OIDC_PROJECTS ; do cd ${OIDC_ROOT}/${project}; python3 setup.py install ; done

## Setup testing tool instance with TLS
ENV OIDC_TEST_PROJECT_ROOT="$OIDC_ROOT/oidctest" \
    OIDC_TEST_SERVER_ROOT="$OIDC_ROOT/oidctest_server_instance"
RUN oidc_setup.py ${OIDC_TEST_PROJECT_ROOT} ${OIDC_TEST_SERVER_ROOT} \
    && openssl req -newkey rsa:2048 -nodes -keyout \
    ${OIDC_TEST_SERVER_ROOT}/oidc_op/certs/key.pem -x509 -days 365 \
    -out $OIDC_TEST_SERVER_ROOT/oidc_op/certs/cert.pem \
    -subj "/CN=oidctest" \
    && mkdir -p ${OIDC_TEST_SERVER_ROOT}/oidc_op/proc \
    && chown nobody ${OIDC_TEST_SERVER_ROOT}/oidc_op/proc

## Documentation
ENV WEB_DOCS_ROOT="/var/www/docs" \
    OIDC_PROJECT_DOC_MAKEFILE_ROOTS="pyjwkest/doc pyoidc oidctest/docs" \
    OIDC_PROJECT_DOCS="pyjwkest/doc pyoidc/doc oidctest/docs"

RUN pip install sphinx \
    && mkdir $WEB_DOCS_ROOT \
    && for doc in $OIDC_PROJECT_DOC_MAKEFILE_ROOTS ; do cd ${OIDC_ROOT}/${doc}; make html ; done \
    && for doc in $OIDC_PROJECT_DOCS ; do ln -s ${OIDC_ROOT}/${doc}/_build/html ${WEB_DOCS_ROOT}/`echo ${doc} | sed 's/\/.*//'` ; done

# Finalization
COPY root /
EXPOSE 80 443 10000-10100 60000
ENTRYPOINT ["/init"]
