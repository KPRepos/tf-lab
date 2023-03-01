resource "kubernetes_cluster_role" "cluster-admin" {
  metadata {
    name = "clusteradmin-custom"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "cluster-admin-role-binding" {
  metadata {
    name = "clusteradmin-custom"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "clusteradmin-custom"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "lab-eks-pod-cluster-admin"
    namespace = "kube-system"
  }
  subject {
    kind      = "Group"
    name      = "system:serviceaccounts"
    api_group = "rbac.authorization.k8s.io"
  }
}
