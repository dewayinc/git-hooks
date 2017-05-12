#!/usr/bin/env bash

source ${UTILS_PATH}/log_messages.sh

function create_env () {
  APP_NAME=$(basename ${APP_PATH})

  section "Create virtual environment with Python ${PYTHON_VERSION} for \"${APP_NAME}\""
  PYTHONPATH=${VENV_PYTHONPATH} ${VENV_BIN} -p /usr/local/bin/python${PYTHON_VERSION} --prompt="(${APP_NAME} Python${PYTHON_VERSION}) " ${ENV_PATH} || exit 1

  # Solution source: https://community.webfaction.com/questions/18791/why-can-my-virtualenv-still-see-system-site-packages/18792
  touch ${APP_PATH}/env/lib/python${PYTHON_VERSION}/sitecustomize.py
}

ENV_PATH=${APP_PATH}/env

if [ ! -d ${ENV_PATH} ]; then
  # If the env does not exist, create it
  if [ -f ${PROJECT_PATH}/app.json ]; then
    PYTHON_VERSION=$(cat ${PROJECT_PATH}/app.json | ${JQ_BIN} -r '.environments.webfaction.python?')
  fi

  if [[ "${PYTHON_VERSION}" == "null" ]] || [[ "${PYTHON_VERSION}" == "" ]]; then
    PYTHON_VERSION=2.7
  fi

  create_env

elif [ -f ${APP_PATH}/app.json ] && [ -f ${PROJECT_PATH}/app.json ]; then
  # If the env does exist, check if the Python version is updated and recreate the env
  NEW_PYTHON_VERSION=$(cat ${PROJECT_PATH}/app.json | ${JQ_BIN} -r '.environments.webfaction.python?')
  OLD_PYTHON_VERSION=$(cat ${APP_PATH}/app.json | ${JQ_BIN} -r '.environments.webfaction.python?')

  if [[ "${NEW_PYTHON_VERSION}" != "null" ]] && [[ "${OLD_PYTHON_VERSION}" != "${NEW_PYTHON_VERSION}" ]]; then
    rm -rf ${BACKUPS_PATH}/env && mv ${APP_PATH}/env ${BACKUPS_PATH}
    PYTHON_VERSION=${NEW_PYTHON_VERSION}

    create_env
  fi
fi
