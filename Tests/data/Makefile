.PHONY: help

help:
	@grep -E '^[a-zA-Z_-][a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help


loop0: ## loopcount = 0
	gifsicle --delay=50 --loopcount=0 ./in/*.gif > ./out/loop0.gif

loop1: ## loopcount = 1
	gifsicle --delay=50 --loopcount=1 ./in/*.gif > ./out/loop1.gif

loop2: ## loopcount = 2
	gifsicle --delay=50 --loopcount=2 ./in/*.gif > ./out/loop2.gif

without_loop: ## without Application Extension Block
	gifsicle --delay=50 ./in/*.gif > ./out/without_loop.gif

convert_to_gif: ## convert png files to gif
	convert ./in/01.png ./in/01.gif
	convert ./in/02.png ./in/02.gif
	convert ./in/03.png ./in/03.gif

all: convert_to_gif loop0 loop1 loop2 without_loop
