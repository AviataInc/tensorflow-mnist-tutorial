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
    --publish 7007:7007 \
    --rm \
    --name aviata_ai \
    --workdir ${MOUNT_DIR} \
    ${IMAGE_NAME} \
    $@

  xhost -SI:localuser:root
}

# Determine our run mode if possible
if [[ $# -eq 0 ]]; then
  run python
elif [[ $# -gt 1 ]]; then
  run $@
elif [[ ${SCRIPT_NAME} == "help" ]]; then
  echo "Usage: ./run.sh : run python REPL"
  echo "       ./run.sh <cmd> <arg> [arg...] : run any valid command within the container"
  echo "       ./run.sh <help> : prints this help dialog"
  echo "       ./run.sh <notebook> : runs Jupyter Notebook"
  echo "       ./run.sh <executable> : any valid executable in the current directory"
  echo "       ./run.sh <script> : any valid .py or .sh script (with or without extension specified)"
  echo "       ./run.sh <cmd> : run any valid command within the container"
elif [[ ${SCRIPT_NAME} == "notebook" ]]; then
  echo "Running Jupyter Notebook on port 7007"
  run jupyter notebook --allow-root --no-browser --ip=0.0.0.0 --port=7007
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

