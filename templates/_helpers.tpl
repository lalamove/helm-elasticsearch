{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 53 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 53 chars (63 - len("-discovery")) because some Kubernetes name fields are limited to 63 (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 53 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for Curactor cron job.
*/}}
{{- define "curator.cronJob.apiVersion" -}}
{{- if ge .Capabilities.KubeVersion.Minor "8" -}}
"batch/v1beta1"
{{- else -}}
"batch/v2alpha1"
{{- end -}}
{{- end -}}
{{/*
init container template
*/}}
{{- define "init-containers" -}}
- name: init-sysctl
  image: busybox
  imagePullPolicy: IfNotPresent
  command: ["sysctl", "-w", "vm.max_map_count=262144"]
  securityContext:
    privileged: true
{{- if $.Values.tls.enable }}
- name: generate-tls-pair
  image: "{{ .Values.tls.image }}:{{ .Values.tls.imageTag }}"
  imagePullPolicy: {{ .Values.tls.imagePullPolicy }}
  env:
  - name: NAMESPACE
    valueFrom:
      fieldRef:
        fieldPath: metadata.namespace
  - name: POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: SUBDOMAIN
    value: {{ template "fullname" . }}
  - name: POD_IP
    valueFrom:
      fieldRef:
        fieldPath: status.podIP
  args:
  - "-namespace=$(NAMESPACE)"
  - "-pod-ip=$(POD_IP)"
  - "-pod-name=$(POD_NAME)"
  - "-hostname=$(POD_NAME)"
  - "-subdomain=$(SUBDOMAIN)"
  - "-headless-name-as-cn"
  - "-service-names={{ template "fullname" . }}-discovery,{{ template "fullname" . }}"
  - "-cert-dir=/tls/"
  - "-pkcs8"
  - "-labels=component={{ template "fullname" . }}"
  volumeMounts:
    - name: tls
      mountPath: /tls
- name: copy-ca
  image: busybox
  imagePullPolicy: IfNotPresent
  command: ["cp", "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt", "/tls/ca.crt"]
  volumeMounts:
    - name: tls
      mountPath: /tls
{{- end }}
{{- if .Values.common.plugins }}
- name: es-plugin-install
  image: "{{ .Values.common.image.repository }}:{{ .Values.common.image.tag }}"
  imagePullPolicy: {{ .Values.common.image.pullPolicy }}
  securityContext:
    capabilities:
      add:
        - IPC_LOCK
        - SYS_RESOURCE
  command:
    - "sh"
    - "-c"
    - "{{ if .Values.searchguard.enable }}elasticsearch-plugin install {{ .Values.searchguard.plugin }};{{ end }}{{- range .Values.common.plugins }}elasticsearch-plugin install {{ . }};{{- end }} true"
  env:
  - name: NODE_NAME
    value: es-plugin-install
  volumeMounts:
  - mountPath: /storage/
    name: storage
  - mountPath: /usr/share/elasticsearch/config/
    name: configdir
  - mountPath: /usr/share/elasticsearch/plugins/
    name: plugindir
  - mountPath: /usr/share/elasticsearch/config/elasticsearch.yml
    name: config
    subPath: elasticsearch.yml
  - mountPath: /usr/share/elasticsearch/config/tls/
    name: tls
{{- end }}
- name: permissions
  image: busybox
  command: ["sh", "-c", "chmod 400 /usr/share/elasticsearch/config/tls/*; chown -R 1000: /usr/share/elasticsearch/ /storage/; true"]
  volumeMounts:
  - mountPath: /storage
    name: storage
{{- end -}}
