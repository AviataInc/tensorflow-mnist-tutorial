IMAGE_NAME=aviata/hal

SCRIPT_NAME=$1
INTERPRETER=python

function run() {
  LOCAL_DIR=`pwd`
  MOUNT_DIR=/opt

  echo "Running command '${@}'"
  export XSOCK=/tmp/.X11-unix
  xhost +SI:localuser:root

  docker run \
    --interactive \
    --tty \
    --volume ${HOME}/.Xauthority:/root/.Xauthority \
    --volume ${HOME}/Documents:/root/Documents \
    --volume /etc/localtime:/etc/localtime \
    --volume ${LOCAL_DIR}/data/tmp:/tmp \
    --volume /tmp/.X11-unix:/tmp/.X11-unix:rw \
    --volume ${LOCAL_DIR}:${MOUNT_DIR} \
    --env DISPLAY=$DISPLAY \
    --env GDK_SCALE \
    --env GDK_DPI_SCALE \
    --publish 6006:6006 \
    --rm \
    --name aviata_ai \
    --workdir ${MOUNT_DIR} \
    ${IMAGE_NAME} \
    $@

  xhost -SI:localuser:root
}

# Determine our run mode if possible
if [[ $# -gt 1 ]]; then
  run $@
elif [[ -z ${SCRIPT_NAME} ]]; then
  run python
elif [[ -x ${SCRIPT_NAME} ]]; then
  run ./${SCRIPT_NAME}
elif [[ -f ${SCRIPT_NAME} ]] && [[ ${SCRIPT_NAME} == *.py ]]; then
  run python ${SCRIPT_NAME}
elif [[ -f ${SCRIPT_NAME} ]] && [[ ${SCRIPT_NAME} == *.sh ]]; then
  run bash ${SCRIPT_NAME}
elif [[ -f "${SCRIPT_NAME}.py" ]]; then
  run python ${SCRIPT_NAME}.py
elif [[ -f "${SCRIPT_NAME}.sh" ]]; then
  run bash ${SCRIPT_NAME}.sh
else
  run $@
fi
#  echo "Script '${SCRIPT_NAME}' not found"
#  exit 1
#fi

