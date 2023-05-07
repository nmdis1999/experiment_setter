all:
	chmod +x build.sh
	./build.sh
	chmod +x collect_prof.sh
	./collect_prof.sh
	chmod +x multi_run.sh
	./multi_run.sh

clean:
	rm -rf tmux
	rm -rf profiles

