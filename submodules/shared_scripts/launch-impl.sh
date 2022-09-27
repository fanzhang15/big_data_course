# (C) Copyright IBM Corp. 2020  All Rights Reserved.
#
# This script implements/overrides the base functions defined in launch.sh
# This implementation is specific to this auditwebhook operator

# auditwebhook operator specific variables
caseName="ibm-auditwebhook-operator"

inventory="cp4dAuditWebhookOperatorSetup"
caseCatalogName="ibm-auditwebhook-operator-catalog"
catalogNamespace="openshift-marketplace"

channelName="alpha"
cr_system_status="betterThanYesterday"
# - variables specific to catalog/operator installation
catalogNamespace="openshift-marketplace"

declare -a case_dependencies=(
#    "ibm-cp-common-services"
)

dependent_case_tgz() {
    local case_name=$1
    local input_dir=$2

    # if there are multiple versions of the case is downloaded ( this happens when same dependency
    # is requested by a different case but with a different version)
    # use the latest version
    # the below command finds files that start with dependent case name, sorts by semver field
    # note that this sort flag is only available on GNU sort ( linux versions)
    case_tgz=$(find "${input_dir}" -name "${case_name}*.tgz" | sort --reverse --version-sort --field-separator="-" | head -n1)

    if [[ -z ${case_tgz} ]]; then
        err_exit "failed to find case tgz for dependent case: ${case_name}"
    fi

    echo "${case_tgz}"
}

# returns name of inventory containing setup code, given a CASE name
# this is used during the install of catalog of dependent CASE
dependent_inventory_item() {
    local case_name=$1
    case $case_name in
    ibm-cp-common-services)
        echo "ibmCommonServiceOperatorSetup"
        return 0
        ;;
    *)
        echo "unknown case: $case_name"
        return 1
        ;;
    esac
}


# overriding dynamic args thats passed with --args
parse_custom_dynamic_args() {
  key=$1
  val=$2
  case $key in
  --foo)
    echo "$val"
    ;;
  --bar)
    echo "do something"
    ;;
  esac
}


# ----- INSTALL ACTIONS -----

# Installs the catalog source and operator group of any dependencies
install_dependent_catalogs() {
  echo "-------------Installing dependent catalogs-------------"

  local dep_case=""

  for dep in "${case_dependencies[@]}"; do
    local dep_case="$(dependent_case_tgz "${dep}" "${inputcasedir}")"

    echo "-------------Installing dependent catalog source: ${dep_case}-------------"

    validate_file_exists "${dep_case}"
    local inventory=""
    inventory=$(dependent_inventory_item "${dep}")

    local install_catalog_args="--inputDir ${inputcasedir} --recursive ${dryRun:+--dryRun }"
    if [[ -n ${registry} ]]; then
      install_catalog_args="${install_catalog_args} --registry ${registry}"
    fi

    set -x
    cloudctl case launch \
      --case "${dep_case}" \
      --namespace "${namespace}" \
      --inventory "${inventory}" \
      --action install-catalog \
      --args "${install_catalog_args}" \
      --tolerance "${tolerance_val}"
    set +x
    if [[ $? -ne 0 ]]; then
      err_exit "installing dependent catalog for '${dep_case}' failed"
    fi
  done
}

# Installs the operators (native) of any dependencies
install_dependent_operators() {
  echo "-------------Installing dependent operators-------------"

  local dep_case=""

  for dep in "${case_dependencies[@]}"; do
    local dep_case="$(dependent_case_tgz "${dep}" "${inputcasedir}")"

    echo "-------------Installing dependent operator: ${dep_case}-------------"

    validate_file_exists "${dep_case}"
    local inventory=""
    inventory=$(dependent_inventory_item "${dep}")

    local install_catalog_args="--inputDir ${inputcasedir} --recursive ${dryRun:+--dryRun }"
    if [[ -n ${registry} ]]; then
      install_catalog_args="${install_catalog_args} --registry ${registry}"
    fi

    set -x
    cloudctl case launch \
      --case "${dep_case}" \
      --namespace "${namespace}" \
      --inventory "${inventory}" \
      --action install-operator \
      --args "${install_catalog_args}" \
      --tolerance "${tolerance_val}"
    set +x
    if [[ $? -ne 0 ]]; then
      err_exit "installing dependent operator for '${dep_case}' failed"
    fi
  done
}

