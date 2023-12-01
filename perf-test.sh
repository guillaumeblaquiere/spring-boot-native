LEGACY_IMAGE=$1
NATIVE_IMAGE=$2

# Test if variables are set
if [ -z "${LEGACY_IMAGE}" ]; then
  echo "LEGACY_IMAGE is not set (first parameter)"
  exit 1
fi
if [ -z "${NATIVE_IMAGE}" ]; then
  echo "NATIVE_IMAGE is not set (second parameter)"
  exit 1
fi

# Constants
LEGACY_SERVICE_NAME=spring-boot-native-off
NATIVE_SERVICE_NAME=spring-boot-native-on
LEGACY_CLOUD_RUN_URL=$1
NATIVE_CLOUD_RUN_URL=$2
COMMON_PARAMETER="--platform=managed --region=europe-west1"
AVERAGE_TIME=0


# Function that deploys the images with in arguments the parameter to pass to the deploy command
deploy_image() {
  local parameter=$1
  gcloud run deploy ${LEGACY_SERVICE_NAME} --image=${LEGACY_IMAGE} ${COMMON_PARAMETER} --allow-unauthenticated --memory=595Mi ${parameter} > /dev/null 2>&1

  local memory="128Mi"
  # test is parameter contains gen2
  if [[ "${parameter}" =~ "gen2" ]]; then
    memory="512Mi"
  fi
  gcloud run deploy ${NATIVE_SERVICE_NAME} --image=${NATIVE_IMAGE} ${COMMON_PARAMETER} --allow-unauthenticated --memory=${memory} ${parameter} > /dev/null 2>&1
}

get_urls() {
    LEGACY_CLOUD_RUN_URL=$(gcloud run services describe ${LEGACY_SERVICE_NAME} ${COMMON_PARAMETER}  --format='value(status.address.url)')
    NATIVE_CLOUD_RUN_URL=$(gcloud run services describe ${NATIVE_SERVICE_NAME} ${COMMON_PARAMETER}  --format='value(status.address.url)')
}

# Function that runs the perf test
run_perf_test() {
  local URL=$1
  local total=0
  local counter=10

  for i in $(seq 1 ${counter}); do
    curl -o /dev/null -s ${URL}/kill
    result=$(curl -w "%{time_total}\n" -o /dev/null -s ${URL})
    total=$(echo "${total} + ${result}" | bc)
  done
  AVERAGE_TIME=$(echo " (1000 * ${total}) / ${counter}" | bc)
}


TEXT_CURRENT_CONTEXT="No CPU boost, GEN1"
echo "Deploy images. ${TEXT_CURRENT_CONTEXT}"
deploy_image "--execution-environment=gen1 --no-cpu-boost"

# Get URLs. Only one time
get_urls

echo "Run perf test"
run_perf_test ${LEGACY_CLOUD_RUN_URL}
echo "Average time, legacy ${TEXT_CURRENT_CONTEXT}: ${AVERAGE_TIME} ms"

echo "Run perf test"
run_perf_test ${NATIVE_CLOUD_RUN_URL}
echo "Average time, native ${TEXT_CURRENT_CONTEXT}: ${AVERAGE_TIME} ms"

#------------------
TEXT_CURRENT_CONTEXT="No CPU boost, GEN2"
echo "Deploy images. ${TEXT_CURRENT_CONTEXT}"
deploy_image "--execution-environment=gen2 --no-cpu-boost"

echo "Run perf test"
run_perf_test ${LEGACY_CLOUD_RUN_URL}
echo "Average time, legacy ${TEXT_CURRENT_CONTEXT}: ${AVERAGE_TIME} ms"

echo "Run perf test"
run_perf_test ${NATIVE_CLOUD_RUN_URL}
echo "Average time, native ${TEXT_CURRENT_CONTEXT}: ${AVERAGE_TIME} ms"

#------------------
TEXT_CURRENT_CONTEXT="CPU boost, GEN1"
echo "Deploy images. ${TEXT_CURRENT_CONTEXT}"
deploy_image "--execution-environment=gen1 --cpu-boost"

echo "Run perf test"
run_perf_test ${LEGACY_CLOUD_RUN_URL}
echo "Average time, legacy ${TEXT_CURRENT_CONTEXT}: ${AVERAGE_TIME} ms"

echo "Run perf test"
run_perf_test ${NATIVE_CLOUD_RUN_URL}
echo "Average time, native ${TEXT_CURRENT_CONTEXT}: ${AVERAGE_TIME} ms"

#------------------
TEXT_CURRENT_CONTEXT="CPU boost, GEN2"
echo "Deploy images. ${TEXT_CURRENT_CONTEXT}"
deploy_image "--execution-environment=gen2 --cpu-boost"

echo "Run perf test"
run_perf_test ${LEGACY_CLOUD_RUN_URL}
echo "Average time, legacy ${TEXT_CURRENT_CONTEXT}: ${AVERAGE_TIME} ms"

echo "Run perf test"
run_perf_test ${NATIVE_CLOUD_RUN_URL}
echo "Average time, native ${TEXT_CURRENT_CONTEXT}: ${AVERAGE_TIME} ms"
