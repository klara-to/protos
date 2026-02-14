protodir    = klara
protogendir = .gen
protogendirgo = $(protogendir)/go/klarapb

protos  := $(shell find $(protodir) -type f -name '*.proto')

githubrepo = github.com/klara-to/protos

.SILENT: lint

all: protoc

$(protogendir): $(protogendirgo)

$(protogendirgo):
	if [ ! -d $(protogendirgo) ] ; then mkdir -p $(protogendirgo); fi

lint:
ifeq (, $(shell which clang-format))
	echo '\033[1;41m WARN \033[0m clang-format not found, not linting files';
else
	clang-format --style=file --dry-run $(protos)
endif

lint\:ci:
	clang-format --style=file --dry-run --Werror $(protos)

lint\:fix:
	clang-format --style=file -i $(protos)

protoc: protoc-go

protoc-go: $(protos) $(protogendir) protoc-gen-go protoc-gen-go-grpc
	protoc \
		--go_out=$(protogendir)/go --go_opt=module=$(githubrepo)/$(protogendir)/go \
		--go-grpc_out=$(protogendir)/go --go-grpc_opt=module=$(githubrepo)/$(protogendir)/go \
		$(protos)

protoc-gen-go:
ifeq (, $(shell which protoc-gen-go))
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
endif

protoc-gen-go-grpc:
ifeq (, $(shell which protoc-gen-go-grpc))
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
endif
