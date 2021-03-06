app ?= $(notdir $(basename $(CURDIR)))
common_srcs ?=
srcs ?= src/$(app).d $(common_srcs)
imports ?= -I$(common_srcdir)

app_debug = $(project_bindir)/$(app).dbg
app_release = $(project_bindir)/$(app)

release: $(app_release)
debug: $(app_debug)

$(app_release): $(srcs)
	$(DCOMPILER) $(release_flags) -of$(app_release) $(imports) $(srcs)
$(app_debug): $(srcs)
	$(DCOMPILER) $(debug_flags) -of$(app_debug) $(imports) $(srcs)

clean:
	-rm $(app_debug)
	-rm $(app_release)
	-rm $(objdir)/*.o

.PHONY: test
test: test-debug test-release

.PHONY: test-debug
test-debug: $(app_debug)
	-@if [ -d $(testsdir)/latest_debug ]; then echo 'Deleting prior test files.';  rm $(testsdir)/latest_debug/*; fi
	@if [ ! -d $(testsdir)/latest_debug ]; then mkdir $(testsdir)/latest_debug; fi
	cd $(testsdir) && ./tests.sh $(app_debug) latest_debug
	@if diff -q $(testsdir)/latest_debug $(testsdir)/gold ; \
	then echo '---> $(app) command line tests passed.'; exit 0; \
	else echo '---> $(app) command line tests failed.'; \
	exit 1; \
	fi

.PHONY: test-release
test-release: $(app_release)
	-@if [ -d $(testsdir)/latest_release ]; then echo 'Deleting prior test files.';  rm $(testsdir)/latest_release/*; fi
	@if [ ! -d $(testsdir)/latest_release ]; then mkdir $(testsdir)/latest_release; fi
	cd $(testsdir) && ./tests.sh $(app_release) latest_release
	@if diff -q $(testsdir)/latest_release $(testsdir)/gold ; \
	then echo '---> $(app) command line tests passed.'; exit 0; \
	else echo '---> $(app) command line tests failed.'; \
	exit 1; \
	fi

.PHONY: test-nobuild
test-nobuild:
	-@if [ -d $(testsdir)/latest_release ]; then echo 'Deleting prior test files.';  rm $(testsdir)/latest_release/*; fi
	@if [ ! -d $(testsdir)/latest_release ]; then mkdir $(testsdir)/latest_release; fi
	cd $(testsdir) && ./tests.sh $(app_release) latest_release
	@if diff -q $(testsdir)/latest_release $(testsdir)/gold ; \
	then echo '---> $(app) command line tests passed.'; exit 0; \
	else echo '---> $(app) command line tests failed.'; \
	exit 1; \
	fi

