VERSION ?= latest
PHP_VERSION ?= 8.0
ifdef BASE_IMAGE
	BUILD_ARG = --build-arg BASE_IMAGE=$(BASE_IMAGE)
	ifndef NAME
		NAME = phusion/baseimage-$(subst :,-,${BASE_IMAGE})
	endif
else
	NAME ?= signifly/php-$(PHP_VERSION)
endif
ifdef TAG_ARCH
	# VERSION_ARG = $(VERSION)-$(subst /,-,$(subst :,-,${BASE_IMAGE}))-$(TAG_ARCH)
	VERSION_ARG = $(VERSION)-$(TAG_ARCH)
	LATEST_VERSION = latest-$(TAG_ARCH)
else
	# VERSION_ARG = $(VERSION)-$(subst /,-,$(subst :,-,${BASE_IMAGE}))
	VERSION_ARG = $(VERSION)
	LATEST_VERSION = latest
endif
VERSION_ARG ?= $(VERSION)
PHP_VERSION_ARG ?= $(PHP_VERSION)

.PHONY: all

all: build

build:
	docker build -t $(NAME):$(VERSION_ARG) $(BUILD_ARG) --build-arg PHP_VERSION=$(PHP_VERSION_ARG) .
