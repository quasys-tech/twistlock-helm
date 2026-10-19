{{/*
=============================================================================
 Platform yardımcıları — OpenShift (Route) / vanilla Kubernetes (Gateway API)
=============================================================================
*/}}

{{/*
TLSRoute apiVersion
  1) gatewayApi.tlsRouteApiVersion verildiyse o ("v1alpha2" gibi kısa yazım da olur)
  2) Cluster'ın sunduğu en yeni sürüm: v1 > v1alpha3 > v1alpha2
     (Gateway API v1.5+ standard → v1; v1.4 experimental → v1alpha3/v1alpha2)
  3) Cluster'a sorulamıyorsa (helm template, CRD henüz yok) → v1
*/}}
{{- define "twistlock-console.tlsRouteApiVersion" -}}
{{- $override := .Values.gatewayApi.tlsRouteApiVersion | default "" | trim -}}
{{- if $override -}}
  {{- if contains "/" $override -}}
    {{- $override -}}
  {{- else -}}
    {{- printf "gateway.networking.k8s.io/%s" $override -}}
  {{- end -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/TLSRoute" -}}
gateway.networking.k8s.io/v1
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha3/TLSRoute" -}}
gateway.networking.k8s.io/v1alpha3
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/TLSRoute" -}}
gateway.networking.k8s.io/v1alpha2
{{- else -}}
gateway.networking.k8s.io/v1
{{- end -}}
{{- end -}}

{{/*
TLSRoute parentRefs
  gateway.create: true  → chart'ın Gateway'i + ilgili listener (sectionName)
  gateway.create: false → gatewayApi.parentRefs (mevcut/paylaşımlı Gateway)
Kullanım: include "twistlock-console.gatewayApi.parentRefs" (dict "root" $ "section" "console")
*/}}
{{- define "twistlock-console.gatewayApi.parentRefs" -}}
{{- $gw := .root.Values.gatewayApi.gateway -}}
{{- if $gw.create -}}
- name: {{ $gw.name }}
  sectionName: {{ .section }}
{{- else -}}
{{- toYaml .root.Values.gatewayApi.parentRefs }}
{{- end -}}
{{- end -}}

{{/*
Gateway API modunda değer kontrolleri — eksik/çakışan ayarda kurulumdan önce
anlaşılır bir hata ile durur.
*/}}
{{- define "twistlock-console.gatewayApi.validate" -}}
{{- $gw := .Values.gatewayApi.gateway -}}
{{- if not .Values.MANAGEMENT_PORT_HTTPS -}}
  {{- fail "\n[twistlock-console] Gateway API (TLS passthrough) için MANAGEMENT_PORT_HTTPS dolu olmalı (varsayılan \"8083\")." -}}
{{- end -}}
{{- if not .Values.routename -}}
  {{- fail "\n[twistlock-console] openshift=false (Gateway API): 'routename' zorunlu.\nTLS passthrough trafiği SNI hostname ile yönlendirir; ör. --set routename=twistlock.example.com" -}}
{{- end -}}
{{- if .Values.defenderRouteEnabled -}}
  {{- if not .Values.defenderroutename -}}
    {{- fail "\n[twistlock-console] openshift=false (Gateway API): 'defenderroutename' zorunlu\n(ya da Defender'ı dışarı açmamak için defenderRouteEnabled=false)." -}}
  {{- end -}}
  {{- if eq (lower .Values.routename) (lower .Values.defenderroutename) -}}
    {{- if not $gw.create -}}
      {{- fail "\n[twistlock-console] Mevcut Gateway (parentRefs) kullanılırken routename ve defenderroutename farklı olmalı;\naynı SNI hostname iki ayrı servise yönlendirilemez." -}}
    {{- else if eq (int $gw.consolePort) (int $gw.defenderPort) -}}
      {{- fail "\n[twistlock-console] routename ve defenderroutename aynı; bu durumda gatewayApi.gateway.consolePort ve defenderPort farklı olmalı\n(ör. defenderPort: 8084) ya da farklı hostname'ler kullanılmalı." -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- if $gw.create -}}
  {{- if not $gw.gatewayClassName -}}
    {{- fail "\n[twistlock-console] gatewayApi.gateway.gatewayClassName zorunlu (kubectl get gatewayclass).\nMevcut bir Gateway kullanacaksanız: gatewayApi.gateway.create=false + gatewayApi.parentRefs" -}}
  {{- end -}}
{{- else if not .Values.gatewayApi.parentRefs -}}
  {{- fail "\n[twistlock-console] gatewayApi.gateway.create=false iken gatewayApi.parentRefs (mevcut Gateway) zorunlu." -}}
{{- end -}}
{{- end -}}
