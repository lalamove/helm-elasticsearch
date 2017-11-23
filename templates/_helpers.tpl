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
{{- if .plugins }}
- name: es-plugin-install
  image: "{{ .image.repository }}:{{ .image.tag }}"
  imagePullPolicy: {{ .image.pullPolicy }}
  securityContext:
    capabilities:
      add:
        - IPC_LOCK
        - SYS_RESOURCE
  command:
    - "sh"
    - "-c"
    - "{{- range .plugins }}elasticsearch-plugin install {{ . }};{{- end }} true"
  env:
  - name: NODE_NAME
    value: es-plugin-install
  volumeMounts:
  - mountPath: /usr/share/elasticsearch/config/
    name: configdir
  - mountPath: /usr/share/elasticsearch/plugins/
    name: plugindir
  - mountPath: /usr/share/elasticsearch/config/elasticsearch.yml
    name: config
    subPath: elasticsearch.yml
volumes:
  - name: configdir
    emptyDir: {}
  - name: plugindir
    emptyDir: {}
{{- end }}
{{- end -}}
