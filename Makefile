baseDir=$(shell pwd)
funDir = ${baseDir}/src/lambda
depDir = ${baseDir}/src/nodejs
define makeLayer
	cd ${depDir};\
	npm install;\
	utilDir=${depDir}/node_modules/common-util;\
	mkdir -p $$utilDir;\
	cp -a index.js lib $$utilDir;\
	cd ..;\
	zip -rq nodejs.zip nodejs;\
	aws lambda publish-layer-version --layer-name ${1} --zip-file fileb://nodejs.zip --compatible-runtimes nodejs14.x > /dev/null;\
	rm -f nodejs.zip
endef
define zipCode
	name=$(1);\
	cd ${funDir}/$${name};\
	zip -qr code.zip *;\
	aws lambda update-function-code --function-name $(2) --zip-file fileb://code.zip > /dev/null;\
	rm -f code.zip
endef
PHONY: smsConnectDeps
smsConnectDeps:
	$(call makeLayer,smsConnectDeps)
inboudCode:
	$(call zipCode,inboundMessageHandler,ChatMessageStreamingExamp-inboundMessageFunctionB5-njXNL94bdNWX)
	
outboudCode:
	$(call zipCode,outboundMessageHandler,ChatMessageStreamingExamp-outboundMessageFunction0-1PVFs8GGa3pp)