.PHONY: clean
clean:
	@rm -rf out/*
	@rm -rf runs/*
	@find . -name "output.xml" | xargs rm -rf
	@find . -name "log.html" | xargs rm -rf
	@find . -name "report.html" | xargs rm -rf
	@find . -name "diagnostics.log" | xargs rm -rf
	@find . -name "installed_packages.txt" | xargs rm -rf
	@find . -name "environment.yaml" | xargs rm -rf