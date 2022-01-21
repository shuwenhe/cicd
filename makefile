# 配置
service_name = user
repository = registry.cn-hangzhou.aliyuncs.com
docker_file = Dockerfile
config_path = configs/dev.yaml
tag = dev

# 镜像构建
.PHONY:docker-build
docker-build:build-linux ##@docker 构建镜像.
	docker build -t $(repository):$(tag) -f $(docker_file) .
	@echo "build success"


# 镜像构建
.PHONY:docker-push
docker-push: docker-build##@docker 推送镜像.
	docker push $(repository):$(tag)
	@echo "push success"

# 部署
.PHONY:deploy
deploy:docker-push  ##@docker 推送镜像.
	curl -X POST -v http://portainer.antdate.cn/api/webhooks/3008ef6e-d826-46c8-82ff-9e19c80cb22c
	@echo "push success"

deploy-test:
	@echo "sidsa-service 停止服务:"
	ssh root@x.140.156.102 systemctl stop sidsa-service
	scp -r config/*.yml root@x.x.156.102:/app/sidsa-service/configs/
	scp -r sidsa-service root@x.x.156.102:/app/sidsa-service/
	@echo "sidsa-service 启动服务:"
	ssh root@x.140.156.102 systemctl start sidsa-service
	@echo "sidsa-service 服务:"
	ssh root@x.140.156.102 systemctl status sidsa-service

HELP_FUN = \
	%help; \
	while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
	print "usage: make [target]\n\n"; \
	for (sort keys %help) { \
		print "${WHITE}$$_:${RESET}\n"; \
		for (@{$$help{$$_}}) { \
			$$sep = " " x (32 - length $$_->[0]); \
			print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
	}; \
	print "\n"; }
