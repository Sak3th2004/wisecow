# Wisecow



Web server that prints a fortune inside a cow. Port 4499.



\## Docker



docker build -t wisecow:latest .

docker run --rm -p 4499:4499 wisecow:latest



Open http://127.0.0.1:4499



Build before applying the Kubernetes files. The Deployment uses the same image name, wisecow:latest.



\## Kubernetes



The cluster is Kubernetes in Docker Desktop. The context name is docker-desktop.



kubectl config use-context docker-desktop

kubectl get nodes



Ingress is installed once and is not stored in this repo.



kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/cloud/deploy.yaml

kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller



bash scripts/generate-tls.sh



kubectl apply -f k8s/

kubectl get pods



Add this line to the hosts file:



127.0.0.1 wisecow.local



On Windows that file is C:\\Windows\\System32\\drivers\\etc\\hosts



curl -k https://wisecow.local



The certificate is self-signed, so the browser warning is expected.



\## GitHub



A push to main builds the image and pushes it to ghcr.io/<github name>/wisecow.



The deploy job runs only when the repo secret KUBE\_CONFIG is set. Leave it empty. GitHub cannot reach a laptop cluster. Deploy with kubectl apply, above.



\## Scripts



Run these on Linux, or Ubuntu in WSL:



bash scripts/system-health.sh

bash scripts/app-health.sh https://wisecow.local



One run printed:



cpu=6% mem=25% disk=3% procs=48

https://wisecow.local status=200 up



Alerts fire above 80% cpu, memory, or disk, and above 400 processes. The same line is appended to health-alerts.log.