install_operator_group() {
      echo "check for any existing operator group in ${namespace} ..."

      if [[ $($kubernetesCLI get og -n "${namespace}" -o=go-template --template='{{len .items}}') -gt 0 ]]; then
          echo "found operator group"
          $kubernetesCLI get og -n "${namespace}" -o yaml
          return
      fi

      echo "no existing operator group found"

      echo "------------- Installing operator group for $namespace -------------"

      local opgrp_file="${casePath}/inventory/${inventory}/files/op-olm/operator_group.yaml"
      validate_file_exists "${opgrp_file}"

      sed <"${opgrp_file}" "s|REPLACE_NAMESPACE|${namespace}|g" | tee >($kubernetesCLI apply ${dryRun} -n "${namespace}" -f -) | cat

      echo "done"
}

# Installs the catalog source and operator group
install_catalog() {

  validate_install_catalog

#  install all catalogs of subcases first
#  if [[ ${recursive_action} -eq 1 ]]; then
#    install_dependent_catalogs
#  fi

  echo "-------------Installing catalog source-------------"

  local catsrc_file="${casePath}/inventory/${inventory}/files/op-olm/catalog_source.yaml"

  # Verfy expected yaml files for install exit
  validate_file_exists "${catsrc_file}"

  # Apply yaml files manipulate variable input as required
  if [[ -z $registry ]]; then
    # If an additional arg named registry is NOT passed in, then just apply
    tee >($kubernetesCLI apply ${dryRun} -f -) <"${catsrc_file}"
  else
    # If an additional arg named registry is passed in, then adjust the name of the image and apply
    local catsrc_image_orig=$(grep "image:" "${catsrc_file}" | awk '{print$2}')

    # replace original registry with local registry
    local catsrc_image_mod="${registry}/$(echo "${catsrc_image_orig}" | sed -e "s/[^/]*\///")"

    # apply catalog source
    sed -e "s|${catsrc_image_orig}|${catsrc_image_mod}|g" "${catsrc_file}" | tee >($kubernetesCLI apply ${dryRun} -f -) | cat
  fi

  echo "done"

}

# Install utilizing default OLM method
install_operator() {
  # Verfiy arguments are valid
  validate_install_args

  # install all operators of subcases first
#  if [[ ${recursive_action} -eq 1 ]]; then
#      install_dependent_operators
#  fi

  install_operator_group

  echo "-------------Installing via OLM-------------"

  local subscription_file="${casePath}/inventory/${inventory}/files/op-olm/subscription.yaml"
  validate_file_exists "${subscription_file}"

  # check if catalog source is installed
  echo "checking if catalog source exists ..."
  if ! $kubernetesCLI get catsrc "${caseCatalogName}" -n "${catalogNamespace}"; then
    err_exit "expected catalog source '${caseCatalogName}' expected to be installed namespace '${catalogNamespace}'"
  fi

  # create subscription
  # fix namespace and channel before creating subscription
  sed -e "s|REPLACE_NAMESPACE|${namespace}|g" "${subscription_file}" | sed "s|REPLACE_CHANNEL_NAME|$channelName|g" | tee >($kubernetesCLI apply ${dryRun} -n "${namespace}" -f -) | cat
}

# Install utilizing default CLI method
install_operator_native() {
  # Verfiy arguments are valid
  validate_install_args

#  # install all catalogs of subcases first
#  if [[ ${recursive_action} -eq 1 ]]; then
#    install_dependent_catalogs
#  fi
#
#  # install all operators of subcases first
#  if [[ ${recursive_action} -eq 1 ]]; then
#    install_dependent_operators
#  fi
  # Proceed with install
  echo "-------------Installing native -------------"

  # Verify expected yaml files for install exist
  local op_cli_files="${casePath}/inventory/${inventory}/files/op-cli"
  $kubernetesCLI apply ${dryRun} -n "${namespace}" -f "${op_cli_files}"
}

# install operand custom resources
apply_custom_resources() {
    echo "-------------Applying custom resources-------------"
    local cr="${casePath}"/inventory/"${inventory}"/files/config/samples/audit_v1beta1_auditwebhook.yaml

    validate_file_exists "$cr"

    sed -e "s|systemStatus.*|systemStatus: ${cr_system_status}|g" -e "s/accept: false/accept: true/g" "${cr}" | tee >($kubernetesCLI apply ${dryRun} -n "${namespace}" -f -) | cat
}

