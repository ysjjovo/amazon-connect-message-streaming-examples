layerName=
inboundFun=
outboundfun=
region= us-east-1

baseDir=$(shell pwd)
define makeLayer
	layerDir=${baseDir}/src/layer/smsConnectDeps/nodejs;\
	cd $$layerDir;\
	npm install;\
	utilDir=node_modules/common-util;\
	mkdir -p $$utilDir;\
	cp -a index.js lib $$utilDir;
endef

define zipCode
	cd ${baseDir}/src/lambda/${1};\
	zip -qr code.zip *;\
	aws lambda update-function-code --function-name $(2) --zip-file fileb://code.zip > /dev/null;\
	rm -f code.zip
endef

deps:
	npm -g install typescript
	npm install -g aws-cdk
	cdk bootstrap aws://$(shell aws sts get-caller-identity --query "Account" --output text)/${region}
	npm install;
	$(call makeLayer)

deploy:
	export account=$(shell aws sts get-caller-identity --query "Account" --output text);\
	export region=${region};\
	cdk bootstrap aws://$$account/${region};\
	cdk deploy --app 'npx ts-node --prefer-ts-exts bin/chat-message-streaming-examples.ts'
smsConnectDeps:
	$(call makeLayer)
	cd src/layer/${layerName};\
	zip -rq nodejs.zip nodejs;\
	aws lambda publish-layer-version --layer-name ${layerName} --zip-file fileb://nodejs.zip --compatible-runtimes nodejs14.x > /dev/null;\
	rm -f nodejs.zip
vonageDeps:
	cd src/layer/vonage-callback/nodejs;\
	npm install;\
	cd ..;\
	zip -rq nodejs.zip nodejs;\
	aws lambda publish-layer-version --layer-name vonageDeps --zip-file fileb://nodejs.zip --compatible-runtimes nodejs18.x > /dev/null;\
	rm -f nodejs.zip
inboudCode:
	$(call zipCode,inboundMessageHandler,${inboundFun})
	
outboudCode:
	$(call zipCode,outboundMessageHandler,${outboundfun})