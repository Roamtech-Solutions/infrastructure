%{ for user in users ~}

CREATE USER IF NOT EXISTS '${user.name}'@'%'
IDENTIFIED BY '${user.password}';

%{ endfor ~}

FLUSH PRIVILEGES;

