#########################################################################
# Simple makefile for packaging Roku dreamTV application
#
# Makefile Usage:
# > make
# > make install
# > make remove
#
# Important Notes: 
# To use the "install" and "remove" targets to install your
# application directly from the shell, you must do the following:
#
# 1) Make sure that you have the curl command line executable in your path
# 2) Set the variable ROKU_DEV_TARGET in your environment to the IP 
#    address of your Roku box. (e.g. export ROKU_DEV_TARGET=192.168.1.1.
#    Set in your this variable in your shell startup (e.g. .bashrc)
##########################################################################  
APPREL = ../../dist
APPSRC = ..
APPNAME = dreamTV

.PHONY: all dreamTV

dreamTV: 
	@echo "*** packaging $(APPNAME).zip ***"

	@echo "  >> removing old application package $(APPREL)/$(APPNAME).zip"
	@if [ -e "$(APPREL)/$(APPNAME).zip" ]; \
	then \
		rm  $(APPREL)/$(APPNAME).zip; \
	fi

	@echo "  >> creating destination directory $(APPREL)"	
	@if [ ! -d $(APPREL) ]; \
	then \
		mkdir -p $(APPREL); \
	fi

	@echo "  >> setting directory permissions for $(APPREL)"
	@if [ ! -w $(APPREL) ]; \
	then \
		chmod 755 $(APPREL); \
	fi

	@echo "  >> creating application package $(APPREL)/$(APPNAME).zip"	
	@if [ -d $(APPSRC)/$(APPNAME) ]; \
	then \
		(zip -9 -r "$(APPREL)/$(APPNAME).zip" .); \
		(zip -d "$(APPREL)/$(APPNAME).zip" Makefile); \
	else \
		echo "Source for $(APPNAME) not found at $(APPSRC)/$(APPNAME)"; \
	fi

	@echo "*** packaging $(APPNAME) complete ***"

install:
	@echo "Installing $(APPSRC)/$(APPNAME) to host $(ROKU_DEV_TARGET)"
	@curl -s -S -F "mysubmit=Install" -F "archive=@$(APPREL)/$(APPNAME).zip" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//"

remove:
	@echo "Removing $(APPNAME) from host $(ROKU_DEV_TARGET)"
	@curl -s -S -F "mysubmit=Delete" -F "archive=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//"
