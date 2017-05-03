#!/usr/bin/env bash

cd $(dirname ${0})

source `pwd`/utils/set_paths.sh
source ${UTILS_PATH}/log_messages.sh

section "Check dependencies"
${UTILS_PATH}/check_dependencies.sh
check_error $?

section "Set project's environment variables"
touch ${APP_PATH}/.env
cp ${APP_PATH}/.env ${PROJECT_PATH}
check_error $?

section "Activate the virtual environment"
${UTILS_PATH}/prepare_env.sh
cd ${PROJECT_PATH}
source ${APP_PATH}/env/bin/activate
check_error $?
log $(python --version 2>&1) # Solution source: http://stackoverflow.com/a/23862813/4694834
log "$(pip --version)"

${UTILS_PATH}/install_requirements.sh

${UTILS_PATH}/read_app_json.sh

${UTILS_PATH}/restart_server.sh

success "Deployment performed successfully!"