# ----- UNINSTALL ACTIONS -----

uninstall_dependent_catalogs() {
  echo "-------------Uninstalling dependent catalog sources-------------"

#  local dep_case=""
#  for dep in "${case_dependencies[@]}"; do
#    local dep_case="$(dependent_case_tgz "${dep}" "${inputcasedir}")"
#
#    echo "-------------Uninstalling dependent catalog source: ${dep_case}-------------"
#
#    validate_file_exists "${dep_case}"
#    local inventory=""
#    inventory=$(dependent_inventory_item "${dep}")
#
#    set -x
#    cloudctl case launch \
#      --case "${dep_case}" \
#      --namespace "${namespace}" \
#      --inventory "${inventory}" \
#      --action uninstall-catalog \
#      --args "--inputDir ${inputcasedir} --recursive ${dryRun:+--dryRun }" \
#      --tolerance "${tolerance_val}"
#    set +x
#    if [[ $? -ne 0 ]]; then
#      err_exit "uninstalling dependent catalog for '${dep_case}' failed"
#    fi
#  done
}

uninstall_dependent_operators() {
  echo "no dependent operators"
}

# deletes the catalog source and operator group
uninstall_catalog() {
  echo "-------------Uninstalling catalog source-------------"
#  validate_install_catalog "uninstall"
#
#  # uninstall all catalogs of subcases first
#  #if [[ ${recursive_action} -eq 1 ]]; then
#  #  uninstall_dependent_catalogs
#  #fi
#
#  local catsrc_file="${casePath}"/inventory/"${inventory}"/files/op-olm/catalog_source.yaml
#
#  echo "-------------Uninstalling catalog source-------------"
#  $kubernetesCLI delete -f "${catsrc_file}" --ignore-not-found=true ${dryRun}
}

## Uninstall operator installed via OLM
uninstall_operator() {
  echo "-------------Uninstalling operator-------------"
  # Find installed CSV
  csvName=$($kubernetesCLI get subscription "${caseName}"-subscription -o go-template --template '{{.status.installedCSV}}' -n "${namespace}" --ignore-not-found=true)
  # Remove the subscription
  $kubernetesCLI delete subscription "${caseName}-subscription" -n "${namespace}" --ignore-not-found=true ${dryRun}
  # Remove the CSV which was generated by the subscription but does not get garbage collected
  [[ -n "${csvName}" ]] && { $kubernetesCLI delete clusterserviceversion "${csvName}" -n "${namespace}" --ignore-not-found=true ${dryRun}; }

  # don't remove operator group, some other may have a dependency
  $kubernetesCLI delete OperatorGroup "${caseName}-group" -n "${namespace}" --ignore-not-found=true

  # delete crds
  for crdYaml in "${casePath}"/inventory/"${inventory}"/files/op-cli/*.yaml; do
    $kubernetesCLI delete -f "${crdYaml}" --ignore-not-found=true ${dryRun}
  done
  # Delete catalog source
  $kubernetesCLI delete CatalogSource "${caseCatalogName}" -n "${catalogNamespace}" --ignore-not-found=true ${dryRun}

  $kubernetesCLI delete -n "${namespace}" serviceaccount cp4d-audit-webhook-operator-controller-manager --ignore-not-found=true ${dryRun}
}

# Uninstall operator installed via CLI
uninstall_operator_native() {
  # Verfiy arguments are valid
  validate_install_args

  # Proceed with install
  echo "-------------Uninstalling native -------------"

  delete_custom_resources

  # Verify expected yaml files for install exist
  local op_cli_files="${casePath}/inventory/${inventory}/files/op-cli"
  $kubernetesCLI delete ${dryRun} -n "${namespace}" -f "${op_cli_files}"
}

delete_custom_resources() {
    echo "---------Deleting Custom Resources---------"
    local cr="${casePath}"/inventory/"${inventory}"/files/config/samples/audit_v1beta1_auditwebhook.yaml
    [[ ! -f ${cr} ]] && { err_exit "Missing required ${cr}, exiting deployment."; }
    $kubernetesCLI delete -n "${namespace}" -f "${cr}" ${dryRun}
}

install() {
  install_operator
}

uninstall() {
  uninstall_operator
}