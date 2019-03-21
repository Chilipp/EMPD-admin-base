#!/bin/bash
docker-entrypoint.sh postgres -V
pg_ctl start
