# Terraform DigitalOcean Managed K8S Cluster

```shell
tgenv install
echo 'do_token = <do_token>' > ingress/credentials.auto.tfvars
terragrant apply
```

### Особенности реализации

DigitalOcean автоматически создает LoadBalancer для сущности k8s LoadBalancer. Нужно в helm скриптах явно прописать
конфигурацию LoadBalancer.

### Links

1. [Load Balancer Service Annotations](https://github.com/digitalocean/digitalocean-cloud-controller-manager/blob/master/docs/controllers/services/annotations.md)
1. [Istio Helm Chart](https://comocomo.github.io/istio-charts/)
1. [Istio Official Helm Chart](https://artifacthub.io/packages/helm/istio-official/istiod)