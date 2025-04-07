.PHONY: k9s-kustomizations
k9s-kustomizations:
	k9s --headless --all-namespaces --command kustomizations

.PHONY: k9s-helmreleases
k9s-helmreleases:
	k9s --headless --all-namespaces --command helmreleases
