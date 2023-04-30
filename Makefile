all:
	chmod +x build.sh
	./build.sh
	chmod +x benchmark.sh
	./benchmark.sh

clean:
	rm -rf tmux
	rm -rf profiles

