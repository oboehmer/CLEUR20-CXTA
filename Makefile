.PHONY: clean
clean:
	@find . -name "out" -type d | xargs rm -rf
	@find . -name "device_logs" -type d | xargs rm -rf
	@find . -name "output.xml" | xargs rm -rf
	@find . -name "log.html" | xargs rm -rf
	@find . -name "report.html" | xargs rm -rf
	@find . -name "diagnostics.log" | xargs rm -rf
	@find . -name "installed_packages.txt" | xargs rm -rf
	@find . -name "environment.yaml" | xargs rm -rf
