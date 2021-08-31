resource "google_compute_address" "server" {
  name         = "minecraft-ip"
  network_tier = "PREMIUM"
}

resource "google_compute_address" "dns" {
  name         = "minecraft-dns-ip"
  network_tier = "PREMIUM"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "minecraft"
  }
}

resource "kubectl_manifest" "storage_class" {
  yaml_body = <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: slow
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
  fstype: ext4
  replication-type: none
reclaimPolicy: Retain
YAML
}


resource "helm_release" "minecraft" {
  name      = "minecraft"
  namespace = kubernetes_namespace.namespace.metadata[0].name

  chart = "${path.module}/helm/minecraft-bedrock"

  set {
    name  = "minecraftServer.eula"
    value = true
  }

  set {
    name  = "minecraftServer.gameMode"
    value = "survival"
  }

  set {
    name  = "minecraftServer.difficulty"
    value = "hard"
  }

  set {
    name  = "minecraftServer.whitelist"
    value = false
  }

  set {
    name  = "persistence.storageClass"
    value = "slow"
  }

  set {
    name  = "service.ipAddress"
    value = google_compute_address.server.address
  }

  set {
    name = "minecraftServer.serverName"
    value = "Mugreros"
  }

  set {
    name = "minecraftServer.cheats"
    value = false
  }

  set {
    name = "minecraftServer.ops"
    value = "2533274863435856"
  }

  depends_on = [
    kubectl_manifest.storage_class
  ]
}

resource "helm_release" "minecraft-dns" {
  name      = "minecraftdns"
  namespace = kubernetes_namespace.namespace.metadata[0].name

  chart = "${path.module}/helm/dnsmasq"

  set {
    name  = "service.ipAddress"
    value = google_compute_address.dns.address
  }

  set {
    name  = "dnsmasq.entry1.host"
    value = "hivebedrock.network"
  }
  
  set {
    name  = "dnsmasq.entry1.ip"
    value = google_compute_address.server.address
  }

  depends_on = [
    helm_release.minecraft
  ]
}