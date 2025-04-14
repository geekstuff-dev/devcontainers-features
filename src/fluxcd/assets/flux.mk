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

.PHONY: k9s-kustomizations
k9s-kustomizations:
	k9s --headless --all-namespaces --command kustomizations

.PHONY: k9s-helmreleases
k9s-helmreleases:
	k9s --headless --all-namespaces --command helmreleases
