.PHONY: test watch run-server clean

build: ./node_modules ../node_modules
	cp ../awesome-websocket.js www/js/awesome-websocket.js
	cp ../awesome-websocket-global.js www/js/awesome-websocket-global.js

watch: build
	PORT=8080 DEBUG=true ./node_modules/.bin/supervisor -V --watch .. --ignore ../node_modules,www,node_modules -e ".litcoffee|.coffee|.js" --exec make run-server

run-server: build
	exec server/server.js

./node_modules:
	npm install .

../node_modules:
	pushd .. && npm install . && popd

clean:
	rm -rf ./node_modules
	rm -rf ../node_modules
