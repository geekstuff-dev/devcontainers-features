K8_NAMESPACE ?= default
K8_KIND ?= pod

.PHONY: k9s
k9s: .k9s

.PHONY: k9s-all
k9s-all: K8_NAMESPACE = all
k9s-all: .k9s

.PHONY: k9s-nodes
k9s-nodes: K8_NAMESPACE = all
k9s-nodes: K8_KIND = node
k9s-nodes: .k9s

.PHONY: .k9s
.k9s: NAMESPACE_ARG = $(shell \
	test "${K8_NAMESPACE}" = "all" \
		&& echo "--all-namespaces" \
		|| echo "-n ${K8_NAMESPACE}" \
	)
.k9s:
	k9s --headless ${NAMESPACE_ARG} -c ${K8_KIND}
