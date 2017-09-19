IMAGE_NAME=aviata/tf

SCRIPT_NAME=$1
INTERPRETER=python

if [[ -f ${SCRIPT_NAME} ]]; then
  SCRIPT_FILE=${SCRIPT_NAME}
elif [[ -f "${SCRIPT_NAME}.py" ]]; then
  SCRIPT_FILE=${SCRIPT_NAME}.py
elif [[ -f "${SCRIPT_NAME}.sh" ]]; then
  SCRIPT_FILE=${SCRIPT_NAME}.sh
else
  echo "Script '${SCRIPT_NAME}' not found"
  exit 1
fi

if [[ ${SCRIPT_FILE} == *.sh ]]; then
  INTERPRETER=bash
fi

LOCAL_DIR=`pwd`
MOUNT_DIR=/opt

LOCAL_SCRIPT=./${SCRIPT_FILE}
CONTAINER_SCRIPT=${MOUNT_DIR}/${SCRIPT_FILE}

echo "Running script '${SCRIPT_NAME}'"
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
  --name aviata_tf \
  --workdir /opt \
  ${IMAGE_NAME} \
  ${INTERPRETER} ${CONTAINER_SCRIPT}

xhost -SI:localuser:root

