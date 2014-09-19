.PHONY: watch clean run-server

watch:	build
	cd test && $(MAKE) watch

build:
	node_modules/.bin/browserify  test/www/js/browser-client.js --outfile awesome-websocket-global.js -t coffeeify
	node_modules/.bin/browserify  client.js --outfile awesome-websocket.js

client-module:
	node_modules/.bin/browserify  client.js --outfile awesome-websocket.js

publish:
	npm version patch -m "version up for patch"
	npm publish

clean:
	rm -rf node_modules
	rm -rf test/node_modules
