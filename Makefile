argocd_server = $(shell kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
argocd_password = $(shell kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d)

docker-build:
	git pull
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 565122144984.dkr.ecr.us-east-1.amazonaws.com
	docker build -t  565122144984.dkr.ecr.us-east-1.amazonaws.com/portfolio-service:$(image_tag) .
	docker push 565122144984.dkr.ecr.us-east-1.amazonaws.com/portfolio-service:$(image_tag)

eks-deploy:
	git pull
	aws eks update-kubeconfig --name wmp-dev
	helm upgrade -i portfolio-service helm -f helm/values/portfolio-service.yaml --set image_tag=$(image_tag)

argocd-deploy:
	git pull
	aws eks update-kubeconfig --name wmp-dev

	argocd login $(argocd_server) \
		--insecure \
		--username admin \
		--password $(argocd_password)

	argocd app create portfolio-service \
		--repo https://github.com/Wealth-Management-Project-v1/helm-v1.git \
		--path . \
		--revision main \
		--dest-server https://kubernetes.default.svc \
		--dest-namespace default \
		--sync-policy auto \
		--upsert \
		--values values/portfolio-service.yaml \
		--helm-set-string image_tag=$(image_tag)
