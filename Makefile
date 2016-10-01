WEBPACK=./node_modules/.bin/webpack

.PHONY: all
all: build

.PHONY: build
build:
ifeq ($(OPTIMIZE), 1)
	NODE_ENV=production $(WEBPACK)
	swift build -v -c release
else
	$(WEBPACK)
	swift build -v
endif

.PHONY: run
run:
	./.build/debug/App serve

.PHONY: watch
watch:
	$(WEBPACK) --progress --colors --watch

.PHONY: run-dev-server
run-dev-server:
	webpack-dev-server --inline --progress --colors -d --host 0.0.0.0 --port 8081

.PHONY: deps
deps:
	npm install

.PHONY: docker
docker:
	docker build -t react-swift-example .

.PHONY: docker-run
docker-run:
	docker run -it --rm=true -p 8080:8080 react-swift-example $(DOCKER_COMMAND)

.PHONY: check-integration
check-integration:
	./node_modules/.bin/mocha --timeout 60000 --compilers js:babel-core/register Tests/Integration/**/*.js

.PHONY: run-webdriver
run-webdriver:
	./node_modules/.bin/phantomjs --webdriver=4444
