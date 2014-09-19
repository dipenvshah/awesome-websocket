.PHONY: watch clean run-server

watch:	client-global client-module
	cp ./awesome-websocket.js ./test/www/js/awesome-websocket.js
	cp ./awesome-websocket-global.js ./test/www/js/awesome-websocket-global.js
	cd test && $(MAKE) watch

client-global:
	./node_modules/.bin/browserify  ./test/www/js/browser-client.js --outfile ./awesome-websocket-global.js -t coffeeify

client-module:
	./node_modules/.bin/browserify  ./client.js --outfile ./awesome-websocket.js


publish:
	npm version patch -m "version up for patch"
	npm publish

clean:
	rm -rf ./node_modules
	rm -rf ./test/node_modules
