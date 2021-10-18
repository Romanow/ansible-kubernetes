# Terraform DigitalOcean Managed K8S Cluster

```shell
echo 'do_token = <do_token>' > vars.auto.tfvars
terraform init
terraform apply
```

DigitalOcean автоматически создает LoadBalancer для сущности k8s LoadBalancer. Для того, что использовать уже
существующий LB, нужно в helm скриптах явно прописать id нужно LB.

```shell
helm install nginx-ingress nginx-stable/nginx-ingress \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/do-loadbalancer-name=loadbalancer" \
    --set controller.service.annotations."kubernetes\.digitalocean\.com/load-balancer-id=<loadbalancer-id>"
```