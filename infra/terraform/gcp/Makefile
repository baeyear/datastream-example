DIR=""

init:
	terraform -chdir=${DIR} init
plan:
	terraform -chdir=${DIR} fmt
	terraform -chdir=${DIR} validate
	tflint --chdir=${DIR}
	terraform -chdir=${DIR} plan
apply:
	terraform -chdir=${DIR} fmt
	terraform -chdir=${DIR} validate
	tflint --chdir=${DIR}
	terraform -chdir=${DIR} apply