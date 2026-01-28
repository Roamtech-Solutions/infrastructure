{{- range $user := .users }}

CREATE USER IF NOT EXISTS '{{ user.name }}'@'{{ user.host }}'
IDENTIFIED BY '{{ user.password }}';

{{- end }}

FLUSH PRIVILEGES;

