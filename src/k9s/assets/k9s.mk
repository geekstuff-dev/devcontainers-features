.PHONY: flux-watch
flux-watch: SLEEP ?= 3
flux-watch:
	watch -n${SLEEP} flux get kustomizations --all-namespaces

.PHONY: flux-watch-original
flux-watch-original:
	flux get kustomizations --watch --timeout 15m0s

.PHONY: flux-check
flux-check:
	flux check --pre

.PHONY: flux-build
flux-build:
	flux build kustomization flux-system --path ${FLUX_PATH}

.PHONY: flux-diff
flux-diff:
	flux diff kustomization flux-system --path ${FLUX_PATH}

.PHONY: flux-events
flux-events:
	flux events

.PHONY: flux-stats
flux-stats:
	flux stats

.PHONY: flux-tree
flux-tree:
	flux tree kustomization flux-system --compact

.PHONY: .ensure-flux-graph
.ensure-flux-graph:
	@command -v flux-graph 1>/dev/null 2>/dev/null || { \
		echo "> install flux-graph"; \
		TMP=$$(mktemp -d); \
		curl -fsSL -o $${TMP}/flux-graph.tar.gz "https://github.com/rishinair11/flux-graph/releases/download/0.4.0/flux-graph_0.4.0_linux_amd64.tar.gz"; \
		tar -zx -C $${TMP} -f $${TMP}/flux-graph.tar.gz; \
		sudo install -t /usr/local/bin $${TMP}/flux-graph; \
		rm -rf $${TMP}; \
	}

.PHONY: flux-graph
flux-graph: .ensure-flux-graph
flux-graph:
	flux tree kustomization flux-system --compact -o yaml | flux-graph --no-serve -o .flux-graph.svg

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