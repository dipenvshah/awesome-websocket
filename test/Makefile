.PHONY: test watch run-server clean build


build:
	node_modules/.bin/browserify  ../for-browser-as-window-vars.js \
		--outfile www/js/awesome-websocket-global.js 
	node_modules/.bin/browserify  ../for-browser.js \
		--outfile www/js/awesome-websocket.js

watch: 
	PORT=8080 DEBUG=true ./node_modules/.bin/supervisor -V --watch .. --ignore ../node_modules,www,node_modules,../awesome-websocket.js,../awesome-websocket-global.js -e ".litcoffee|.coffee|.js" --exec make run-server

run-server: build
	exec server/server.js

./node_modules:
	npm install .

../node_modules:
	pushd .. && npm install . && popd

clean:
	rm -rf ./node_modules
	rm -rf ../node_modules
