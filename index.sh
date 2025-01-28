#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' 


pid=""


build_and_run() {
    echo -e "${GREEN}Building application...${NC}"
    
    if [ ! -z "$pid" ]; then
        kill $pid 2>/dev/null
    fi

    go build -o ./tmp/app
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Build successful. Starting application...${NC}"

        ./tmp/app & pid=$!
    else
        echo -e "${RED}Build failed${NC}"
    fi
}

mkdir -p tmp

build_and_run

echo -e "${GREEN}Watching for changes...${NC}"
while true; do
    inotifywait -r -e modify -e create -e delete --format '%w%f' . | while read file; do
        if [[ $file == *.go ]]; then
            echo -e "${GREEN}Detected change in${NC} $file"
            build_and_run
        fi
    done
done