# 定义Protoc编译器的路径
PROTOC=protoc

# 定义生成Go文件的protoc插件
PROTOC_GEN_GO=protoc-gen-go
PROTOC_GEN_GO_GRPC=protoc-gen-go-grpc
PROTOC_GEN_GRPC_GATEWAY=protoc-gen-grpc-gateway
PROTOC_GEN_SWAGGER=protoc-gen-swagger

# 定义插件的路径
PROTOC_GEN_GO_PATH=$(shell which $(PROTOC_GEN_GO) 2>/dev/null)
PROTOC_GEN_GO_GRPC_PATH=$(shell which $(PROTOC_GEN_GO_GRPC) 2>/dev/null)
PROTOC_GEN_GRPC_GATEWAY_PATH=$(shell which $(PROTOC_GEN_GRPC_GATEWAY) 2>/dev/null)
PROTOC_GEN_SWAGGER_PATH=$(shell which $(PROTOC_GEN_SWAGGER) 2>/dev/null)

# 检查protoc-gen-go和protoc-gen-go-grpc插件是否存在
ifeq ($(PROTOC_GEN_GO_PATH),)
  $(error "protoc-gen-go is not installed, please install it first")
endif
ifeq ($(PROTOC_GEN_GO_GRPC_PATH),)
  $(error "protoc-gen-go-grpc is not installed, please install it first")
endif
ifeq ($(PROTOC_GEN_GRPC_GATEWAY_PATH),)
  $(error "protoc-gen-grpc-gateway is not installed, please install it first")
endif
ifeq ($(PROTOC_GEN_SWAGGER_PATH),)
  $(error "protoc-gen-swagger is not installed, please install it first")
endif

# 定义.proto文件的路径
PROTO_FILE=login.proto

# 定义生成的Go文件的输出目录
GO_OUT_DIR=.
GO_OUT_PACKAGE_DIR=./v1

# 定义生成的Go文件的路径
#GO_OUT=$(GO_OUT_DIR)/$(notdir $(PROTO_FILE:.proto=.pb.go))
GRPC_GO_OUT=$(GO_OUT_DIR)/$(notdir $(PROTO_FILE:.proto=_grpc.pb.go))


# 目标：默认目标是生成Go文件和gRPC文件
all: $(GRPC_GO_OUT)

## 规则：生成Go文件
#$(GO_OUT): $(PROTO_FILE)
#	$(PROTOC) --proto_path=. --go_out=$(GO_OUT_DIR) $(PROTO_FILE)

install_dependency:
	go install google.golang.org/protobuf/cmd/protoc-gen-go
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-swagger

# 规则：生成gRPC Go文件
$(GRPC_GO_OUT): $(PROTO_FILE)
	$(PROTOC) --proto_path=. \
	--go_out=$(GO_OUT_DIR) \
	--go-grpc_out=$(GO_OUT_DIR) \
	--grpc-gateway_out=$(GO_OUT_DIR) \
	--swagger_out=$(GO_OUT_PACKAGE_DIR) \
	$(PROTO_FILE)

# 清理生成的文件
clean:
	rm -rf $(GO_OUT_PACKAGE_DIR)

# 声明伪目标
.PHONY: all clean