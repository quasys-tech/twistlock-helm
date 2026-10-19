# Twistlock Console Helm repository for GitHub Pages

This project contains the supplied chart, an initial packaged release and a Helm index.

## Publish

1. Copy this repository content to the root of your public GitHub repository.
2. Commit and push `charts/`, `docs/`, `publish.sh`, `README.md` and `.gitignore` to `main`.
3. GitHub repository Settings > Pages > Deploy from a branch > main > /docs > Save.
4. Your Helm URL is `https://YOUR_USER.github.io/YOUR_REPOSITORY/`.

```bash
helm repo add twistlock https://YOUR_USER.github.io/YOUR_REPOSITORY/
helm repo update
helm search repo twistlock/twistlock-console --versions
```

The `docs/index.yaml` uses relative chart package URLs, so no username replacement is necessary inside the index.

## Chart verification

```bash
helm lint charts/twistlock-console
helm template test charts/twistlock-console --namespace twistlock \
  --set consoleImageName=registry.example.com/twistlock-console:34.05.168 \
  > rendered.yaml
```

Set the actual authorized console image, appropriate StorageClass, ingress hostname and any pull secrets before installation. Installation may create cluster wide SecurityContextConstraints and should be reviewed before production use.

## Update

Edit `charts/twistlock-console/Chart.yaml` version and chart configuration, then:

```bash
./publish.sh
git add charts docs
git commit -m 'Publish updated Twistlock Console chart'
git push
```

Existing tgz files remain in docs to preserve previous versions.

## Notes from the supplied source

* The source chart version is 34.05.168. This version is not an independent verification of the installed Console image.
* The default `consoleImageName` is `<IMAGE_NAME_GIRILECEK>` and must be set before installation.
* `openshift: true` enables OpenShift Route and SCC. Use compatible Gateway API CRDs and configure hostnames when `openshift: false`.
* The default StorageClass is `ocs-storagecluster-ceph-rbd`, which may not exist in a different cluster.
* The source archive included a hidden `.backup` chart package and macOS metadata; these were excluded from the public output.
