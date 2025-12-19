output "argocd_namespace" {
  value = var.namespace
}

output "argocd_server_service_name" {
  value = "argocd-server"
}

output "application_name" {
  value = var.app_name
}

output "argocd_username" {
  value       = "admin"
  description = "ArgoCD admin username"
}

output "argocd_password" {
  value       = try(nonsensitive(base64decode(data.kubernetes_secret.argocd_admin.data["password"])), null)
  sensitive   = false
  description = "ArgoCD admin password"
}
