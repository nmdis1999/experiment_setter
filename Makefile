all:
	chmod +x build.sh
	./build.sh
	chmod +x collect_prof.sh
	./collect_prof.sh
	chmod +x multi_run.sh
	./multi_run.sh
	chmod +x val_run.sh
	./val_run.sh
	chmod +x valgrind_data_collector.sh
	./valgrind_data_collector.sh

clean:
	rm -rf tmux
	rm -rf profiles

