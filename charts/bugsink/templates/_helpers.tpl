{{- define "bugsink.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

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

{{- define "bugsink.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "bugsink.labels" -}}
helm.sh/chart: {{ include "bugsink.chart" . }}
{{ include "bugsink.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "bugsink.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bugsink.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "bugsink.serviceAccount.name" -}}
  {{- if .Values.serviceAccount.create }}
    {{- default (include "bugsink.fullname" .) .Values.serviceAccount.name }}
  {{- else }}
    {{- default "default" .Values.serviceAccount.name }}
  {{- end }}
{{- end }}

{{- define "bugsink.secret.create" }}
{{- ternary true false (or (not .Values.secretKey.existingSecret) (and .Values.smtp.enabled (not .Values.smtp.existingSecret)) (not .Values.admin.existingSecret) (and .Values.externalDatabase.url (not .Values.externalDatabase.existingSecret)) (not (not .Values.extraEnv.secrets))) }}
{{- end }}

{{- define "bugsink.env" -}}
env:
  {{- if .Values.secretKey.existingSecret }}
  - name: SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: {{ .Values.secretKey.existingSecret }}
        key: {{ .Values.secretKey.existingSecretKey }}
  {{- end }}
  {{- if .Values.admin.existingSecret }}
  - name: CREATE_SUPERUSER
    valueFrom:
      secretKeyRef:
        name: {{ .Values.admin.existingSecret }}
        key: {{ .Values.admin.existingSecretKey }}
  {{- end }}
  {{- if and .Values.smtp.enabled .Values.smtp.existingSecret }}
  - name: EMAIL_HOST_USER
    valueFrom:
      secretKeyRef:
        name: {{ .Values.smtp.existingSecret }}
        key: {{ .Values.smtp.existingSecretUsernameKey }}
  - name: EMAIL_HOST_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ .Values.smtp.existingSecret }}
        key: {{ .Values.smtp.existingSecretPasswordKey }}
  {{- end }}
  {{- if .Values.externalDatabase.existingSecret }}
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: {{ .Values.externalDatabase.existingSecret }}
        key: {{ .Values.externalDatabase.existingSecretKey }}
  {{- end }}
  {{- if .Values.postgresql.enabled }}
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: {{ printf "%s-postgresql-svcbind-custom-user" (include "bugsink.fullname" .) }}
        key: uri
  {{- end }}
envFrom:
  - configMapRef:
      name: {{ include "bugsink.fullname" . }}
  {{- if (include "bugsink.secret.create" .) }}
  - secretRef:
      name: {{ include "bugsink.fullname" . }}
  {{- end }}
  {{- range .Values.extraEnv.configMapRefs }}
  - configMapRef:
      name: {{ .name }}
  {{- end }}
  {{- range .Values.extraEnv.secretRefs }}
  - secretRef:
      name: {{ .name }}
  {{- end }}
{{- end }}

{{- define "bugsink.secretKey" -}}
  {{- if .Values.secretKey.value }}
    {{- .Values.secretKey.value }}
  {{- else }}
    {{- $secret := lookup "v1" "Secret" .Release.Namespace (include "bugsink.fullname" .) }}
    {{- if $secret }}
      {{- index $secret.data "SECRET_KEY" | b64dec }}
    {{- else }}
      {{- randAlphaNum 64 }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "bugsink.admin.auth" -}}
  {{- if .Values.admin.auth }}
    {{- .Values.admin.auth }}
  {{- else }}
    {{- $secret := lookup "v1" "Secret" .Release.Namespace (include "bugsink.fullname" .) }}
    {{- if $secret }}
      {{- index $secret.data "CREATE_SUPERUSER" | b64dec }}
    {{- else }}
      {{- printf "admin:%s" (randAlphaNum 16) }}
    {{- end }}
  {{- end }}
{{- end }}
