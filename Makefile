.PHONY: clean clean_all run_pbook


default: run_pbook clean

clean: 
	@echo "Removing retry files"
	@rm -f *.retry

clean_all: clean
	@echo "Removing forklift"
	@rm -rf forklift

run_pbook:
	ansible-playbook setup.yaml


