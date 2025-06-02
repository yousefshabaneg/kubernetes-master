#!/bin/bash
docker run -d --name nfs \
  --privileged \
  -v /c/nfs-share:/nfsshare \
  -e SHARED_DIRECTORY=/nfsshare \
  itsthenetwork/nfs-server-alpine
