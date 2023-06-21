#!/usr/bin/env bash

tar xJf zips-and-tarballs/tpc-h-tool.tar.xz -C srcs/

tar -Oxf zips-and-tarballs/tpccuva-1.2.4-tarball.tar.gz \
    tpccuva-1.2.4-tarball/tpccuva-1.2.4.tar.gz | tar xzf - -C srcs/

tar xzf zips-and-tarballs/tpc-e-tool.tar.gz -C srcs/

tar xzf zips-and-tarballs/tpc-e-scripts.tar.gz -C srcs/

tar xzf zips-and-tarballs/unixODBC-2.3.11.tar.gz -C srcs/
