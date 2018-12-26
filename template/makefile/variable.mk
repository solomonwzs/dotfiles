debug-var-%:
	@echo -n '$($*)'

debug-ori-%:
	@echo -n '$(origin $*)'

debug-fla-%:
	@echo -n '$(flavor $*)'

debug-val-%:
	@echo -n '$(value  $*)'
