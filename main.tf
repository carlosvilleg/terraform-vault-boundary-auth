
resource "vault_identity_entity" "boundary" {
  name      = "hcp boundary"
}

resource "vault_policy" "boundary-controller" {
	name      = "boundary-controller"
	policy    = file("${path.module}/boundary-controller.hcl")
}

resource "vault_policy" "secrets" {
	name      = "boundary-access"
	policy    = file("${path.module}/boundary-access.hcl")
}

resource "vault_token" "boundary" {
  role_name = vault_token_auth_backend_role.boundary.role_name
  policies = [vault_policy.boundary-controller.name, vault_policy.secrets.name]
  no_parent = true
  renewable = true
  period = "24h"
}

resource "vault_token_auth_backend_role" "boundary" {
  role_name              = "credential-store"
  allowed_policies = [vault_policy.boundary-controller.name, vault_policy.secrets.name]
  disallowed_policies    = ["default"]
  allowed_entity_aliases = [vault_identity_entity.boundary.name]
  orphan                 = true
  token_period           = "86400"
  renewable              = true
}

output "token" {
	value     = vault_token.boundary.client_token
	sensitive = true
}

