{{/*
Expand the name of the chart.
*/}}
{{- define "bugsink.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "bugsink.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "bugsink.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "bugsink.labels" -}}
helm.sh/chart: {{ include "bugsink.chart" . }}
{{ include "bugsink.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "bugsink.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bugsink.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "bugsink.serviceAccount.name" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "bugsink.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "bugsink.image" -}}
{{- $appVersion := .Chart.AppVersion }}
{{- with .Values.image }}
{{- printf "%s/%s:%s" .registry .repository (.tag | default $appVersion) }}
{{- end }}
{{- end }}

{{- define "bugsink.envConfigMap.create" -}}
{{- or .Values.baseUrl .Values.timezone .Values.smtp.enabled }}
{{- end }}

{{- define "bugsink.envConfigMap.name" -}}
{{- printf "%s-envs" (include "bugsink.fullname" .) }}
{{- end }}

{{- define "bugsink.extraEnvConfigMap.create" -}}
{{- ternary false true (not .Values.extraEnv.configs) }}
{{- end }}

{{- define "bugsink.extraEnvConfigMap.name" -}}
{{- printf "%s-extra-envs" (include "bugsink.fullname" .) }}
{{- end }}

{{- define "bugsink.envSecret.create" }}
{{- ternary true false (or (not .Values.secretKey.existingSecret) (and .Values.smtp.enabled (not .Values.smtp.existingSecret)) (not .Values.admin.existingSecret) .Values.postgresql.enabled) }}
{{- end }}

{{- define "bugsink.envSecret.name" -}}
{{- printf "%s-envs" (include "bugsink.fullname" .) }}
{{- end }}

{{- define "bugsink.envSecret" -}}
{{- lookup "v1" "Secret" .Release.Namespace (include "bugsink.envSecret.name" .) }}
{{- end }}

{{- define "bugsink.extraEnvSecret.create" -}}
{{- ternary false true (not .Values.extraEnv.secrets) }}
{{- end }}

{{- define "bugsink.extraEnvSecret.name" -}}
{{- printf "%s-extra-envs" (include "bugsink.fullname" .) }}
{{- end }}

{{- define "bugsink.postgresql.fullname" -}}
{{- printf "%s-postgresql" (include "bugsink.fullname" .) }}
{{- end }}

{{- define "bugsink.postgresql.secret.name" -}}
{{- printf "%s-postgresql" (include "bugsink.fullname" .) }}
{{- end }}

{{- define "bugsink.postgresql.username" -}}
{{- .Values.postgresql.auth.username }}
{{- end }}

{{- define "bugsink.postgresql.password" -}}
{{- $postgresqlSecretName := include "bugsink.postgresql.secret.name" . }}
{{- $postgresqlSecret := lookup "v1" "Secret" .Release.Namespace $postgresqlSecretName }}
{{- if $postgresqlSecret }}
{{- index $postgresqlSecret.data "password" | b64dec }}
{{- end }}
{{- end }}

{{- define "bugsink.postgresql.host" -}}
{{- printf "%s-postgresql" (include "bugsink.fullname" .) }}
{{- end }}

{{- define "bugsink.postgresql.port" -}}
{{- 5432 }}
{{- end }}

{{- define "bugsink.postgresql.database" -}}
{{- .Values.postgresql.auth.database }}
{{- end }}

{{- define "bugsink.postgresql.url" -}}
{{- $username := include "bugsink.postgresql.username" . }}
{{- $password := include "bugsink.postgresql.password" . }}
{{- $host := include "bugsink.postgresql.host" . }}
{{- $port := include "bugsink.postgresql.port" . }}
{{- $database := include "bugsink.postgresql.database" . }}
{{- printf "postgresql://%s:%s@%s:%s/%s" $username $password $host $port $database }}
{{- end }}

{{- define "bugsink.secretKey" -}}
{{- if not .Values.secretKey.existingSecret }}
    {{- if .Values.secretKey.value }}
        {{- .Values.secretKey.value }}
    {{- else }}
        {{- $envSecretName := include "bugsink.envSecret.name" . }}
        {{- $envSecret := lookup "v1" "Secret" .Release.Namespace $envSecretName }}
        {{- if $envSecret }}
            {{- index $envSecret.data "SECRET_KEY" | b64dec }}
        {{- else }}
            {{- randAlphaNum 64 }}
        {{- end }}
    {{- end }}
{{- end }}
{{- end }}

{{- define "bugsink.admin.auth" -}}
{{- if .Values.admin.auth }}
    {{- .Values.admin.auth }}
{{- else }}
    {{- $envSecretName := include "bugsink.envSecret.name" . }}
    {{- $envSecret := lookup "v1" "Secret" .Release.Namespace $envSecretName }}
    {{- if and $envSecret (hasKey $envSecret.data "CREATE_SUPERUSER") }}
        {{- index $envSecret.data "CREATE_SUPERUSER" | b64dec }}
    {{- else }}
        {{- printf "admin:%s" (randAlphaNum 16) }}
    {{- end }}
{{- end }}
{{- end }}
