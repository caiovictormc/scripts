#!/bin/bash

usage() {
  echo "Usage: ${SCRIPT_NAME} [option]..."
  echo "  --user ADMIN_USER          InfluxDB Admin Username"
  echo "  --password ADMIN_PASSWORD  InfluxDB Admin Password"
  echo "  --database DB_NAME         InfluxDB Name / Default = devbd"
  echo "  --dev                      Expose the default ports / Optional"
}

VERBOSE=0

# Production enviroment in development
DEV_CONTAINER=1

DB_NAME="devdb"

while getopts "hv-:" opt "$@"; do
  case ${opt} in
    -)
      case ${OPTARG} in
        help)
          usage
          exit 1
          ;;

        user)
          ADMIN_USER="${!OPTIND}"
          OPTIND=$(( $OPTIND + 1 ))
          ;;
        
        database)
          DB_NAME="${!OPTIND}"
          OPTIND=$(( $OPTIND + 1 ))
          ;;

        password)
          ADMIN_PASSWORD="${!OPTIND}"
          OPTIND=$(( $OPTIND + 1 ))
          ;;

        dev)
          DEV_CONTAINER=1
          ;;

        *)
          echo "Unrecognized option: ${OPTARG}"
          exit 1
          ;;
      esac
      ;;

    h)
      usage
      exit 1
      ;;

    v)
      VERBOSE=1
      ;;

    *)
      echo "Unrecognized option: ${opt}"
      exit 1
      ;;
  esac
done

if [ "${VERBOSE}" == 1 ]; then
  echo "INFLUXDB_ADMIN_USER       = ${ADMIN_USER}"
  echo "INFLUXDB_ADMIN_PASSWORD   = ${ADMIN_PASSWORD}"
  echo "INFLUXDB_DB               = ${DB_NAME}"
  echo "DEV                       = ${DEV_CONTAINER}"
fi

if [ -z "${ADMIN_USER}" ] || [ -z "${ADMIN_PASSWORD}" ]; then
  echo "'--user' and '--password' are required flags"
  exit 1
fi


docker run -p 8086:8086 -p 2003:2003 -p 8083:8083 \
  -e INFLUXDB_ADMIN_ENABLED=true -e INFLUXDB_GRAPHITE_ENABLED=true \
  -e INFLUXDB_ADMIN_USER=${ADMIN_USER} -e INFLUXDB_ADMIN_PASSWORD=${ADMIN_PASSWORD} \
  -e INFLUXDB_DB=${DB_NAME} \
  influxdb
