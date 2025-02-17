#
# This is a redacted version of the upstream values.yaml file found here:
# https://github.com/helm/charts/blob/dea84cfd139f0e7bd7721abfa53e4853c1379c0a/stable/oauth2-proxy/values.yaml
#
replicaCount: 2

config:
  clientID: "${client_id}"
  clientSecret: "${client_secret}"
  cookieSecret: "${cookie_secret}"
  # Custom configuration file: oauth2_proxy.cfg
  # configFile: |-
  #   pass_basic_auth = false
  #   pass_access_token = true
  configFile: ""

%{ if eks ~}
image:
  imagePullSecrets:
  - name: "dockerhub-credentials"
%{ endif ~}
extraArgs:
  provider: oidc
  oidc-issuer-url: ${issuer_url}
  email-domain: "*"
  upstream: "${upstream}"
  http-address: "0.0.0.0:4180"
  skip-auth-regex: "${exclude_paths}"
  cookie-expire: "7h"
  skip-provider-button: true
  pass-basic-auth: "false"
  pass-host-header: "false"

ingress:
  enabled: true
  annotations: {
    external-dns.alpha.kubernetes.io/aws-weight: "100",
    external-dns.alpha.kubernetes.io/set-identifier: "dns-${clusterName}"
  }
  path: /
%{ if ingress_redirect ~}
  hosts:
    - "${hostname}"
    - "${live_domain_hostname}"
  tls:
    - hosts:
      - "${hostname}"
      - "${live_domain_hostname}"
%{ else ~}
  hosts:
    - "${hostname}"
  tls:
    - hosts:
      - "${hostname}"
%{ endif ~}
serviceAccount:
  enabled: false
